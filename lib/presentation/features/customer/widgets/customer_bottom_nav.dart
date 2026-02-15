import 'dart:math' as math;
import 'dart:ui';

import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart';
import 'package:baladi/presentation/cubits/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomerBottomNav extends StatefulWidget {
  final int currentIndex;
  const CustomerBottomNav({super.key, required this.currentIndex});

  @override
  State<CustomerBottomNav> createState() => _CustomerBottomNavState();
}

class _CustomerBottomNavState extends State<CustomerBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _glowPulseController;
  late AnimationController _waveController;
  late AnimationController _selectController;
  
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowPulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    // Floating animation - subtle up/down movement
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _floatingAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    // Glow pulse animation
    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    
    _glowPulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );
    
    // Wave animation for background effect
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
    
    // Selection animation
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _glowPulseController.dispose();
    _waveController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    _selectController.forward(from: 0);
    _navigateTo(context, index);
  }

  void _navigateTo(BuildContext context, int index) {
    final routeName = switch (index) {
      0 => RouteNames.customerHome,
      1 => RouteNames.ordersHistory,
      2 => RouteNames.cart,
      3 => RouteNames.customerProfile,
      _ => RouteNames.customerHome,
    };
    context.goNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _glowPulseAnimation]),
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
          child: Transform.translate(
            offset: Offset(0, -_floatingAnimation.value),
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  // Main shadow
                  BoxShadow(
                    color: const Color(0xFF0A1628).withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 0,
                  ),
                  // Colored glow
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15 * _glowPulseAnimation.value),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.85),
                          const Color(0xFFF8FAFC).withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated wave background
                        AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, _) {
                            return CustomPaint(
                              size: Size(double.infinity, 80.h),
                              painter: _WaveBackgroundPainter(
                                progress: _waveAnimation.value,
                                selectedIndex: widget.currentIndex,
                              ),
                            );
                          },
                        ),
                        // Navigation items
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ModernNavItem(
                                icon: Icons.home_rounded,
                                outlinedIcon: Icons.home_outlined,
                                label: 'الرئيسية',
                                isSelected: widget.currentIndex == 0,
                                onTap: () => _onItemTapped(0),
                                glowIntensity: _glowPulseAnimation.value,
                                color: const Color(0xFF10B981),
                              ),
                              _ModernNavItem(
                                icon: Icons.receipt_long_rounded,
                                outlinedIcon: Icons.receipt_long_outlined,
                                label: 'طلباتي',
                                isSelected: widget.currentIndex == 1,
                                onTap: () => _onItemTapped(1),
                                glowIntensity: _glowPulseAnimation.value,
                                color: const Color(0xFF6366F1),
                              ),
                              _CartNavItem(
                                isSelected: widget.currentIndex == 2,
                                onTap: () => _onItemTapped(2),
                                glowIntensity: _glowPulseAnimation.value,
                              ),
                              _ModernNavItem(
                                icon: Icons.person_rounded,
                                outlinedIcon: Icons.person_outline_rounded,
                                label: 'حسابي',
                                isSelected: widget.currentIndex == 3,
                                onTap: () => _onItemTapped(3),
                                glowIntensity: _glowPulseAnimation.value,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ],
                          ),
                        ),
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
}

class _ModernNavItem extends StatefulWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double glowIntensity;
  final Color color;

  const _ModernNavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.glowIntensity,
    required this.color,
  });

  @override
  State<_ModernNavItem> createState() => _ModernNavItemState();
}

