import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  const HomeSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
          )
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppColors.textHint,
              size: 22.r,
            ),
            SizedBox(width: 12.w,),
            Expanded(
              child: Text(
                "ابحث عن متجر أو منتج...",
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                  color: AppColors.textHint,
                ),
              ) 
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 18.r,
                  ),
                  
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}