import 'dart:ui';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petrov_hockey_academy_flutter/universal/universal.dart';
import 'package:petrov_hockey_academy_flutter/user_reports/user_reports.dart';

/// Экран со списком отчетов об индивидуальных тренировках с фильтром по статусу
class IndividualsScreen extends StatefulWidget {
  const IndividualsScreen({super.key});

  @override
  State<IndividualsScreen> createState() => _IndividualsScreenState();
}

class _IndividualsScreenState extends State<IndividualsScreen> {
  List<String> filterList = [
    'Все статусы',
    'Подтверждено',
    'Отменено',
    'Запись',
    'Посещено',
  ];

  List<String> selectedFiltertList = ['Все статусы'];

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  /// Установка состояния фильтра
  void setIndividualsFilterStatus(
    String value,
  ) {
    return setState(() {
      selectedFiltertList
        ..removeLast()
        ..add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displaySize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text('Индивидуальные тренировки'),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          switch (state.status) {
            case ReportsFetchedStatus.failure:
              return _FailureContent(
                size: displaySize,
              );
            case ReportsFetchedStatus.success:
              // Проверка на пустой список
              if (state.individuals.isEmpty) {
                return EmptyContent(
                    value: 'Посещения индвидуальных тренировок отстутвуют.',
                    size: displaySize);
              }
              return _SuccessContent(
                scrollController: scrollController,
                selectedFiltertList: selectedFiltertList,
                setIndividualsFilterStatus: setIndividualsFilterStatus,
                state: state,
              );
            case ReportsFetchedStatus.initial:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      context.read<ReportsBloc>().add(ReportsIndividualsLoadedMore());
    }
  }
}

/// [ListView.builder] списка отчетов о тренировках
class _IndividualsReportsListView extends StatelessWidget {
  const _IndividualsReportsListView({
    required this.scrollController,
    required this.selectedFiltertList,
    required this.setIndividualsFilterStatus,
    required this.state,
  });
  final List<String> selectedFiltertList;
  final void Function(String) setIndividualsFilterStatus;
  final ReportsState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          // Логика отображения списка в зависимости от выбранного фильтра
          if (index >= state.individuals.length) {
            // Если выбран фильтр отличный от "Все статусы" может быть ситуация когда
            // элементов слишком мало для прокрутки и тогда подгрузка по скроллу не сработает
            if (selectedFiltertList.contains('Все статусы')) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return const SizedBox();
            }
          } else {
            // На все статусы передется весь список
            if (selectedFiltertList.contains('Все статусы')) {
              return IndividualsReportsListItem(
                individualReport: state.individuals[index],
              );
            } else {
              // Проверка содержится ли выбранный фильтр (т.к. пока нельзя выбирать
              // несколько фильтров, беру первый элемент) в элементе списка
              if (state.individuals[index].status
                  .contains(selectedFiltertList.first)) {
                return IndividualsReportsListItem(
                  individualReport: state.individuals[index],
                );
              } else {
                return const SizedBox();
              }
            }
          }
        },
        itemCount: state.individualsHasReachedMax
            ? state.individuals.length
            : state.individuals.length + 1,
        controller: scrollController,
      ),
    );
  }
}

/// Контент когда загрузка данных завершилась успешно
class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.scrollController,
    required this.selectedFiltertList,
    required this.setIndividualsFilterStatus,
    required this.state,
  });
  final List<String> selectedFiltertList;
  final void Function(String) setIndividualsFilterStatus;
  final ReportsState state;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        _IndividulasReportsFilter(
          selectedFiltertList: selectedFiltertList,
          callback: setIndividualsFilterStatus,
        ),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
        _IndividualsReportsListView(
          scrollController: scrollController,
          selectedFiltertList: selectedFiltertList,
          setIndividualsFilterStatus: setIndividualsFilterStatus,
          state: state,
        ),
      ],
    );
  }
}

/// Контент показываемый при ошибке загрузки отчетов об индивидуальных тренировках
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
              context.read<ReportsBloc>().add(ReportsFetched());
            },
            authenticationRepository: context.read<AuthenticationRepository>(),
          ),
        ],
      ),
    );
  }
}

/// Элемент фильтра отчетов о индивидуальных тренировках
class _IndividualsReportsFilterOptions extends StatelessWidget {
  const _IndividualsReportsFilterOptions({
    required this.value,
    required this.callback,
  });
  final String value;
  final Function(String) callback;
  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 16,
      ),
      key: ValueKey(value),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        callback(value);
      },
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// Фильтр отчетов об индивидуальных тренировках
class _IndividulasReportsFilter extends StatelessWidget {
  const _IndividulasReportsFilter({
    required this.selectedFiltertList,
    required this.callback,
  });
  final List<String> selectedFiltertList;
  final void Function(String) callback;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: () {
          showGeneralDialog<String>(
            context: context,
            pageBuilder: (context, anim1, anim2) {
              return Container();
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return Transform.scale(
                scale: anim1.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: SimpleDialog(
                    title: const Text(
                      'Выбрать статус тренировки:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    // Список опций фильтров в диалоговом окне по статусу тренировки
                    children: [
                      _IndividualsReportsFilterOptions(
                        value: 'Все статусы',
                        callback: callback,
                      ),
                      _IndividualsReportsFilterOptions(
                        value: 'Запись',
                        callback: callback,
                      ),
                      _IndividualsReportsFilterOptions(
                        value: 'Подтверждено',
                        callback: callback,
                      ),
                      _IndividualsReportsFilterOptions(
                        value: 'Отменено',
                        callback: callback,
                      ),
                      _IndividualsReportsFilterOptions(
                        value: 'Посещено',
                        callback: callback,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedFiltertList.first,
                style: Theme.of(context).textTheme.bodyMedium,
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
