// Presentation - Common reusable text field widget for the Baladi design system.
//
// Provides a styled text input with validation support, optional icons,
// character counters, and RTL-aware layout for Arabic-first UX.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A design-system-consistent text field widget.
///
/// Wraps [TextFormField] with Baladi styling, validation, and
/// optional prefix/suffix icons, counters, and input formatters.
///
/// Example usage:
/// ```dart
/// AppTextField(
///   label: 'رقم الهاتف',
///   hint: '01xxxxxxxxx',
///   controller: _phoneController,
///   keyboardType: TextInputType.phone,
///   prefixIcon: Icons.phone,
///   validator: Validators.phone,
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// The label displayed above the input field.
  final String? label;

  /// Hint text displayed when the field is empty.
  final String? hint;

  /// The text editing controller.
  final TextEditingController? controller;

  /// The focus node for managing focus state.
  final FocusNode? focusNode;

  /// The keyboard type for the input.
  final TextInputType keyboardType;

  /// The text input action (e.g. next, done).
  final TextInputAction? textInputAction;

  /// Whether the field is obscured (for passwords/PINs).
  final bool obscureText;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Maximum number of lines for the input.
  final int maxLines;

  /// Minimum number of lines for the input.
  final int? minLines;

  /// Maximum character length.
  final int? maxLength;

  /// Optional prefix icon.
  final IconData? prefixIcon;

  /// Optional suffix icon.
  final IconData? suffixIcon;

  /// Called when the suffix icon is tapped.
  final VoidCallback? onSuffixTap;

  /// Optional suffix widget (overrides [suffixIcon]).
  final Widget? suffix;

  /// Optional prefix widget (overrides [prefixIcon]).
  final Widget? prefix;

  /// Validation function returning an error string or `null`.
  final String? Function(String?)? validator;

  /// Called when the field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the field is submitted (e.g. keyboard done).
  final ValueChanged<String>? onFieldSubmitted;

  /// Called when the field is tapped (useful for date pickers).
  final VoidCallback? onTap;

  /// Optional input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to auto-validate on every change.
  final AutovalidateMode autovalidateMode;

  /// Optional helper text displayed below the field.
  final String? helperText;

  /// Optional error text to force an error state.
  final String? errorText;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Text alignment within the field.
  final TextAlign textAlign;

  /// Whether to fill the background.
  final bool filled;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.suffix,
    this.prefix,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.helperText,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.filled = true,
  });

  /// Creates a phone number input field.
  const AppTextField.phone({
    super.key,
    this.label = 'رقم الهاتف',
    this.hint = '01xxxxxxxxx',
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.errorText,
  })  : keyboardType = TextInputType.phone,
        obscureText = false,
        readOnly = false,
        maxLines = 1,
        minLines = null,
        maxLength = 11,
        prefixIcon = Icons.phone_outlined,
        suffixIcon = null,
        onSuffixTap = null,
        suffix = null,
        prefix = null,
        onTap = null,
        inputFormatters = null,
        autovalidateMode = AutovalidateMode.onUserInteraction,
        helperText = null,
        textCapitalization = TextCapitalization.none,
        textAlign = TextAlign.start,
        filled = true;

  /// Creates a PIN input field.
  const AppTextField.pin({
    super.key,
    this.label = 'رمز الدخول',
    this.hint = '••••',
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.errorText,
  })  : keyboardType = TextInputType.number,
        obscureText = true,
        readOnly = false,
        maxLines = 1,
        minLines = null,
        maxLength = 6,
        prefixIcon = Icons.lock_outlined,
        suffixIcon = null,
        onSuffixTap = null,
        suffix = null,
        prefix = null,
        onTap = null,
        inputFormatters = null,
        autovalidateMode = AutovalidateMode.onUserInteraction,
        helperText = null,
        textCapitalization = TextCapitalization.none,
        textAlign = TextAlign.center,
        filled = true;

  /// Creates a multiline text area field.
  const AppTextField.textArea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.enabled = true,
    this.errorText,
  })  : keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        obscureText = false,
        readOnly = false,
        maxLines = 5,
        minLines = 3,
        prefixIcon = null,
        suffixIcon = null,
        onSuffixTap = null,
        suffix = null,
        prefix = null,
        onFieldSubmitted = null,
        onTap = null,
        inputFormatters = null,
        autovalidateMode = AutovalidateMode.onUserInteraction,
        helperText = null,
        textCapitalization = TextCapitalization.sentences,
        textAlign = TextAlign.start,
        filled = true;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Label ───────────────────────────────────────────────
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 8),
        ],

        // ─── Text Field ──────────────────────────────────────────
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscured,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autovalidateMode,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          style: AppTextStyles.bodyLarge.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: widget.filled,
            fillColor: widget.enabled
                ? AppColors.surfaceVariant
                : AppColors.surfaceVariant.withValues(alpha: 0.5),
            counterText: '',
            prefixIcon: _buildPrefixIcon(),
            suffixIcon: _buildSuffixIcon(),
            prefix: widget.prefix,
          ),
        ),
      ],
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon == null) return null;
    return Icon(
      widget.prefixIcon,
      color: AppColors.textSecondary,
      size: 22,
    );
  }

  Widget? _buildSuffixIcon() {
    // Toggle visibility for obscured fields
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    if (widget.suffix != null) return widget.suffix;

    if (widget.suffixIcon == null) return null;

    if (widget.onSuffixTap != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.textSecondary,
          size: 22,
        ),
        onPressed: widget.onSuffixTap,
      );
    }

    return Icon(
      widget.suffixIcon,
      color: AppColors.textSecondary,
      size: 22,
    );
  }
}

/// A search-specific text field with Baladi styling.
///
/// Example usage:
/// ```dart
/// AppSearchField(
///   hint: 'ابحث عن منتج...',
///   onChanged: (query) => _search(query),
/// )
/// ```
class AppSearchField extends StatelessWidget {
  /// Hint text for the search field.
  final String hint;

  /// The text editing controller.
  final TextEditingController? controller;

  /// Called when the search query changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search.
  final ValueChanged<String>? onSubmitted;

  /// Called when the clear button is pressed.
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.hint = 'بحث...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 22,
        ),
        suffixIcon: controller != null
            ? ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller!,
                builder: (_, value, child) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      controller!.clear();
                      onClear?.call();
                      onChanged?.call('');
                    },
                  );
                },
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}