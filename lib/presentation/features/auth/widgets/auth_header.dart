import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20.r,
            left: -15.r,
            child: _Circle(size: 60.r),
          ),
          Positioned(
            bottom: 10.r,
            right: -25.r,
            child: _Circle(size: 60.r),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBackButton)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 4.w,
                    top: 4.h,
                  ) ,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(), 
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15)
                    ),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 18.r,
                      color: AppColors.textOnPrimary,
                    ),
                    tooltip: 'رجوع',
                    ),
                )
                else SizedBox(height: 16.h,),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                        ),
                        ),
                        if(subtitle != null)...[
                          SizedBox(height: 8.h,),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14.sp,
                              color: AppColors.textOnPrimary.withValues(alpha: 0.8)
                            ),
                          )
                        ],
                        SizedBox(height: 12.h,),
                        Container(
                          width: 32.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        )
                    ],
                  ), 
                )
              ],
            )
            )
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  const _Circle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07)
      ),
    );
  }
}
