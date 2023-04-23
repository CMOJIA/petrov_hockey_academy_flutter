import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/notifications/notifications.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:shimmer/shimmer.dart';

/// Экран просмотра списка уведомлений
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    final _displaySize = MediaQuery.of(context).size;

    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        switch (state.status) {
          case NotificationFetchedStatus.failure:
            return _FailureContent(size: _displaySize);

          case NotificationFetchedStatus.success:
            if (state.notifications.isEmpty) {
              return EmptyContent(
                value: 'Уведомления отсутствуют.',
                size: _displaySize,
              );
            }
            return _SuccessContent(
              state: state,
              scrollController: _scrollController,
            );

          case NotificationFetchedStatus.initial:
            return Center(
              child: _NotificationsShimmer(),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<NotificationsBloc>().add(NotificationsLoadedMore());
    }
  }
}

/// Шиммер при загрузке списка уведомлений
class _NotificationsShimmer extends StatelessWidget {
  const _NotificationsShimmer();
  @override
  Widget build(BuildContext context) {
    final itemHeight = 82.0;
    final color = Colors.grey[400];
    // AbsorbPointer чтобы не регировал экран на нажатия
    return AbsorbPointer(
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            // Шиммер списка уведомлений
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: itemHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Shimmer.fromColors(
                                baseColor: color!,
                                highlightColor: Colors.grey[300]!,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: color,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                                child: Shimmer.fromColors(
                              baseColor: color,
                              highlightColor: Colors.grey[300]!,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: CircleAvatar(
                                  radius: 11,
                                ),
                              ),
                            ))
                          ],
                        ),
                        Shimmer.fromColors(
                          baseColor: color,
                          highlightColor: Colors.grey[300]!,
                          child: Container(
                            margin: const EdgeInsets.only(top: 15),
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: color,
                            ),
                          ),
                        ),
                        Divider(
                          color: color,
                          thickness: 0.8,
                          height: 1,
                        ),
                      ],
                    ),
                  );
                },
                itemCount: (constraints.maxHeight / itemHeight).ceil(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Контент когда загрузка данных завершилась успешно
class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.state,
    required this.scrollController,
  });
  final NotificationsState state;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: Theme.of(context).primaryColorDark,
            // На рефреш обновляю состояние стейта NotificationsBloc
            // до знаечния по умолчанию и загружаю уведомления снова
            onRefresh: () async {
              context.read<NotificationsBloc>()
                ..add(NotificationsStatusRefreshed())
                ..add(NotificationsFetched());
            },
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return index >= state.notifications.length
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : NotificationListItem(
                        index: index,
                      );
              },
              itemCount: state.hasReachedMax
                  ? state.notifications.length
                  : state.notifications.length + 1,
              controller: scrollController,
            ),
          ),
        ),
      ],
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
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
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
              context.read<NotificationsBloc>().add(NotificationsFetched());
            },
            authenticationRepository: context.read<AuthenticationRepository>(),
          ),
        ],
      ),
    );
  }
}
