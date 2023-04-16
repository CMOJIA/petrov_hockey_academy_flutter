import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';

/// Форма в виде ModalBottomSheet для редактирования email
void updateEmail(
  BuildContext context,
) {
  showModalBottomSheet<void>(
    isScrollControlled: true,
    context: context,
    builder: (_) {
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
                    content: const Text(
                      'E-mail успешно изменен.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
            }
            if (state.formzStatus.isSubmissionFailure) {
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
              return _SheetEmailContent(state: state);
            },
          ),
        ),
      );
    },
  ).whenComplete(
    () => context.read<ProfileDataBloc>().add(ProfileDataInputClosed()),
  );
}

/// Контент ModalBottomSheet для редактирования email
class _SheetEmailContent extends StatelessWidget {
  const _SheetEmailContent({Key? key, required this.state}) : super(key: key);
  final ProfileDataState state;

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
            // Заголовок
            Text(
              'Редактирование e-mail',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            _EmailTextField(inputEmail: state.inputEmail),
            _SubmitButton(formzStatus: state.formzStatus),
          ],
        ),
      ),
    );
  }
}

/// Кнопка подтверждения изменения email и отправки запроса на его изменение
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.formzStatus});
  final FormzStatus formzStatus;
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
        onPressed: formzStatus.isValidated
            ? () =>
                context.read<ProfileDataBloc>().add(ProfileDataEmailSubmetted())
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

/// Форма ввода нового [Email]
class _EmailTextField extends StatelessWidget {
  const _EmailTextField({required this.inputEmail});
  final Email inputEmail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      // При появлении сообщения об ошибке в TextField - ModalBottomSheet дергался из-за нехватки места
      child: SizedBox(
        height: 95,
        child: TextField(
          autofocus: true,
          autocorrect: false,
          textCapitalization: TextCapitalization.sentences,
          maxLength: 255,
          onChanged: (value) => context
              .read<ProfileDataBloc>()
              .add(ProfileDataInputEmailChanged(value)),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Новый e-mail',
            prefixIcon: Icon(
              Icons.email_rounded,
            ),
            errorText: inputEmail.invalid ? 'Некорректный email' : null,
          ),
        ),
      ),
    );
  }
}
