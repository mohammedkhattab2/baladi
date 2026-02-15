import 'dart:math' as math;
import 'dart:ui';

import 'package:baladi/core/constants/storage_keys.dart';
import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/services/local_storage_service.dart';
import 'package:baladi/core/services/secure_storage_service.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/extensions.dart';
import 'package:baladi/core/utils/validators.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Luxury Customer Login Screen with magical animations and glowing effects
class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();

  Map<String, String>? _fieldErrors;
  bool _rememberMe = false;
  bool _obscurePin = true;

  final _localStorage = getIt<LocalStorageService>();
  final _secureStorage = getIt<SecureStorageService>();

  // Animation controllers
  late AnimationController _backgroundController;
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  // Animations
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;
  late Animation<double> _formSlide;
  late Animation<double> _formFade;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRememberedCredentials();
  }

  void _initAnimations() {
    // Background gradient animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Entrance animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Pulse animation for glow effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Floating particles animation
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Header animations
    _headerSlide = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Form animations
    _formSlide = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    // Button animation
    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.9, curve: Curves.elasticOut),
      ),
    );

    // Start entrance animation
    _entranceController.forward();
  }

  Future<void> _loadRememberedCredentials() async {
    final remembered = await _localStorage.getBool(StorageKeys.rememberMe);
    if (remembered == true) {
      final phone = await _localStorage.getString(StorageKeys.rememberedPhone);
      final pin = await _secureStorage.getUserPin();
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
      if (pin != null && pin.isNotEmpty) {
        _pinController.text = pin;
      }
      setState(() => _rememberMe = true);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    _backgroundController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext blocContext) {
    setState(() => _fieldErrors = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(blocContext).unfocus();

    blocContext.read<AuthCubit>().loginCustomer(
          phone: _phoneController.text.trim(),
          pin: _pinController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _onAuthStateChanged,
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Scaffold(
            body: Stack(
              children: [
                // Animated gradient background
                _AnimatedGradientBackground(controller: _backgroundController),
                // Floating particles
                _FloatingParticles(
                  controller: _floatingController,
                  pulseController: _pulseController,
                ),
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Luxury Header
                            Transform.translate(
                              offset: Offset(0, _headerSlide.value),
                              child: Opacity(
                                opacity: _headerFade.value,
                                child: _LuxuryHeader(
                                  pulseController: _pulseController,
                                  onBack: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            // Form Container
                            Transform.translate(
                              offset: Offset(0, _formSlide.value),
                              child: Opacity(
                                opacity: _formFade.value,
                                child: _GlassmorphicFormContainer(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Phone field
                                        _LuxuryTextField(
                                          controller: _phoneController,
                                          focusNode: _phoneFocus,
                                          label: 'رقم الهاتف',
                                          hint: '01xxxxxxxxx',
                                          prefixIcon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 11,
                                          validator: Validators.validatePhone,
                                          errorText: _fieldErrors?["phone"],
                                          onFieldSubmitted: (_) =>
                                              _pinFocus.requestFocus(),
                                          pulseController: _pulseController,
                                        ),
                                        SizedBox(height: 20.h),
                                        // PIN field
                                        _LuxuryTextField(
                                          controller: _pinController,
                                          focusNode: _pinFocus,
                                          label: 'رمز الدخول',
                                          hint: '••••',
                                          prefixIcon: Icons.lock_outlined,
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                          obscureText: _obscurePin,
                                          validator: Validators.validatePin,
                                          errorText: _fieldErrors?["pin"],
                                          onFieldSubmitted: (_) =>
                                              _handleLogin(context),
                                          pulseController: _pulseController,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePin
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.white70,
                                              size: 22.r,
                                            ),
                                            onPressed: () => setState(
                                                () => _obscurePin = !_obscurePin),
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        // Remember me & Forgot PIN
                                        _RememberMeRow(
                                          rememberMe: _rememberMe,
                                          onRememberMeChanged: (value) =>
                                              setState(
                                                  () => _rememberMe = value),
                                          onForgotPin: () => context
                                              .pushNamed(RouteNames.pinRecovery),
                                        ),
                                        SizedBox(height: 28.h),
                                        // Login button
                                        Transform.scale(
                                          scale: _buttonScale.value,
                                          child: _GlowingButton(
                                            text: 'تسجيل الدخول',
                                            icon: Icons.login_rounded,
                                            isLoading: isLoading,
                                            onPressed: isLoading
                                                ? null
                                                : () => _handleLogin(context),
                                            pulseController: _pulseController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Or divider
                            Opacity(
                              opacity: _formFade.value,
                              child: const _LuxuryOrDivider(),
                            ),
                            SizedBox(height: 24.h),
                            // Register link
                            Opacity(
                              opacity: _formFade.value,
                              child: _RegisterLink(
                                onTap: () =>
                                    context.pushNamed(RouteNames.customerRegister),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black45,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Center(
                        child: _GlowingLoader(pulseController: _pulseController),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveRememberMePreference() async {
    if (_rememberMe) {
      await _localStorage.setBool(StorageKeys.rememberMe, true);
      await _localStorage.setString(
        StorageKeys.rememberedPhone,
        _phoneController.text.trim(),
      );
      await _secureStorage.setUserPin(_pinController.text.trim());
    } else {
      await _localStorage.setBool(StorageKeys.rememberMe, false);
      await _localStorage.remove(StorageKeys.rememberedPhone);
    }
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _saveRememberMePreference();
      context.goNamed(RouteNames.customerHome);
    } else if (state is AuthError) {
      if (state.fieldErrors != null && state.fieldErrors!.isNotEmpty) {
        setState(() => _fieldErrors = state.fieldErrors);
      } else {
        context.showErrorSnackBar(state.message);
      }
    }
  }
}

/// Animated gradient background
class _AnimatedGradientBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedGradientBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _interpolateColor(controller.value, 0),
                _interpolateColor(controller.value, 0.33),
                _interpolateColor(controller.value, 0.66),
                _interpolateColor(controller.value, 1.0),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }

  Color _interpolateColor(double t, double offset) {
    final colors = [
      const Color(0xFF0D1B2A),
      const Color(0xFF1B263B),
      const Color(0xFF2D5A27),
      const Color(0xFF1A3A16),
      const Color(0xFF0D1B2A),
    ];

    final adjustedT = (t + offset) % 1.0;
    final index = (adjustedT * (colors.length - 1)).floor();
    final localT = (adjustedT * (colors.length - 1)) - index;

    return Color.lerp(
        colors[index], colors[(index + 1) % colors.length], localT)!;
  }
}

/// Floating particles with glow effects
class _FloatingParticles extends StatelessWidget {
  final AnimationController controller;
  final AnimationController pulseController;

  const _FloatingParticles({
    required this.controller,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, pulseController]),
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlesPainter(
            animationValue: controller.value,
            pulseValue: pulseController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double animationValue;
  final double pulseValue;
  final List<_Particle> particles;

  _ParticlesPainter({
    required this.animationValue,
    required this.pulseValue,
  }) : particles = _generateParticles();

  static List<_Particle> _generateParticles() {
    final random = math.Random(42);
    return List.generate(20, (index) {
      return _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1.5,
        speed: random.nextDouble() * 0.3 + 0.1,
        opacity: random.nextDouble() * 0.4 + 0.15,
        color: index % 3 == 0
            ? const Color(0xFF4A7C43)
            : index % 3 == 1
                ? const Color(0xFFD4A574)
                : const Color(0xFF6BB3F0),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = (particle.x * size.width +
              animationValue * particle.speed * size.width) %
          size.width;
      final y = (particle.y * size.height -
              animationValue * particle.speed * size.height * 0.5) %
          size.height;

      final glowSize = particle.size * (1 + pulseValue * 0.3);

      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSize * 3);
      canvas.drawCircle(Offset(x, y), glowSize * 2, glowPaint);

      final corePaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSize * 0.5);
      canvas.drawCircle(Offset(x, y), glowSize, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pulseValue != pulseValue;
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

/// Luxury header with glowing effects
class _LuxuryHeader extends StatelessWidget {
  final AnimationController pulseController;
  final VoidCallback onBack;

  const _LuxuryHeader({
    required this.pulseController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          _GlowingBackButton(
            onTap: onBack,
            pulseController: pulseController,
          ),
          SizedBox(height: 24.h),
          // Title section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome text with shimmer
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.secondary,
                      Colors.white,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'مرحباً بعودتك',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'أدخل رقم هاتفك ورمز الدخول',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15.sp,
                    color: Colors.white.withOpacity(0.8),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Decorative line with glow
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    final pulseValue = 0.8 + pulseController.value * 0.4;
                    return Container(
                      width: 50.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.r),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withOpacity(0.5),
                            AppColors.secondary,
                            AppColors.secondary.withOpacity(0.5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.secondary.withOpacity(0.6 * pulseValue),
                            blurRadius: 15 * pulseValue,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Glowing back button
class _GlowingBackButton extends StatefulWidget {
  final VoidCallback onTap;
  final AnimationController pulseController;

  const _GlowingBackButton({
    required this.onTap,
    required this.pulseController,
  });

  @override
  State<_GlowingBackButton> createState() => _GlowingBackButtonState();
}

class _GlowingBackButtonState extends State<_GlowingBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: widget.pulseController,
        builder: (context, child) {
          final pulseValue = 0.8 + widget.pulseController.value * 0.4;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(_isPressed ? 0.25 : 0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3 * pulseValue),
                  blurRadius: 15 * pulseValue,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.r,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

/// Glassmorphic form container
class _GlassmorphicFormContainer extends StatelessWidget {
  final Widget child;

  const _GlassmorphicFormContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Luxury text field with glow effects
class _LuxuryTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final int maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String>? onFieldSubmitted;
  final AnimationController pulseController;
  final Widget? suffixIcon;

  const _LuxuryTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.keyboardType,
    required this.maxLength,
    this.obscureText = false,
    this.validator,
    this.errorText,
    this.onFieldSubmitted,
    required this.pulseController,
    this.suffixIcon,
  });

  @override
  State<_LuxuryTextField> createState() => _LuxuryTextFieldState();
}

class _LuxuryTextFieldState extends State<_LuxuryTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Text field
        AnimatedBuilder(
          animation: widget.pulseController,
          builder: (context, child) {
            final pulseValue = 0.8 + widget.pulseController.value * 0.4;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4 * pulseValue),
                          blurRadius: 20 * pulseValue,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                maxLength: widget.maxLength,
                validator: widget.validator,
                onFieldSubmitted: widget.onFieldSubmitted,
                textAlign: widget.obscureText ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  errorText: widget.errorText,
                  errorStyle: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.error,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white.withOpacity(_isFocused ? 0.15 : 0.1),
                  prefixIcon: Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppColors.secondary
                        : Colors.white.withOpacity(0.6),
                    size: 22.r,
                  ),
                  suffixIcon: widget.suffixIcon,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: AppColors.secondary.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: AppColors.error.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(
                      color: AppColors.error,
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Remember me row with styled checkbox
class _RememberMeRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPin;

  const _RememberMeRow({
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Custom checkbox
        GestureDetector(
          onTap: () => onRememberMeChanged(!rememberMe),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24.r,
            height: 24.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              color: rememberMe
                  ? AppColors.primary.withOpacity(0.8)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: rememberMe
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: rememberMe
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: rememberMe
                ? Icon(
                    Icons.check_rounded,
                    size: 16.r,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: () => onRememberMeChanged(!rememberMe),
          child: Text(
            'تذكرني',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        const Spacer(),
        // Forgot PIN link
        GestureDetector(
          onTap: onForgotPin,
          child: Text(
            'نسيت رمز الدخول؟',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.sp,
              color: AppColors.secondary,
              shadows: [
                Shadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Glowing button with animation
class _GlowingButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final AnimationController pulseController;

  const _GlowingButton({
    required this.text,
    required this.icon,
    required this.isLoading,
    this.onPressed,
    required this.pulseController,
  });

  @override
  State<_GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<_GlowingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: widget.pulseController,
        builder: (context, child) {
          final pulseValue = 0.8 + widget.pulseController.value * 0.4;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 56.h,
            transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDisabled
                    ? [
                        AppColors.primary.withOpacity(0.5),
                        AppColors.primaryLight.withOpacity(0.5),
                      ]
                    : [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
              ),
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5 * pulseValue),
                        blurRadius: 25 * pulseValue,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2 * pulseValue),
                        blurRadius: 40 * pulseValue,
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 22.r,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          widget.text,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Luxury or divider
class _LuxuryOrDivider extends StatelessWidget {
  const _LuxuryOrDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'أو',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Register link with glow
class _RegisterLink extends StatelessWidget {
  final VoidCallback onTap;

  const _RegisterLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'سجل الآن',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              shadows: [
                Shadow(
                  color: AppColors.secondary.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Glowing loader
class _GlowingLoader extends StatelessWidget {
  final AnimationController pulseController;

  const _GlowingLoader({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseValue = 0.8 + pulseController.value * 0.4;
        return Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5 * pulseValue),
                blurRadius: 30 * pulseValue,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3 * pulseValue),
                blurRadius: 50 * pulseValue,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.surface.withOpacity(0.9),
                ],
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 40.r,
                height: 40.r,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
