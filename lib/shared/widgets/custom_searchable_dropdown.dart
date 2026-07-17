import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomSearchableDropdown extends StatefulWidget {
  final String labelText;
  final String hintText;
  final List<Map<String, dynamic>> items;
  final String? selectedValue;
  final String idKey;
  final String displayKey;
  final bool isRequired;
  final bool readOnly;
  final void Function(Map<String, dynamic>?) onChanged;

  const CustomSearchableDropdown({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.idKey = '_id',
    this.displayKey = 'name',
    this.isRequired = false,
    this.readOnly = false,
  });

  @override
  State<CustomSearchableDropdown> createState() => _CustomSearchableDropdownState();
}

class _CustomSearchableDropdownState extends State<CustomSearchableDropdown> {
  String _getDisplayValue(Map<String, dynamic> item) {
    if (item.containsKey(widget.displayKey)) return item[widget.displayKey]?.toString() ?? '';
    if (item.containsKey('label')) return item['label']?.toString() ?? '';
    if (item.containsKey('name')) return item['name']?.toString() ?? '';
    return item.toString();
  }

  String _getIdValue(Map<String, dynamic> item) {
    if (item.containsKey(widget.idKey)) return item[widget.idKey]?.toString() ?? '';
    if (item.containsKey('value')) return item['value']?.toString() ?? '';
    if (item.containsKey('_id')) return item['_id']?.toString() ?? '';
    return item.toString();
  }

