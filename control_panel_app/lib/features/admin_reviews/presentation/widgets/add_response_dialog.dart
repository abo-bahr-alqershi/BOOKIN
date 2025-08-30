// lib/features/admin_reviews/presentation/widgets/add_response_dialog.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:bookn_cp_app/core/theme/app_theme.dart';
import 'package:bookn_cp_app/core/theme/app_text_styles.dart';

class AddResponseDialog extends StatefulWidget {
  final String reviewId;
  final Function(String) onSubmit;
  
  const AddResponseDialog({
    super.key,
    required this.reviewId,
    required this.onSubmit,
  });
  
  @override
  State<AddResponseDialog> createState() => _AddResponseDialogState();
}

class _AddResponseDialogState extends State<AddResponseDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isValid = _controller.text.trim().isNotEmpty;
      });
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withOpacity(0.95),
              AppTheme.darkCard.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.reply_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Text(
                        'إضافة رد',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Text Field
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.darkSurface.withOpacity(0.6),
                          AppTheme.darkSurface.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 5,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textWhite,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب ردك هنا...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textMuted.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Submit Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: _isValid
                              ? AppTheme.primaryGradient
                              : LinearGradient(
                                  colors: [
                                    AppTheme.textMuted.withOpacity(0.3),
                                    AppTheme.textMuted.withOpacity(0.2),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isValid
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: TextButton(
                          onPressed: _isValid
                              ? () {
                                  widget.onSubmit(_controller.text.trim());
                                  Navigator.pop(context);
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Text(
                              'إرسال',
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}