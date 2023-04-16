import 'package:flutter/material.dart';

// Файл с различными видами анимаций переходов на старницу

class SizeRoute extends PageRouteBuilder<Widget> {
  SizeRoute({required this.builder})
      : super(
          pageBuilder: builder,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Align(
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          ),
        );
  final Widget Function(BuildContext, Animation<double>, Animation<double>)
      builder;
}

class FadeRoute extends PageRouteBuilder<Widget> {
  FadeRoute({required this.builder})
      : super(
          pageBuilder: builder,
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
  final Widget Function(BuildContext, Animation<double>, Animation<double>)
      builder;
}

class RotationRoute extends PageRouteBuilder<Widget> {
  RotationRoute({required this.builder})
      : super(
          pageBuilder: builder,
          transitionDuration: const Duration(seconds: 1),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              RotationTransition(
            turns: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.linear,
              ),
            ),
            child: child,
          ),
        );
  final Widget Function(BuildContext, Animation<double>, Animation<double>)
      builder;
}

class ScaleRoute extends PageRouteBuilder<Widget> {
  ScaleRoute({required this.builder})
      : super(
          pageBuilder: builder,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
  final Widget Function(BuildContext, Animation<double>, Animation<double>)
      builder;
}

class SlideRightRoute extends PageRouteBuilder<Widget> {
  SlideRightRoute({required this.builder})
      : super(
          pageBuilder: builder,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
  final Widget Function(BuildContext, Animation<double>, Animation<double>)
      builder;
}