  void _showBottomSheet() {
    if (widget.readOnly || widget.items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SingleSelectBottomSheet(
        labelText: widget.labelText,
        items: widget.items,
        selectedValue: widget.selectedValue,
        getDisplayValue: _getDisplayValue,
        getIdValue: _getIdValue,
        onSelected: (item) {
          widget.onChanged(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find display name for currently selected value
    String displayLabel = '';
    if (widget.selectedValue != null && widget.selectedValue!.isNotEmpty) {
      final selectedItem = widget.items.firstWhereOrNull(
        (item) => _getIdValue(item) == widget.selectedValue,
      );
      if (selectedItem != null) {
        displayLabel = _getDisplayValue(selectedItem);
      } else {
        displayLabel = widget.selectedValue!;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.labelText,
              style: AppTextStyles.label,
              children: [
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: _showBottomSheet,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: widget.readOnly ? AppColors.surface.withValues(alpha: 0.5) : AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border, width: 1.w),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel.isNotEmpty ? displayLabel : widget.hintText,
                    style: displayLabel.isNotEmpty
                        ? AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)
                        : AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: widget.readOnly ? AppColors.textHint.withValues(alpha: 0.5) : AppColors.textHint,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SingleSelectBottomSheet extends StatefulWidget {
  final String labelText;
  final List<Map<String, dynamic>> items;
  final String? selectedValue;
  final String Function(Map<String, dynamic>) getDisplayValue;
  final String Function(Map<String, dynamic>) getIdValue;
  final void Function(Map<String, dynamic>) onSelected;

  const _SingleSelectBottomSheet({
    required this.labelText,
    required this.items,
    required this.selectedValue,
    required this.getDisplayValue,
    required this.getIdValue,
    required this.onSelected,
  });

  @override
  State<_SingleSelectBottomSheet> createState() => _SingleSelectBottomSheetState();
}

class _SingleSelectBottomSheetState extends State<_SingleSelectBottomSheet> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => widget
                .getDisplayValue(item)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      constraints: BoxConstraints(maxHeight: 0.75.sh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select ${widget.labelText}',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _searchController,
            onChanged: _filterList,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No items found',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final id = widget.getIdValue(item);
                      final display = widget.getDisplayValue(item);
                      final isSelected = widget.selectedValue == id;

                      return ListTile(
                        onTap: () => widget.onSelected(item),
                        title: Text(
                          display,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: AppColors.primary)
                            : null,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CustomMultiSelectDropdown extends StatefulWidget {
  final String labelText;
  final String hintText;
  final List<Map<String, dynamic>> items;
  final RxList selectedIds;
  final String idKey;
  final String displayKey;
  final bool isRequired;
  final void Function(Map<String, dynamic>) onToggle;

  const CustomMultiSelectDropdown({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.items,
    required this.selectedIds,
    required this.onToggle,
    this.idKey = '_id',
    this.displayKey = 'name',
    this.isRequired = false,
  });

  @override
  State<CustomMultiSelectDropdown> createState() => _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  String _getDisplayValue(Map<String, dynamic> item) {
    if (item.containsKey(widget.displayKey)) return item[widget.displayKey]?.toString() ?? '';
    if (item.containsKey('label')) return item['label']?.toString() ?? '';
    if (item.containsKey('name')) return item['name']?.toString() ?? '';
    return item.toString();
  }

  String _getIdValue(Map<String, dynamic> item) {
    if (item.containsKey(widget.idKey)) return item[widget.idKey]?.toString() ?? '';
    if (item.containsKey('value')) return item['value']?.toString() ?? '';
    if (item.containsKey('_id')) return item['_id']?.toString() ?? '';
    return item.toString();
  }

  void _showBottomSheet() {
    if (widget.items.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MultiSelectBottomSheet(
        labelText: widget.labelText,
        items: widget.items,
        selectedIds: widget.selectedIds,
        getDisplayValue: _getDisplayValue,
        getIdValue: _getIdValue,
        onToggle: widget.onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: widget.labelText,
              style: AppTextStyles.label,
              children: [
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        GestureDetector(
          onTap: _showBottomSheet,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border, width: 1.w),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    if (widget.selectedIds.isEmpty) {
                      return Text(
                        widget.hintText,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                    return Text(
                      '${widget.selectedIds.length} Selected',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textHint,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          if (widget.selectedIds.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: widget.selectedIds.map((id) {
                  final item = widget.items.firstWhereOrNull((item) => _getIdValue(item) == id);
                  final display = item != null ? _getDisplayValue(item) : id.toString();
                  return InputChip(
                    label: Text(
                      display,
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.primary,
                    deleteIcon: Icon(Icons.close_rounded, size: 14.sp, color: Colors.white),
                    onDeleted: () {
                      if (item != null) widget.onToggle(item);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _MultiSelectBottomSheet extends StatefulWidget {
  final String labelText;
  final List<Map<String, dynamic>> items;
  final RxList selectedIds;
  final String Function(Map<String, dynamic>) getDisplayValue;
  final String Function(Map<String, dynamic>) getIdValue;
  final void Function(Map<String, dynamic>) onToggle;

  const _MultiSelectBottomSheet({
    required this.labelText,
    required this.items,
    required this.selectedIds,
    required this.getDisplayValue,
    required this.getIdValue,
    required this.onToggle,
  });

  @override
  State<_MultiSelectBottomSheet> createState() => _MultiSelectBottomSheetState();
}

class _MultiSelectBottomSheetState extends State<_MultiSelectBottomSheet> {
  final _searchController = TextEditingController();
  final RxList<Map<String, dynamic>> _filteredItems = RxList<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    _filteredItems.assignAll(widget.items);
  }

  void _filterList(String query) {
    if (query.isEmpty) {
      _filteredItems.assignAll(widget.items);
    } else {
      _filteredItems.assignAll(
        widget.items
            .where((item) => widget
                .getDisplayValue(item)
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      constraints: BoxConstraints(maxHeight: 0.75.sh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select ${widget.labelText}',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('Done', style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 13.sp)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _searchController,
            onChanged: _filterList,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              if (_filteredItems.isEmpty) {
                return Center(
                  child: Text(
                    'No items found',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                  ),
                );
              }
              return ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final id = widget.getIdValue(item);
                  final display = widget.getDisplayValue(item);

                  return Obx(() => ListTile(
                    onTap: () => widget.onToggle(item),
                    title: Text(
                      display,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.selectedIds.contains(id) ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: widget.selectedIds.contains(id) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: Checkbox(
                      value: widget.selectedIds.contains(id),
                      activeColor: AppColors.primary,
                      onChanged: (_) => widget.onToggle(item),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  ));
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
