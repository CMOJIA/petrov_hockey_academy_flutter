part of 'app_bloc.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

class AppState extends Equatable {
  const AppState._({
    required this.status,
    this.user = User.empty,
    this.selectedPage = 0,
  });

  const AppState.authenticated(User user)
      : this._(status: AppStatus.authenticated, user: user, selectedPage: 0);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final User user;
  final int selectedPage;

  AppState copyWith({
    int? selectedPage,
  }) {
    return AppState._(
        status: status, selectedPage: selectedPage ?? this.selectedPage);
  }

  @override
  List<Object> get props => [status, user, selectedPage];
}
