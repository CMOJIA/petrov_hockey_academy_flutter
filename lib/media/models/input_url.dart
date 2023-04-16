import 'package:formz/formz.dart';

enum InputUrlValidationError {
  /// Generic invalid error.
  invalid
}

class InputUrl extends FormzInput<String, InputUrlValidationError> {
  const InputUrl.pure() : super.pure('');

  const InputUrl.dirty([super.value = '']) : super.dirty();
  // Загрузка видео доступна только из некоторых источников, проверяю сссылку по домену.
  static final _inputDataRegExp = RegExp(
    'https://vk.com/video|https://youtu.be/|https://rutube.ru/video/|https://vimeo.com/|https://www.youtube.com/watch',
  );

  @override
  InputUrlValidationError? validator(String? value) {
    return _inputDataRegExp.hasMatch(value ?? '')
        ? null
        : InputUrlValidationError.invalid;
  }
}
