import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/users_list/users_list_bloc.dart';
import '../widgets/user_role_selector.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage>
    with TickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _glowController;
  
  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _glowAnimation;
  
  // State
  String? _selectedRole;
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  
  // Focus Nodes
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutBack,
    );
    
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    
    _formController.forward();
  }

  void _setupFocusListeners() {
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
    _phoneFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _glowController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Form Content
          _buildFormContent(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkBackground,
                AppTheme.darkBackground2.withOpacity(0.95),
                AppTheme.darkBackground3.withOpacity(0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated shapes
              ...List.generate(5, (index) {
                return Positioned(
                  top: 100.0 * index,
                  left: 50.0 * index,
                  child: Transform.rotate(
                    angle: _backgroundAnimation.value + (index * math.pi / 5),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryBlue.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              // Grid overlay
              CustomPaint(
                painter: _GridPainter(
                  color: AppTheme.primaryBlue.withOpacity(0.02),
                ),
                size: Size.infinite,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: AppDimensions.spaceLarge),
              
              // Form Card
              AnimatedBuilder(
                animation: _formAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _formAnimation.value,
                    child: Opacity(
                      opacity: _formAnimation.value,
                      child: _buildFormCard(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Back Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.7),
                  AppTheme.darkCard.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        
        const SizedBox(width: AppDimensions.spaceMedium),
        
        // Title
        Expanded(
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  AppTheme.primaryCyan,
                  AppTheme.primaryBlue,
                  AppTheme.primaryPurple,
                ],
              ).createShader(bounds);
            },
            child: Text(
              'إضافة مستخدم جديد',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.7),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Header
                  _buildFormHeader(),
                  
                  const SizedBox(height: AppDimensions.spaceLarge),
                  
                  // Name Field
                  _buildFuturisticTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    label: 'الاسم الكامل',
                    icon: Icons.person_rounded,
                    validator: Validators.validateName,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                  ),
                  
                  const SizedBox(height: AppDimensions.spaceMedium),
                  
                  // Email Field
                  _buildFuturisticTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  
                  const SizedBox(height: AppDimensions.spaceMedium),
                  
                  // Password Field
                  _buildFuturisticTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: 'كلمة المرور',
                    icon: Icons.lock_rounded,
                    obscureText: !_isPasswordVisible,
                    validator: Validators.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneFocus);
                    },
                  ),
                  
                  const SizedBox(height: AppDimensions.spaceMedium),
                  
                  // Phone Field
                  _buildFuturisticTextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  
                  const SizedBox(height: AppDimensions.spaceMedium),
                  
                  // Role Selector
                  _buildRoleSelector(),
                  
                  const SizedBox(height: AppDimensions.spaceLarge),
                  
                  // Submit Button
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Center(
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.2 * _glowAnimation.value),
                  AppTheme.primaryPurple.withOpacity(0.1 * _glowAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFuturisticTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Function(String)? onFieldSubmitted,
  }) {
    final isFocused = focusNode.hasFocus;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isFocused
                ? AppTheme.primaryBlue.withOpacity(0.1)
                : AppTheme.darkSurface.withOpacity(0.6),
            isFocused
                ? AppTheme.primaryPurple.withOpacity(0.05)
                : AppTheme.darkSurface.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: isFocused
              ? AppTheme.primaryBlue.withOpacity(0.5)
              : AppTheme.darkBorder.withOpacity(0.3),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: isFocused
                ? AppTheme.primaryBlue
                : AppTheme.textMuted,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isFocused
                  ? AppTheme.primaryGradient
                  : null,
              color: !isFocused
                  ? AppTheme.textMuted.withOpacity(0.3)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showRoleSelector();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkSurface.withOpacity(0.6),
              AppTheme.darkSurface.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: _selectedRole != null
                ? AppTheme.primaryBlue.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _selectedRole != null
                    ? AppTheme.primaryGradient
                    : null,
                color: _selectedRole == null
                    ? AppTheme.textMuted.withOpacity(0.3)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.security_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMedium),
            Expanded(
              child: Text(
                _selectedRole != null
                    ? _getRoleText(_selectedRole!)
                    : 'اختر الدور',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _selectedRole != null
                      ? AppTheme.textWhite
                      : AppTheme.textMuted,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(
                  0.3 + 0.2 * _glowAnimation.value,
                ),
                blurRadius: 20 + 10 * _glowAnimation.value,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppDimensions.spaceSmall),
                      Text(
                        'إنشاء المستخدم',
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _showRoleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => UserRoleSelector(
        currentRole: _selectedRole,
        onRoleSelected: (roleId) {
          setState(() {
            _selectedRole = roleId;
          });
        },
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى اختيار دور المستخدم'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      // TODO: Implement actual user creation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إنشاء المستخدم بنجاح'),
              backgroundColor: AppTheme.success,
            ),
          );
          
          context.pop();
        }
      });
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'مدير';
      case 'owner':
        return 'مالك';
      case 'staff':
        return 'موظف';
      case 'customer':
        return 'عميل';
      default:
        return role;
    }
  }
}

// Custom Grid Painter
class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 50.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}