class _ModernNavItemState extends State<_ModernNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isSelected ? 16.w : 12.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.15),
                          widget.color.withOpacity(0.05),
                        ],
                      )
                    : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.2 * widget.glowIntensity),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with effects
                  SizedBox(
                    height: 38.r,
                    width: 38.r,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow ring for selected
                        if (widget.isSelected)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            builder: (context, value, _) {
                              return Container(
                                width: 36.r * value,
                                height: 36.r * value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: widget.color.withOpacity(0.3 * widget.glowIntensity),
                                    width: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        // Icon
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: widget.isSelected ? 1 : 0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          builder: (context, value, _) {
                            return Transform.scale(
                              scale: 1 + (value * 0.1),
                              child: Container(
                                padding: EdgeInsets.all(widget.isSelected ? 6.r : 0),
                                decoration: widget.isSelected
                                    ? BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            widget.color,
                                            widget.color.withOpacity(0.7),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.color.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      )
                                    : null,
                                child: Icon(
                                  widget.isSelected ? widget.icon : widget.outlinedIcon,
                                  color: widget.isSelected
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  size: widget.isSelected ? 18.r : 22.r,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: widget.isSelected ? 10.sp : 9.sp,
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isSelected
                          ? widget.color
                          : const Color(0xFF94A3B8),
                    ),
                    child: Text(widget.label),
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

class _CartNavItem extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final double glowIntensity;

  const _CartNavItem({
    required this.isSelected,
    required this.onTap,
    required this.glowIntensity,
  });

  @override
  State<_CartNavItem> createState() => _CartNavItemState();
}

class _CartNavItemState extends State<_CartNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) => _bounceController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFD4A574);
    
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? _bounceAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isSelected ? 14.w : 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.r),
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.08),
                        ],
                      )
                    : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.25 * widget.glowIntensity),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cart icon with badge
                  SizedBox(
                    height: 42.r,
                    width: 42.r,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        if (widget.isSelected)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            builder: (context, value, _) {
                              return Container(
                                width: 40.r * value,
                                height: 40.r * value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color.withOpacity(0.4 * widget.glowIntensity),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        // Main icon container
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: widget.isSelected ? 1 : 0),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          builder: (context, value, _) {
                            return Transform.scale(
                              scale: 1 + (value * 0.08),
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: widget.isSelected
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            color,
                                            color.withOpacity(0.75),
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFFF1F5F9),
                                            const Color(0xFFE2E8F0),
                                          ],
                                        ),
                                  boxShadow: widget.isSelected
                                      ? [
                                          BoxShadow(
                                            color: color.withOpacity(0.5),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Icon(
                                  widget.isSelected
                                      ? Icons.shopping_bag_rounded
                                      : Icons.shopping_bag_outlined,
                                  color: widget.isSelected
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  size: 18.r,
                                ),
                              ),
                            );
                          },
                        ),
                        // Badge
                        BlocBuilder<CartCubit, CartState>(
                          builder: (context, state) {
                            final count = state is CartLoaded ? state.totalItems : 0;
                            if (count == 0) return const SizedBox.shrink();
                            return Positioned(
                              top: -4.r,
                              right: -4.r,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                                builder: (context, value, _) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFEF4444),
                                            Color(0xFFDC2626),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFEF4444).withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      constraints: BoxConstraints(minWidth: 16.r),
                                      child: Text(
                                        count > 99 ? "99+" : "$count",
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: widget.isSelected ? 10.sp : 9.sp,
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: widget.isSelected ? color : const Color(0xFF94A3B8),
                    ),
                    child: const Text("السلة"),
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

/// Wave background painter for subtle animated effect
class _WaveBackgroundPainter extends CustomPainter {
  final double progress;
  final int selectedIndex;

  _WaveBackgroundPainter({
    required this.progress,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFF6366F1),
      const Color(0xFFD4A574),
      const Color(0xFF8B5CF6),
    ];
    
    final selectedColor = colors[selectedIndex];
    
    // Draw subtle gradient waves
    final path = Path();
    final waveHeight = 3.0;
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height - 10 + 
          math.sin((x / size.width * 4 * math.pi) + progress) * waveHeight +
          math.sin((x / size.width * 2 * math.pi) + progress * 0.5) * waveHeight * 0.5;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          selectedColor.withOpacity(0.03),
          selectedColor.withOpacity(0.08),
          selectedColor.withOpacity(0.03),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
