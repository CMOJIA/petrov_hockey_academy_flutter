import 'package:formz/formz.dart';

enum InputVideoTitleValidationError {
  /// Generic invalid error.
  invalid
}

class InputVideoTitle
    extends FormzInput<String, InputVideoTitleValidationError> {
  const InputVideoTitle.pure() : super.pure('');

  const InputVideoTitle.dirty([super.value = '']) : super.dirty();
  static final _inputDataRegExp = RegExp(r'^[а-яА-Яa-zA-Z0-9 ]{3,}$');

  @override
  InputVideoTitleValidationError? validator(String? value) {
    return _inputDataRegExp.hasMatch(value ?? '')
        ? null
        : InputVideoTitleValidationError.invalid;
  }
}
