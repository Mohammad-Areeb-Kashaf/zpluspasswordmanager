import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zpluspasswordmanager/core/theme/app_theme.dart';

enum AuthTextFieldWithLabelType {
  email,
  password,
  name,
  passPhrase,
  forgotEmail,
}

class AuthTextFieldWithLabel extends StatefulWidget {
  const AuthTextFieldWithLabel({
    super.key,
    this.controller,
    required this.authFieldType,
    required this.onSaved,
    required this.validator,
    required this.submit,
  });

  final AuthTextFieldWithLabelType authFieldType;
  final Function onSaved;
  final String? Function(String?)? validator;
  final Function? submit;
  final TextEditingController? controller;

  @override
  State<AuthTextFieldWithLabel> createState() => _AuthTextFieldWithLabelState();
}

class _AuthTextFieldWithLabelState extends State<AuthTextFieldWithLabel> {
  // Define focus nodes for each field
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  final textFormFieldKey =
      GlobalKey<FormFieldState<String>>(); // Key for the TextFormField

  FocusNode? _currentFocusNode; // Current field's FocusNode
  FocusNode? _nextFocusNode; // Next field's FocusNode
  bool _isPasswordVisible = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    // Assign the current and next focus nodes based on the authFieldType
    switch (widget.authFieldType) {
      case AuthTextFieldWithLabelType.name:
        _currentFocusNode = nameFocusNode;
        _nextFocusNode = emailFocusNode;
        break;
      case AuthTextFieldWithLabelType.email:
        _currentFocusNode = emailFocusNode;
        _nextFocusNode = passwordFocusNode;
        break;
      case AuthTextFieldWithLabelType.password:
        _currentFocusNode = passwordFocusNode;
        _nextFocusNode = null; // No next focus node for the last field
        break;
      default:
        _currentFocusNode = FocusNode();
        _nextFocusNode = null;
    }

    // Add a listener to update the focus state
    _currentFocusNode?.addListener(() {
      setState(() {
        _isFocused = _currentFocusNode!.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // Dispose all focus nodes to avoid memory leaks
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.0.sp),
            child: Text(
              widget.authFieldType == AuthTextFieldWithLabelType.email ||
                      widget.authFieldType ==
                          AuthTextFieldWithLabelType.forgotEmail
                  ? "EMAIL"
                  : widget.authFieldType == AuthTextFieldWithLabelType.password
                      ? "PASSWORD"
                      : widget.authFieldType == AuthTextFieldWithLabelType.name
                          ? "NAME"
                          : "PASSPHRASE",
              style: AppTheme().buttonTextStyle.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 10.sp,
                  ),
            ),
          ),
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              key: textFormFieldKey,
              focusNode:
                  _currentFocusNode, // Assign the current field's FocusNode
              validator: widget.validator,
              keyboardType: widget.authFieldType ==
                          AuthTextFieldWithLabelType.email ||
                      widget.authFieldType ==
                          AuthTextFieldWithLabelType.forgotEmail
                  ? TextInputType.emailAddress
                  : widget.authFieldType == AuthTextFieldWithLabelType.password
                      ? TextInputType.visiblePassword
                      : TextInputType.text,
              obscureText:
                  widget.authFieldType == AuthTextFieldWithLabelType.password &&
                      !_isPasswordVisible,
              decoration: InputDecoration(
                suffixIcon:
                    widget.authFieldType == AuthTextFieldWithLabelType.password
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: _isFocused
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          )
                        : null,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.sp,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.sp,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.sp,
                  ),
                ),
                hintText:
                    widget.authFieldType == AuthTextFieldWithLabelType.email ||
                            widget.authFieldType ==
                                AuthTextFieldWithLabelType.forgotEmail
                        ? "Email"
                        : widget.authFieldType ==
                                AuthTextFieldWithLabelType.password
                            ? "Password"
                            : widget.authFieldType ==
                                    AuthTextFieldWithLabelType.name
                                ? "Name"
                                : "Passphrase",
                hintStyle: AppTheme().smallTextStyle.copyWith(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                errorStyle: AppTheme().smallTextStyle.copyWith(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2.sp,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.sp),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2.sp,
                  ),
                ),
                errorMaxLines: 2,
              ),
              style: AppTheme().smallTextStyle.copyWith(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              onSaved: (value) => widget.onSaved(value),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: _nextFocusNode != null
                  ? TextInputAction.next
                  : TextInputAction
                      .done, // Show "Next" or "Done" on the keyboard
              onFieldSubmitted: (_) {
                // Validate the current field before moving to the next
                if (textFormFieldKey.currentState?.validate() ?? false) {
                  if (_nextFocusNode != null) {
                    FocusScope.of(context)
                        .nextFocus(); // Move to the next field
                  } else {
                    FocusScope.of(context).unfocus();
                    widget.submit?.call();
                  }
                } else {
                  // Keep focus on the current field if validation fails
                  FocusScope.of(context).requestFocus(_currentFocusNode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
