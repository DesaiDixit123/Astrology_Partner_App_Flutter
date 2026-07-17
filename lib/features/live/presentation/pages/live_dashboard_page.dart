import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrology_partner/core/constants/agora_constants.dart';
import 'package:astrology_partner/core/constants/api_constants.dart';
import 'package:astrology_partner/core/theme/app_colors.dart';
import 'package:astrology_partner/core/theme/app_text_styles.dart';
import 'package:astrology_partner/core/utils/snackbar_util.dart';
import 'package:astrology_partner/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../controllers/live_controller.dart';

class LiveDashboardPage extends StatefulWidget {
  const LiveDashboardPage({super.key});

  @override
  State<LiveDashboardPage> createState() => _LiveDashboardPageState();
}

class _LiveDashboardPageState extends State<LiveDashboardPage> {
  final LiveController _liveController = Get.find<LiveController>();
  final DashboardController _dashboardController = Get.find<DashboardController>();

  RtcEngine? _engine;
  IO.Socket? _socket;
  bool _socketConnected = false;
  bool _chatVisible = true; // Local-only: hide/show chat without affecting others.
  bool _inLiveRoom = false; // Best-effort room membership flag (local only).

  final List<Map<String, dynamic>> _chatMessages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  Timer? _liveTimer;
  int _liveSeconds = 0;

  Timer? _countdownTimer;
  int _countdown = 0;
  bool _startCountdown = true;

  bool _micMuted = false;
  bool _cameraOff = false;

