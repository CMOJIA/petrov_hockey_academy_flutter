import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/user_reports.dart';
import 'package:petrov_hockey_academy_flutter/transitions/transitions.dart';
import 'package:shimmer/shimmer.dart';

/// Экран пользователя, откуда он может перейти к редактированию своих данных, к медиа,
/// а так же к своим отчетам
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.dataStatus != current.dataStatus,
      builder: (context, state) {
        switch (state.dataStatus) {
          case ProfileDataStatus.failure:
            return _FailureContent(
              size: _displaySize,
            );
          case ProfileDataStatus.success:
            if (state.profileData == ProfileData.empty) {
              return EmptyContent(
                  value:
                      'Пользователь не является  клиентом. Данные не могут быть загружены.',
                  size: _displaySize);
            }
            return Column(
              children: [
                const SizedBox(height: 8),

                _ToUserDataScreenButton(),

                _ToReportsScreenButton(),

                // Если пользователь является редактором
                if (state.profileData.isRedactor)
                  _ToMediaScreenButton(
                    groupId: state.groups.first.groupId,
                  )
              ],
            );
          case ProfileDataStatus.initial:
            return _MenuBurgerShimmer();
        }
      },
    );
  }
}

/// Контент когда загрузка данных завершилась ошибкой
class _FailureContent extends StatelessWidget {
  const _FailureContent({required this.size});
  final Size size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.1,
        right: size.width * 0.1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Ошибка загрузки.\nПроверьте интернет-подключение или повторите попытку позже.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          RefreshButton(
            onTap: () {
              context.read<ProfileDataBloc>().add(ProfileDataFetched());
            },
            authenticationRepository: context.read<AuthenticationRepository>(),
          ),
        ],
      ),
    );
  }
}

// Кнопка перехода на страницу изменения пользовательских данных
//
// Отображается аватар, фио и email пользователя
class _ToUserDataScreenButton extends StatelessWidget {
  const _ToUserDataScreenButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDataBloc, ProfileDataState>(
      buildWhen: (previous, current) =>
          previous.profileData != current.profileData,
      builder: (context, state) {
        return Card(
          elevation: 5,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            onTap: () => Navigator.push(
              context,
              FadeRoute(
                builder: (
                  ctx,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: BlocProvider.of<ProfileDataBloc>(
                          context,
                        ),
                      ),
                    ],
                    child: const ProfileDataScreen(),
                  );
                },
              ),
            ),
            // Аватар пользователя, если он отсутствует - заглушка аватара показывается
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).primaryColorDark,
                        foregroundImage: state.profileData.photo == null
                            ? AssetImage(
                                'assets/empty_avatar.png',
                              ) as ImageProvider
                            : NetworkImage(
                                'https://hb.bizmrg.com/st.test.petrovacademy.ru/avatars/${state.profileData.photo}',
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          direction: Axis.vertical,
                          children: [
                            // ФИО пользователя
                            Text(
                                '''${state.profileData.middleName} '''
                                '''${state.profileData.firstName.substring(0, 1).toUpperCase()}.'''
                                '''${state.profileData.lastName.substring(0, 1).toUpperCase()}.''',
                                style: Theme.of(context).textTheme.bodyMedium),
                            // email пользователя
                            Text(state.profileData.email,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Кнопка перехода  к отчетам пользователя
class _ToReportsScreenButton extends StatelessWidget {
  const _ToReportsScreenButton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => Navigator.push(
          context,
          FadeRoute(
            builder: (
              ctx,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return BlocProvider.value(
                value: BlocProvider.of<ReportsBloc>(context),
                child: const ReportsScreen(),
              );
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text('Отчеты',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Кнопка перехода к медиаальбомам пользователя
class _ToMediaScreenButton extends StatelessWidget {
  const _ToMediaScreenButton({required this.groupId});
  final String groupId;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () => Navigator.push(
          context,
          FadeRoute(
            builder: (
              ctx,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<ProfileDataBloc>(
                      context,
                    ),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<MediaBloc>(
                      context,
                    )..add(
                        AddMediaSettedInitialState(
                          int.parse(groupId),
                        ),
                      ),
                  ),
                ],
                child: const MediaPage(),
              );
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text('Добавить медиа',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Шиммер при прогрузке данных
class _MenuBurgerShimmer extends StatelessWidget {
  const _MenuBurgerShimmer();

  @override
  Widget build(BuildContext context) {
    final profileCardHeight = 96.0;
    final itemHeight = 64.0;
    final color = Colors.grey[400];
    return AbsorbPointer(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: profileCardHeight,
              width: constraints.maxWidth,
              child: Shimmer.fromColors(
                baseColor: color!,
                highlightColor: Colors.grey[300]!,
                child: Card(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: color,
                  highlightColor: Colors.grey[300]!,
                  child: SizedBox(
                    height: itemHeight,
                    width: constraints.maxWidth,
                    child: Card(),
                  ),
                ),
                itemCount: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
