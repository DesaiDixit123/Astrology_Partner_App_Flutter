import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../pages/incoming_call_overlay.dart';

class PartnerCallController extends GetxController {
  static PartnerCallController get to => Get.find();

  final RxMap currentSession = {}.obs;
  final RxMap customer = {}.obs;
  final RxString callStatus = 'idle'.obs; // 'idle', 'ringing', 'connected', 'ended'
  final RxInt callDuration = 0.obs;
  final RxBool isMuted = false.obs;
  final RxBool isVideoOn = true.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxInt remoteUid = 0.obs;
  bool _isShowingSummaryDialog = false;

  late RtcEngine engine;
  IO.Socket? _signalSocket;
  IO.Socket? _presenceSocket;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _durationTimer;
  String _astrologerId = '';
  bool _presenceEnabled = false;

  @override
  void onInit() {
    super.onInit();
    _loadUserAndInit();
  }

  Future<void> _loadUserAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    _astrologerId = prefs.getString(AppConstants.keyUserId) ?? '';
    _initSignalSocket();
    _initPresenceSocket();
  }

  Future<void> registerAfterLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _astrologerId = prefs.getString(AppConstants.keyUserId) ?? '';
    if (_astrologerId.isEmpty) return;

    if (_signalSocket == null) {
      _initSignalSocket();
    }
    if (_presenceSocket == null) {
      _initPresenceSocket();
    }

    if (_signalSocket?.connected == true) {
      _signalSocket?.emit('register_astrologer', _astrologerId);
    } else {
      _signalSocket?.connect();
    }

    if (_presenceEnabled) {
      if (_presenceSocket?.connected == true) {
        _presenceSocket?.emit('register_astrologer_presence', _astrologerId);
      } else {
        _presenceSocket?.connect();
      }
    }
  }

  void updatePresenceRegistration({
    required String astrologerId,
    required bool isOnline,
  }) {
    _astrologerId = astrologerId;
    _presenceEnabled = isOnline;

    if (_presenceSocket == null) {
      _initPresenceSocket();
    }

    if (_presenceSocket?.connected != true) {
      _presenceSocket?.connect();
      return;
    }

    if (_presenceEnabled) {
      _presenceSocket?.emit('register_astrologer_presence', _astrologerId);
    } else {
      _presenceSocket?.emit('unregister_astrologer_presence', _astrologerId);
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    _durationTimer?.cancel();
    _disposeAgora();
    _signalSocket?.disconnect();
    _presenceSocket?.disconnect();
    super.onClose();
  }

  void _initSignalSocket() {
    if (_signalSocket != null) return;

    _signalSocket = IO.io(ApiConstants.baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

    _signalSocket?.onConnect((_) {
      if (_astrologerId.isNotEmpty) {
        _signalSocket?.emit('register_astrologer', _astrologerId);
      }
    });

    // Listen for incoming call requests
    _signalSocket?.on('call_request', (data) {
      if (data is Map) {
        _handleIncomingCall(data, isVideo: false);
      }
    });

    _signalSocket?.on('video_call_request', (data) {
      if (data is Map) {
        _handleIncomingCall(data, isVideo: true);
      }
    });

    _signalSocket?.on('call_ended', (data) {
      if (callStatus.value == 'idle' && _isShowingSummaryDialog) return;
      _handleCallEnded(data);
    });
  }

  void _initPresenceSocket() {
    if (_presenceSocket != null) return;

    _presenceSocket = IO.io(ApiConstants.baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

    _presenceSocket?.onConnect((_) {
      if (_astrologerId.isNotEmpty && _presenceEnabled) {
        _presenceSocket?.emit('register_astrologer_presence', _astrologerId);
      }
    });
  }

  void _handleIncomingCall(Map data, {required bool isVideo}) {
    // If already in a call, the backend should ideally handle busy status, 
    // but we can add a secondary check here.
    if (callStatus.value != 'idle') return;

    currentSession.value = data;
    customer.value = data['customer'] ?? {};
    callStatus.value = 'ringing';

    // Play ringtone loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('incoming_call.mp3'));

    // Show WhatsApp-style overlay
    Get.to(() => const IncomingCallOverlay(), 
      opaque: false, 
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      arguments: {'isVideo': isVideo}
    );
  }

  Future<void> acceptCall({required bool isVideo}) async {
    _audioPlayer.stop();
    // Request Permissions
    await Permission.microphone.request();
    if (isVideo) {
      await Permission.camera.request();
    }

    final sessionId = currentSession['session_id'] ?? currentSession['_id'];
    
    // Join Agora
    await _initAgora(
      appId: currentSession['agora_app_id'],
      channel: currentSession['channel'],
      token: currentSession['agora_token'],
      isVideo: isVideo,
    );

    // Join Socket Room
    _signalSocket?.emit('join_call', {
      'session_id': sessionId,
      'astrologer_id': _astrologerId,
      'type': isVideo ? 'video_call' : 'call',
      'participant_type': 'astrologer',
    });

    callStatus.value = 'connected';
    callDuration.value = 0;
    _startTimer();
    
    Get.back(); // Close overlay
    if (isVideo) {
      Get.toNamed('/video-call');
    } else {
      Get.toNamed('/voice-call');
    }
  }

  Future<void> rejectCall() async {
    _audioPlayer.stop();
    final sessionId = currentSession['session_id'] ?? currentSession['_id'];

    // Use HTTP to ensure DB is reliably updated
    try {
      await ApiService.instance.post(ApiConstants.partnerEndCall, data: {
        'session_id': sessionId,
        'duration': 0
      });
    } catch (_) {}

    _signalSocket?.emit('end_call', {
      'session_id': sessionId,
      'reason': 'astrologer_rejected'
    });
    _cleanupAndExit();
  }

  Future<void> _initAgora({
    required String appId,
    required String channel,
    required String token,
    required bool isVideo,
  }) async {
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: appId));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Partner joined Agora channel');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          this.remoteUid.value = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          this.remoteUid.value = 0;
          endCall();
        },
      ),
    );

    if (isVideo) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.enableAudio();
    }

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value++;
    });
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    await engine.muteLocalAudioStream(isMuted.value);
  }

  Future<void> toggleVideo() async {
    isVideoOn.value = !isVideoOn.value;
    await engine.muteLocalVideoStream(!isVideoOn.value);
  }

  Future<void> switchCamera() async {
    await engine.switchCamera();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await engine.setEnableSpeakerphone(isSpeakerOn.value);
  }

  Future<void> endCall() async {
    final sessionId = currentSession['session_id'] ?? currentSession['_id'];

    // Use HTTP to ensure DB is reliably updated
    try {
      await ApiService.instance.post(ApiConstants.partnerEndCall, data: {
        'session_id': sessionId,
        'duration': callDuration.value
      });
    } catch (_) {}

    _signalSocket?.emit('end_call', {
      'session_id': sessionId,
      'reason': 'astrologer_ended'
    });
    _cleanupAndExit();
  }

  void _handleCallEnded(dynamic data) {
    if (callStatus.value == 'idle' && _isShowingSummaryDialog) return;
    
    _cleanupAndExit();
    
    final Map summary = data is Map ? data : {};
    final double totalEarning = (summary['total_earning'] as num?)?.toDouble() ?? 0.0;
    
    SnackbarUtil.success('Call ended. Earning: ₹$totalEarning');
    _showSummaryDialog(summary);
  }

  void _exitCallScreen() {
    if (Get.isDialogOpen == true) Get.back();
    final route = Get.currentRoute;
    if (route.contains('call') || route.contains('incoming')) {
      Get.back();
    }
  }

  void _cleanupAndExit() {
    _audioPlayer.stop();
    _durationTimer?.cancel();
    _disposeAgora();
    
    callStatus.value = 'idle';
    _exitCallScreen();
  }

  Future<void> _disposeAgora() async {
    try {
      await engine.leaveChannel();
      await engine.release();
    } catch (e) {
      print('Error disposing Agora: $e');
    }
  }

  void _showSummaryDialog(Map data) {
    if (_isShowingSummaryDialog) return;
    _isShowingSummaryDialog = true;

    if (Get.isDialogOpen == true) Get.back();

    // Show earnings summary
    Get.defaultDialog(
      title: 'Call Summary',
      middleText: 'Duration: ${(data['duration'] ?? 0) ~/ 60} mins\nEarning: ₹${data['total_earning'] ?? 0.0}',
      textConfirm: 'OK',
      onConfirm: () {
        _isShowingSummaryDialog = false;
        _exitCallScreen();
      },
      barrierDismissible: false,
    );
  }
}
