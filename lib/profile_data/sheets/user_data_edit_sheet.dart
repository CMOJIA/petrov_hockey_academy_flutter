import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';

// Форма в виде ModalBottomSheet для редактирования пользовательских данных:
// ФИО и номер телефона
void editUserData(
  BuildContext context,
  String dataName,
  InputDataType inputDataType,
) {
  showModalBottomSheet<void>(
    isScrollControlled: true,
    context: context,
    builder: (_) {
      // Выбирается редактирование какого поля открыли
      final String _hintText;
      switch (inputDataType) {
        case InputDataType.firstname:
          _hintText =
              context.watch<ProfileDataBloc>().state.profileData.firstName;
          break;
        case InputDataType.middlename:
          _hintText =
              context.watch<ProfileDataBloc>().state.profileData.middleName;
          break;
        case InputDataType.lastname:
          _hintText =
              context.watch<ProfileDataBloc>().state.profileData.lastName;
          break;
        case InputDataType.phoneNumber:
          _hintText = '7 (123) 456-78-90';
          break;
      }
      return BlocProvider.value(
        value: BlocProvider.of<ProfileDataBloc>(context),
        child: BlocListener<ProfileDataBloc, ProfileDataState>(
          listener: (context, state) {
            if (state.formzStatus.isSubmissionSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    margin: const EdgeInsets.all(4),
                    content: Text(
                      dataName == 'имя'
                          ? 'Имя успешно изменено.'
                          : dataName == 'отчестсво'
                              ? 'Отчество успешно изменено.'
                              : dataName == 'фамилия'
                                  ? 'Фамилия успешно изменена.'
                                  : 'Номер телефона успешно изменен',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
            }
            if (state.formzStatus.isSubmissionFailure) {
              // Если редактирование закончилось ошибкой - появлляется диалоговое окно
              warningDialog(
                context: context,
                title: 'Ошибка',
                content:
                    'Не удалось сохранить изменения. Проверьте подключение к интернету или попробуйте позже.',
              );
            }
          },
          child: BlocBuilder<ProfileDataBloc, ProfileDataState>(
            buildWhen: (previous, current) =>
                previous.formzStatus != current.formzStatus,
            builder: (context, state) {
              return SheetProfileDataContent(
                dataName: dataName,
                inputDataType: inputDataType,
                hintText: _hintText,
                state: state,
              );
            },
          ),
        ),
      );
    },
  ).whenComplete(
    () => context.read<ProfileDataBloc>().add(ProfileDataInputClosed()),
  );
}

/// Контент ModalBottomSheet для редактирования данных пользователя
class SheetProfileDataContent extends StatelessWidget {
  final String dataName;
  final InputDataType inputDataType;
  final String hintText;
  final ProfileDataState state;
  const SheetProfileDataContent(
      {Key? key,
      required this.dataName,
      required this.inputDataType,
      required this.hintText,
      required this.state})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ModalBottomSheet Title
            Text(
              'Введите $dataName:',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            // TextField
            _ProfileDataTextField(
              dataName: dataName,
              hintText: hintText,
              inputDataType: inputDataType,
              state: state,
            ),
            _SubmitButton(
              formzStatus: state.formzStatus,
              inputDataType: inputDataType,
            ),
          ],
        ),
      ),
    );
  }
}

/// Кнопка подтверждения изменения пользовательских данных и отправки запроса на изменение
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.formzStatus,
    required this.inputDataType,
  });
  final FormzStatus formzStatus;
  final InputDataType inputDataType;
  @override
  Widget build(BuildContext context) {
    if (formzStatus.isSubmissionInProgress)
      return SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColorDark,
        ),
      );
    else
      return ElevatedButton(
        // Зная какие данные редактирует пользователь - отправляю соответсвующий ивент
        onPressed: formzStatus.isValidated
            ? () async {
                switch (inputDataType) {
                  case InputDataType.firstname:
                    return context.read<ProfileDataBloc>().add(
                          ProfileDataFirstNameSubmitted(),
                        );
                  case InputDataType.middlename:
                    return context.read<ProfileDataBloc>().add(
                          ProfileDataMiddleNameSubmitted(),
                        );
                  case InputDataType.lastname:
                    return context.read<ProfileDataBloc>().add(
                          ProfileDataLastNameSubmitted(),
                        );
                  case InputDataType.phoneNumber:
                    return context.read<ProfileDataBloc>().add(
                          ProfileDataPhoneNumberSubmitted(),
                        );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark,
          disabledBackgroundColor: Colors.black12,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Сохранить',
        ),
      );
  }
}

/// Форма ввода значения изменяемых данных
class _ProfileDataTextField extends StatelessWidget {
  const _ProfileDataTextField(
      {required this.inputDataType,
      required this.state,
      required this.dataName,
      required this.hintText});
  final ProfileDataState state;
  final InputDataType inputDataType;
  final String hintText;
  final String dataName;
  @override
  Widget build(BuildContext context) {
    // Маска для номера телефона
    final maskFormatter = MaskTextInputFormatter(
      mask: '# (###) ###-##-##',
      filter: {'#': RegExp('[0-9]')},
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      // При появлении сообщения об ошибке в TextField - ModalBottomSheet дергался из-за нехватки места
      //  поэтому задал высоту вручную, заранее оставляя место для текста ошибки
      child: SizedBox(
        height: 95,
        child: TextField(
          maxLength: 255,
          // Если редактируемые данные это номер телефона - применяю маску
          inputFormatters:
              inputDataType == InputDataType.phoneNumber ? [maskFormatter] : [],
          autofocus: true,
          onChanged: inputDataType == InputDataType.phoneNumber
              ? (_) {
                  context.read<ProfileDataBloc>().add(
                        ProfileDataInputDataChanged(
                          maskFormatter.getMaskedText(),
                        ),
                      );
                }
              : (value) => context
                  .read<ProfileDataBloc>()
                  .add(ProfileDataInputDataChanged(value)),
          textCapitalization: TextCapitalization.sentences,
          // Тип клавиатуры в зависимости от редактируемого поля
          keyboardType: inputDataType == InputDataType.phoneNumber
              ? TextInputType.phone
              : TextInputType.text,
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            // Префикс только для  номера телефона
            prefix: inputDataType == InputDataType.phoneNumber
                ? const Text('+')
                : null,
            prefixIcon: const Icon(
              Icons.edit_rounded,
            ),
            errorText: state.inputData.invalid ? 'Введите $dataName' : null,
          ),
        ),
      ),
    );
  }
}