  String _streamId = '';
  String _channel = '';
  String _token = '';
  String _title = '';
  int _uid = 0;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _loadArgs();
    _initSocket();
    _initAgora();
  }

  void _loadArgs() {
    final args = Get.arguments;
    final Map data = (args is Map) ? args : _liveController.activeStream;
    _streamId = (data['stream_id'] ?? data['streamId'] ?? '').toString();
    _channel = (data['channel'] ?? '').toString();
    _token = (data['token'] ?? '').toString();
    _title = (data['title'] ?? '').toString();
    _startCountdown = data['startCountdown'] != false;
    final rawUid = data['uid'];
    _uid = (rawUid is num) ? rawUid.toInt() : int.tryParse(rawUid?.toString() ?? '') ?? 0;
  }

  Future<void> _initAgora() async {
    final status = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted = status[Permission.camera]?.isGranted == true;
    final micGranted = status[Permission.microphone]?.isGranted == true;

    if (!cameraGranted || !micGranted) {
      SnackbarUtil.error('permissions_required'.tr);
      return;
    }

    final engine = createAgoraRtcEngine();
    await engine.initialize(
      const RtcEngineContext(
        appId: AgoraConstants.appId,
      ),
    );

    // Register after initialize so callbacks always fire (SDKs may reset handlers on init).
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('Agora(host) joined channel=${connection.channelId} uid=${connection.localUid} elapsed=$elapsed');
          _liveTimer?.cancel();
          _liveSeconds = 0;
          _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => _liveSeconds++);
          });
          if (mounted) {
            setState(() {
              _joined = true;
              // If we joined with uid=0, Agora assigns a uid; store for debugging.
              _uid = connection.localUid ?? _uid;
            });
          }
        },
        onLeaveChannel: (_, __) {
          debugPrint('Agora(host) left channel');
          if (mounted) setState(() => _joined = false);
        },
        onConnectionStateChanged: (_, state, reason) {
          debugPrint('Agora(host) connectionState=$state reason=$reason');
          if (state == ConnectionStateType.connectionStateFailed) {
            SnackbarUtil.error('${'connection_failed'.tr}: $reason');
          }
        },
        onError: (err, msg) {
          debugPrint('Agora(host) error=$err msg=$msg');
          SnackbarUtil.error('Agora error: $err $msg');
        },
      ),
    );

    await engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableVideo();
    await engine.enableAudio();
    await engine.startPreview();

    if (!mounted) {
      await engine.release();
      return;
    }

    setState(() => _engine = engine);

    if (_startCountdown) {
      _beginCountdown();
    } else {
      await _joinChannel();
    }
  }

  Future<void> _joinChannel() async {
    if (_engine == null || _channel.isEmpty) return;
    if (_token.isEmpty) {
      SnackbarUtil.error('missing_token'.tr);
      return;
    }

    debugPrint('Agora(host) joining channel=$_channel uid=$_uid tokenLen=${_token.length}');
    await _engine!.joinChannel(
      token: _token,
      channelId: _channel,
      uid: _uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  void _beginCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = 3);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
        await _joinChannel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _initSocket() {
    if (_streamId.isEmpty) return;

    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _socket?.onConnect((_) {
      debugPrint('Socket(live host) connected id=${_socket?.id}');
      if (mounted) setState(() => _socketConnected = true);
      _socket?.emit('join_live_room', {'live_stream_id': _streamId});
    });

    _socket?.on('joined_live_room', (data) {
      debugPrint('Socket(live host) joined_live_room: $data');
      _inLiveRoom = true;
      if (mounted) setState(() {});
    });

    _socket?.on('left_live_room', (data) {
      debugPrint('Socket(live host) left_live_room: $data');
      _inLiveRoom = false;
      if (mounted) setState(() {});
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket(live host) disconnected');
      _inLiveRoom = false;
      if (mounted) setState(() => _socketConnected = false);
    });

    _socket?.onConnectError((err) {
      debugPrint('Socket(live host) connectError: $err');
      _inLiveRoom = false;
      if (mounted) setState(() => _socketConnected = false);
    });

    _socket?.onError((err) {
      debugPrint('Socket(live host) error: $err');
    });

    _socket?.on('receive_live_message', (data) {
      if (data is Map) {
        debugPrint('Socket(live host) message: $data');
        final msg = Map<String, dynamic>.from(data);
        // Always keep a local history, but only rebuild UI if chat is visible.
        if (_chatVisible) {
          if (!mounted) return;
          setState(() => _chatMessages.add(msg));
          _scrollChatToBottom();
        } else {
          _chatMessages.add(msg);
        }
      }
    });

    _socket?.connect();
  }

  void _scrollChatToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    if (!_chatVisible) return;
    final text = _messageController.text.trim();
    if (text.isEmpty || _socket == null || _streamId.isEmpty) return;

    // If we haven't joined the live room for some reason, try again (idempotent).
    if (!_inLiveRoom) {
      _socket?.emit('join_live_room', {'live_stream_id': _streamId});
    }

    final me = _dashboardController.profile;
    _socket?.emit('send_live_message', {
      'live_stream_id': _streamId,
      'text': text,
      'sender_id': me['_id']?.toString() ?? '',
      'sender_type': 'astrologer',
      'sender_name': me['name']?.toString() ?? 'Astrologer',
      'sender_profile_pic': me['profile_pic']?.toString() ?? '',
    });

    _messageController.clear();
  }

  void _toggleChatVisible() {
    setState(() => _chatVisible = !_chatVisible);
    if (_chatVisible) _scrollChatToBottom();
  }

  Future<void> _toggleMic() async {
    if (_engine == null) return;
    final next = !_micMuted;
    await _engine!.muteLocalAudioStream(next);
    setState(() => _micMuted = next);
  }

  Future<void> _toggleCamera() async {
    if (_engine == null) return;
    final next = !_cameraOff;
    await _engine!.enableLocalVideo(!next);
    await _engine!.muteLocalVideoStream(next);
    setState(() => _cameraOff = next);
  }

  Future<void> _switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
  }

  bool _isEnding = false;

  Future<void> _endLive() async {
    if (_isEnding) return;
    if (mounted) setState(() => _isEnding = true);

    _countdownTimer?.cancel();
    _liveTimer?.cancel();

    // 1. Close screen immediately if still mounted
    if (mounted) {
      Navigator.of(context).pop();
    }

    // 2. Perform backend update and device cleanup asynchronously in the background
    _liveController.endLive().catchError((_) => null);

    final tempEngine = _engine;
    _engine = null;
    if (tempEngine != null) {
      try {
        tempEngine.leaveChannel();
        tempEngine.release();
      } catch (_) {}
    }

    try {
      if (_socket != null) {
        _socket!.emit('leave_live_room', {'live_stream_id': _streamId});
        _socket!.disconnect();
      }
    } catch (_) {}
    _socket = null;
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _liveTimer?.cancel();
    _messageController.dispose();
    _chatScrollController.dispose();
    _socket?.disconnect();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveLabel = _joined ? 'LIVE ${_formatDuration(_liveSeconds)}' : 'connecting'.tr;
    return PopScope(
      canPop: _isEnding,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _endLive();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Camera view
              if (_engine != null && !_cameraOff)
                AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              else
                Center(
                  child: Icon(Icons.person, color: Colors.white24, size: 200.sp),
                ),

              // Top bar
              Positioned(
                top: 24.h,
                left: 16.w,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 10.sp),
                          SizedBox(width: 6.w),
                          Text(
                            liveLabel,
                            style: AppTextStyles.caption.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    InkWell(
                      onTap: _toggleChatVisible,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: BoxDecoration(
                                color: !_socketConnected
                                    ? Colors.white38
                                    : (_inLiveRoom ? Colors.greenAccent : Colors.orangeAccent),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              _chatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline,
                              color: Colors.white70,
                              size: 14.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              _chatVisible ? 'chat_on'.tr : 'chat_off'.tr,
                              style: AppTextStyles.caption.copyWith(
                                color: _chatVisible ? Colors.greenAccent : Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          _title.isNotEmpty ? _title : 'live_session'.tr,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _endLive,
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Icon(Icons.close, color: Colors.white, size: 30.sp),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat overlay
              if (_chatVisible)
                Positioned(
                  bottom: 140.h,
                  left: 16.w,
                  right: 16.w,
                  height: 220.h,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                        stops: [0.0, 0.3],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: ListView.builder(
                      controller: _chatScrollController,
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final msg = _chatMessages[index];
                        final name = (msg['sender_name'] ?? 'User').toString();
                        final text = (msg['text'] ?? '').toString();
                        final isMe = msg['sender_type'] == 'astrologer' || msg['sender_type'] == 'partner';
                        
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 6.h),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12.r),
                              border: isMe 
                                  ? Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1.r)
                                  : null,
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  if (isMe) ...[
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(Icons.stars, color: Colors.amber, size: 14.sp),
                                    ),
                                    const TextSpan(text: ' '),
                                  ],
                                  TextSpan(
                                    text: '$name: ',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isMe ? Colors.amberAccent : Colors.lightBlueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: text,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Bottom input + controls
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_chatVisible) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'say_something'.tr,
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: Colors.black54,
                                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white, size: 22.sp),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ControlButton(
                          icon: Icons.flip_camera_ios,
                          onPressed: _switchCamera,
                        ),
                        _ControlButton(
                          icon: _micMuted ? Icons.mic_off : Icons.mic,
                          onPressed: _toggleMic,
                        ),
                        _ControlButton(
                          icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                          onPressed: _toggleCamera,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3-2-1 countdown overlay
              if (_countdown > 0)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _countdown.toString(),
                            style: TextStyle(
                              fontSize: 86.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'going_live'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28.sp),
        onPressed: onPressed,
      ),
    );
  }
}
