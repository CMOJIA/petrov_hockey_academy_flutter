import 'package:authentication_repository/authentication_repository.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:petrov_hockey_academy_flutter/app/app.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';
import 'package:petrov_hockey_academy_flutter/media/media.dart';
import 'package:petrov_hockey_academy_flutter/notifications/notifications.dart';
import 'package:petrov_hockey_academy_flutter/profile_data/profile_data.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/user_reports.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:petrov_hockey_academy_flutter/timetables/timetables.dart';

final GetIt getIt = GetIt.instance;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  final notification = message.notification;
  final android = message.notification?.android;
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          color: const Color(0xFFA73F40),
          playSound: channel.playSound,
          importance: channel.importance,
          icon: '@drawable/hockey_player',
        ),
      ),
    );
  }
}

/// Основной экран приложения с [BottomNavigationBar] с вкладками экранов:
/// Расписание, Уведомления, Абонементы, Пользователь
class TabsScreen extends StatefulWidget {
  const TabsScreen({
    super.key,
  });

  static Page<void> page() => const MaterialPage<void>(
        child: TabsScreen(),
      );

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen(
      (message) async {
        if (message.notification != null) {
          if (message.notification!.body != null) {
            showFlutterNotification(message);
          }
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(_messageHandler);
  }

  @override
  Widget build(BuildContext context) {
    final _authenticationRepository = context.read<AuthenticationRepository>();

    getIt.allowReassignment = true;

    getIt.registerSingleton<GraphQLService>(
      GraphQLService(_authenticationRepository.currentUser.token),
    );

    return BlocProvider(
      create: (_) => NotificationsBloc(
        authenticationRepository: _authenticationRepository,
        httpClient: http.Client(),
      )..add(NotificationsFetched()),
      child: ScaffoldTabsScreen(),
    );
  }
}

class ScaffoldTabsScreen extends StatelessWidget {
  const ScaffoldTabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late List<Map<String, Object>> _pages;

    var _selectedPage = context.select(
      (AppBloc bloc) => bloc.state.selectedPage,
    );

    _pages = [
      {
        'page': const TimetableScreen(),
        'title': 'Расписание',
        'icon': const Icon(Icons.calendar_today_rounded),
      },
      {
        'page': const NotificationsScreen(),
        'title': 'Уведомления',
        'icon': const Icon(Icons.notifications_rounded),
      },
      {
        'page': const SubscriptionsScreen(),
        'title': 'Покупка абонементов',
        'icon': const Icon(Icons.payment_rounded),
      },
      {
        'page': const UserScreen(),
        'title': 'Пользователь',
        'icon': const Icon(Icons.person_rounded),
      },
    ];

    /// Билдер, чтобы обновлять счетчик уведомлений после прочтения
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isReadStatus != current.isReadStatus,
      builder: (context, state) {
        final _notficationsCounter =
            state.notifications.where((element) => element.isRead == 0).length;
        return Scaffold(
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: _pages[_selectedPage]['icon'] as Icon,
            title: Text(_pages[_selectedPage]['title'] as String),
            actions: [
              _LogOutButton(
                pages: _pages,
                selectedPage: _selectedPage,
              ),
            ],
          ),
          body: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => SubscriptionsBloc(
                  httpClient: http.Client(),
                )..add(SubscriptionsFetched()),
              ),
              BlocProvider(
                create: (_) => ProfileDataBloc(
                  httpClient: http.Client(),
                  authenticationRepository:
                      context.watch<AuthenticationRepository>(),
                )..add(ProfileDataFetched()),
              ),
              BlocProvider(
                create: (_) => ReportsBloc(
                  httpClient: http.Client(),
                  authenticationRepository:
                      context.watch<AuthenticationRepository>(),
                )..add(ReportsFetched()),
              ),
              BlocProvider<MediaBloc>(
                  create: (_) => MediaBloc(
                        authenticationRepository:
                            context.watch<AuthenticationRepository>(),
                      ))
            ],
            child: _pages[_selectedPage]['page'] as Widget,
          ),
          bottomNavigationBar: BottomNavigationBar(
            iconSize: 26,
            onTap: (int index) {
              context.read<AppBloc>().add(AppSelectedTabsPage(index));
            },
            currentIndex: _selectedPage,
            items: [
              BottomNavigationBarItem(
                backgroundColor:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                icon: const Icon(Icons.calendar_today_rounded),
                label: 'Расписание',
              ),
              BottomNavigationBarItem(
                backgroundColor:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                // Показывать иконку непрочитанных уведомлений или нет
                icon: state.status == NotificationFetchedStatus.failure
                    ? const Icon(Icons.notifications_rounded)
                    : state.notifications
                                .where((element) => element.isRead == 0)
                                .length >
                            0
                        ? badges.Badge(
                            badgeAnimation: badges.BadgeAnimation.rotation(
                              animationDuration: Duration(milliseconds: 700),
                              loopAnimation: false,
                              curve: Curves.fastOutSlowIn,
                            ),
                            badgeStyle: badges.BadgeStyle(
                              shape: badges.BadgeShape.circle,
                              badgeColor: Colors.green[600]!,
                              elevation: 0,
                            ),
                            badgeContent: Text(
                              // Чтобы не занимал много места значок счетчика если пользователь вообще не  читает уведомления
                              _notficationsCounter > 9
                                  ? '9+'
                                  : _notficationsCounter.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Icon(Icons.notifications_rounded),
                          )
                        : const Icon(Icons.notifications_rounded),
                label: 'Уведомления',
              ),
              BottomNavigationBarItem(
                backgroundColor:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                icon: const Icon(Icons.payment_rounded),
                label: 'Абонементы',
              ),
              BottomNavigationBarItem(
                backgroundColor:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                icon: const Icon(Icons.dehaze_rounded),
                label: 'Пользователь',
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showFlutterNotification(message);
}

/// Кнопка выхода из аккаунта
class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.pages, required this.selectedPage});
  final List<Map<String, Object>> pages;
  final int selectedPage;
  @override
  Widget build(BuildContext context) {
    // Только на странице Пользователя добавлена кнопка logout
    if (pages[selectedPage] == pages[3])
      return IconButton(
        splashRadius: 24,
        icon: const Icon(Icons.exit_to_app_rounded),
        onPressed: () {
          context.read<AppBloc>().add(AppLogoutRequested());
          // Возвращение фильтра расписания к значению по умолчанию
          TimetableScreen.filter = FilterOptions.free;
        },
      );
    else
      return const SizedBox();
  }
}
