import 'package:formz/formz.dart';

enum InputTitleValidationError {
  /// Generic invalid error.
  invalid
}

class InputAlbumTitle extends FormzInput<String, InputTitleValidationError> {
  const InputAlbumTitle.pure() : super.pure('');

  const InputAlbumTitle.dirty([super.value = '']) : super.dirty();
  static final _inputDataRegExp = RegExp(r'^[а-яА-Яa-zA-Z0-9 ]{3,}$');

  @override
  InputTitleValidationError? validator(String? value) {
    return _inputDataRegExp.hasMatch(value ?? '')
        ? null
        : InputTitleValidationError.invalid;
  }
}
