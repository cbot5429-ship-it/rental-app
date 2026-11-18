import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// A consistent text field with label, hint, prefix/suffix icons, and validation
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final AutovalidateMode autovalidateMode;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.focusNode,
    this.autofillHints,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autovalidateMode: autovalidateMode,
      autofillHints: autofillHints,
      autofocus: autofocus,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        prefix: prefix,
        suffixIcon: suffixIcon,
        suffix: suffix,
        counterText: maxLength != null ? '' : null,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      ),
    );
  }
}

/// Search field with clear button and filter action
class AppSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final int filterCount;
  final bool autofocus;

  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted,
    this.onChanged,
    this.onFilterTap,
    this.showFilter = true,
    this.filterCount = 0,
    this.autofocus = false,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    // The clear button depends on the controller's text, which changes without
    // this widget rebuilding (typing, programmatic clear).
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChange);
      widget.controller.addListener(_handleTextChange);
    }
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The TextField owns _focusNode; wrapping it in a Focus with the same node
    // re-parents the node into itself and throws at build time.
    return AnimatedContainer(
        duration: AppDuration.fast,
        curve: AppCurves.standard,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _hasFocus ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: _hasFocus
              ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 22),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSubmitted,
                onChanged: widget.onChanged,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  isDense: true,
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: theme.colorScheme.onSurfaceVariant, size: 20),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged?.call('');
                  _focusNode.requestFocus();
                },
                splashRadius: 20,
              ),
            if (widget.showFilter)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onFilterTap,
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: widget.filterCount > 0
                            ? theme.colorScheme.primaryContainer
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.tune,
                            color: widget.filterCount > 0
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          if (widget.filterCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  widget.filterCount.toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onError,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
    );
  }
}

/// Password field with visibility toggle
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;
  final IconData? prefixIcon;
  final Iterable<String>? autofillHints;

  const AppPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.prefixIcon,
    this.autofillHints,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon ?? Icons.lock_outline,
      obscureText: _obscure,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      suffixIcon: IconButton(
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
        onPressed: () => setState(() => _obscure = !_obscure),
        splashRadius: 20,
      ),
    );
  }
}

/// OTP input field
class AppOtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final Duration? autoFocusDelay;
  final Iterable<String>? autofillHints;

  const AppOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autoFocusDelay,
    this.autofillHints,
  });

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  late List<TextEditingController> _controllers;
  late TextInputType _keyboardType;
  late List<FocusNode> _focusNodes;
  String _code = '';

  @override
  void initState() {
    super.initState();
    _keyboardType = widget.autofillHints?.contains(AutofillHints.oneTimeCode) ?? false
        ? TextInputType.number
        : TextInputType.text;
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _updateCode();
  }

  void _updateCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code != _code) {
      _code = code;
      widget.onChanged?.call(code);
      if (code.length == widget.length) {
        widget.onCompleted?.call(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 48,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: _keyboardType,
            maxLength: 1,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: theme.dividerColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            onChanged: (v) => _onChanged(v, index),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        );
      }),
    );
  }
}