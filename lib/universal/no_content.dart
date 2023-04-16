import 'package:flutter/material.dart';

/// Текстовый виджет информирующий об отсутствии контента
class EmptyContent extends StatelessWidget {
  const EmptyContent({required this.value, required this.size});
  final String value;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
      ),
      child: Center(
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
