import 'package:formz/formz.dart';

enum InputDataValidationError {
  /// Generic invalid error.
  invalid
}

class InputData extends FormzInput<String, InputDataValidationError> {
  const InputData.pure() : super.pure('');

  /// {@macro InputData}
  const InputData.dirty([super.value = '']) : super.dirty();
  static final _inputDataRegExp =
      RegExp(r'^[а-яА-Я]{2,}$|^[a-zA-Z]{2,}$|^((7){1}([0-9() -]){16})$');

  @override
  InputDataValidationError? validator(String? value) {
    return _inputDataRegExp.hasMatch(value ?? '')
        ? null
        : InputDataValidationError.invalid;
  }
}
