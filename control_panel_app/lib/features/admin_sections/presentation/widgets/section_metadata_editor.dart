import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

class SectionMetadataEditor extends StatefulWidget {
  final String? initialMetadata;
  final Function(String) onMetadataChanged;

  const SectionMetadataEditor({
    super.key,
    this.initialMetadata,
    required this.onMetadataChanged,
  });

  @override
  State<SectionMetadataEditor> createState() => _SectionMetadataEditorState();
}

class _SectionMetadataEditorState extends State<SectionMetadataEditor> {
  final TextEditingController _jsonController = TextEditingController();
  final bool _isValidJson = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMetadata != null) {
      try {
        final formatted = const JsonEncoder.withIndent('  ')
            .convert(json.decode(widget.initialMetadata!));
        _jsonController.text = formatted;
      } catch (e) {
        _jsonController.text = widget.initialMetadata!;
      }
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'البيانات الإضافية (Metadata)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  CupertinoIcons.chevron_down,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isExpanded ? 300 : 0,
          child: _isExpanded ? _buildEditor() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: