// lib/features/admin_reviews/presentation/widgets/add_response_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';

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

class _AddResponseDialogState extends State<AddResponseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _responseController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  int _characterCount = 0;
  final int _maxCharacters = 1000;
  
  // Quick response templates
  final List<String> _templates = [
    'Thank you for your feedback! We appreciate your review.',
    'We\'re sorry to hear about your experience. We\'ll work to improve.',
    'Thank you for taking the time to share your thoughts with us.',
    'We\'re glad you enjoyed your stay! Looking forward to welcoming you again.',
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
    
    _responseController.addListener(() {
      setState(() {
        _characterCount = _responseController.text.length;
      });
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _responseController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _submitResponse() async {
    if (_responseController.text.trim().isEmpty) {
      HapticFeedback.mediumImpact();
      return;
    }
    
    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    widget.onSubmit(_responseController.text.trim());
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(24),
                  ),
                  color: AppTheme.darkCard,
                  border: Border.all(
                    color: AppTheme.darkBorder.withOpacity(0.3),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle Bar
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: AppTheme.textMuted.withOpacity(0.3),
                          ),
                        ),
                        
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: AppTheme.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.reply,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Response',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textWhite,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Reply to customer review',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Quick Templates
                        Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _templates.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildTemplateChip(_templates[index]),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Text Input
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppTheme.glassDark.withOpacity(0.3),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? AppTheme.primaryBlue.withOpacity(0.5)
                                  : AppTheme.darkBorder.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _responseController,
                                focusNode: _focusNode,
                                maxLines: 6,
                                maxLength: _maxCharacters,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: AppTheme.textWhite,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type your response here...',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textMuted.withOpacity(0.5),
                                  ),
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Character Counter
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: _characterCount > _maxCharacters * 0.8
                                          ? AppTheme.warning.withOpacity(0.1)
                                          : AppTheme.primaryBlue.withOpacity(0.1),
                                    ),
                                    child: Text(
                                      '$_characterCount / $_maxCharacters',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _characterCount > _maxCharacters * 0.8
                                            ? AppTheme.warning
                                            : AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                  
                                  // Formatting Options
                                  Row(
                                    children: [
                                      _buildFormatButton(Icons.format_bold),
                                      const SizedBox(width: 8),
                                      _buildFormatButton(Icons.format_italic),
                                      const SizedBox(width: 8),
                                      _buildFormatButton(Icons.link),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          Navigator.pop(context);
                                        },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ||
                                          _responseController.text.trim().isEmpty
                                      ? null
                                      : _submitResponse,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: AppTheme.primaryBlue,
                                    disabledBackgroundColor:
                                        AppTheme.primaryBlue.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Send Response',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTemplateChip(String template) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _responseController.text = template;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          template.length > 30 
              ? '${template.substring(0, 30)}...'
              : template,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormatButton(IconData icon) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Handle formatting
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppTheme.glassDark.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
}