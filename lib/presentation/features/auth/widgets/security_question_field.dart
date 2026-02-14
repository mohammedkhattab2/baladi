// Presentation - Security question dropdown + answer field.
//
// Reused in registration and (if needed) in profile settings.
// Styled consistently with AppTextField.

import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/security_questions.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// A security question dropdown paired with an answer text field.
///
/// ```dart
/// SecurityQuestionField(
///   selectedQuestion: _selectedQuestion,
///   answerController: _answerController,
///   onQuestionChanged: (q) => setState(() => _selectedQuestion = q),
/// )
/// ```
class SecurityQuestionField extends StatelessWidget {
  /// Currently selected question (null = none selected).
  final String? selectedQuestion;

  /// Called when the user selects a question.
  final ValueChanged<String?> onQuestionChanged;

  /// Controller for the answer text field.
  final TextEditingController answerController;

  /// Focus node for the answer field.
  final FocusNode? answerFocusNode;

  /// Text input action for the answer field.
  final TextInputAction answerTextInputAction;

  /// Called when the answer field is submitted.
  final ValueChanged<String>? onAnswerSubmitted;

  /// Server-side error for the question field.
  final String? questionError;

  /// Server-side error for the answer field.
  final String? answerError;

  const SecurityQuestionField({
    super.key,
    required this.selectedQuestion,
    required this.onQuestionChanged,
    required this.answerController,
    this.answerFocusNode,
    this.answerTextInputAction = TextInputAction.next,
    this.onAnswerSubmitted,
    this.questionError,
    this.answerError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Dropdown ─────────────────────────────────────
        Text(
          'سؤال الأمان',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        DropdownButtonFormField<String>(
          value: selectedQuestion,
          onChanged: onQuestionChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            prefixIcon: Icon(
              Icons.shield_outlined,
              color: AppColors.textSecondary,
              size: 22.r,
            ),
            hintText: 'اختر سؤال الأمان',
            hintStyle: AppTextStyles.hint,
            errorText: questionError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
          ),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 24.r,
          ),
          isExpanded: true,
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'اختر سؤال الأمان';
            }
            return null;
          },
          items: SecurityQuestions.questions.map((question) {
            return DropdownMenuItem<String>(
              value: question,
              child: Text(
                question,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),

        // ─── Answer Field ─────────────────────────────────
        AppTextField(
          label: 'إجابة سؤال الأمان',
          hint: 'أدخل إجابتك',
          controller: answerController,
          focusNode: answerFocusNode,
          prefixIcon: Icons.key_outlined,
          textInputAction: answerTextInputAction,
          validator: _validateAnswer,
          errorText: answerError,
          onFieldSubmitted: onAnswerSubmitted,
        ),
      ],
    );
  }

  String? _validateAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'إجابة سؤال الأمان مطلوبة';
    }
    if (value.trim().length < 2) {
      return 'الإجابة يجب أن تكون حرفين على الأقل';
    }
    return null;
  }
}