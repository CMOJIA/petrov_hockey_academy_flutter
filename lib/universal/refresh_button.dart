import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:petrov_hockey_academy_flutter/graphQL/graphql_service.dart';

/// Кнопка для попытки повторной загрузки
class RefreshButton extends StatefulWidget {
  const RefreshButton({
    required this.onTap,
    required this.authenticationRepository,
  });
  final VoidCallback onTap;
  final AuthenticationRepository authenticationRepository;
  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with TickerProviderStateMixin {
  bool isPressed = false;
  final GetIt getIt = GetIt.instance;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCirc,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey[500]!,
                    offset: Offset(8, 8),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: const Offset(-8, -8),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: GestureDetector(
          // Блокирую нажатие если она уже нажата т.к. нажатие сопровождается анимацией
          // и после проигрывания анимации выполняется функция onTap
          onTap: isPressed
              ? null
              : () {
                  getIt.registerSingleton<GraphQLService>(
                    GraphQLService(
                        widget.authenticationRepository.currentUser.token),
                  );
                  if (mounted)
                    setState(() {
                      _controller.forward(from: 0);
                      isPressed = !isPressed;
                    });
                  // Ожидаю пока пройдет анимация нажатия и устанавливаю состояние НЕ нажатой кнопки,
                  // чтобы если повторная загрузка не удалась - кнопка возвращалась в состояние по умолчанию
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted)
                      setState(
                        () {
                          isPressed = !isPressed;
                        },
                      );
                  }).whenComplete(
                      // Время, чтобы прошла анимация и кнопка вернулась в исходное состояние
                      // и только после выполняю функцию на нажатие
                      () {
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      widget.onTap,
                    );
                  });
                },
          child: RotationTransition(
            turns: _animation,
            child: Icon(
              Icons.refresh_rounded,
              size: 40,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
