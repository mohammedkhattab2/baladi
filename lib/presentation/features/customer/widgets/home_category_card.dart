import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeCategoryCard extends StatelessWidget {
  final Category category;
  const HomeCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final cardColor = _parseColor(category.color) ?? AppColors.primary;
    
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.categoryShops,
        pathParameters: {"slug": category.slug},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: cardColor.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF0A1628).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cardColor.withOpacity(0.08),
                      cardColor.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
              ),
            ),
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor.withOpacity(0.15),
                        cardColor.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: cardColor.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(child: _buildIcon(cardColor)),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    category.nameAr,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A1628),
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return null;
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }

  Widget _buildIcon(Color color) {
    if (category.icon != null && category.icon!.isNotEmpty) {
      if (category.icon!.codeUnits.first > 255) {
        return Text(category.icon!, style: TextStyle(fontSize: 28.sp));
      }
    }
    final iconData = _getCategoryIcon(category.slug);
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withOpacity(0.7),
        ],
      ).createShader(bounds),
      child: Icon(iconData, color: Colors.white, size: 28.r),
    );
  }

  IconData _getCategoryIcon(String slug) {
    return switch (slug.toLowerCase()) {
      'restaurants' || 'مطاعم' => Icons.restaurant_rounded,
      'bakeries' || 'مخابز' => Icons.bakery_dining_rounded,
      'pharmacies' || 'صيدليات' => Icons.local_pharmacy_rounded,
      'beauty' || 'تجميل' => Icons.face_rounded,
      'groceries' || 'بقالة' => Icons.local_grocery_store_rounded,
      'electronics' || 'إلكترونيات' => Icons.devices_rounded,
      'clothes' || 'ملابس' => Icons.checkroom_rounded,
      'home' || 'منزل' => Icons.home_rounded,
      _ => Icons.category_rounded,
    };
  }
}
