import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petrov_hockey_academy_flutter/subscriptions/subscriptions.dart';
import 'package:url_launcher/url_launcher.dart';

/// Страница подтвреждения данных для оплаты абонемента с кнопкой оплаты
class SubcriptionPaymentScreen extends StatelessWidget {
  const SubcriptionPaymentScreen({
    super.key,
    required this.subscription,
    required this.student,
  });

  final SubscriptionTemplate subscription;

  final Student? student;

  @override
  Widget build(BuildContext context) {
    // Бэкенд покупки абонемента на стадии разработки, пока открывается сайт академии
    Future<void> _launchURL() async {
      final url = Uri.parse('https://petrovacademy.ru/');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                  ),
                  label: Text(
                    'Назад',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Оплата абонемента',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                _Amount(value: 'Ученик:'),
                _TextForm(
                  value: '''${student?.firstName} '''
                      '''${student?.middleName.substring(0, 1).toUpperCase()}.'''
                      ''' ${student?.lastName.substring(0, 1).toUpperCase()}.''',
                ),
                const SizedBox(
                  height: 8,
                ),
                _Amount(value: 'Абонемент:'),
                _TextForm(
                  value: subscription.title.contains('<b>')
                      ? subscription.title
                          .replaceAll(RegExp(r'</b>|<b>|\(.*?\)'), '')
                          .replaceAll('  ', ' ')
                      : subscription.title,
                ),
                const SizedBox(
                  height: 8,
                ),
                _Amount(value: 'Стоимость:'),
                _TextForm(value: '${subscription.price} руб.'),
                const Spacer(),
                _Button(
                  color: const Color.fromARGB(255, 70, 165, 37),
                  value: 'Оплатить',
                  onPressed: _launchURL,
                ),
                _Button(
                  color: const Color.fromARGB(255, 195, 66, 68),
                  value: 'Отменить',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Универсальный [TextFormField] для этой страницы
class _TextForm extends StatelessWidget {
  const _TextForm({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      initialValue: value,
      maxLines: null,
      cursorColor: Theme.of(context).scaffoldBackgroundColor,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFa73f40),
            width: 1.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFa73f40),
            width: 1.5,
          ),
        ),
        counterText: '',
      ),
    );
  }
}

/// Текстовый виджет с информацией о сумме стоимости абонемента
class _Amount extends StatelessWidget {
  const _Amount({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: TextAlign.end,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 22,
      ),
    );
  }
}

/// Универсальная кнопка для этого виджета.
///
/// Выполняет функцию отмены оплаты или перехода к оплате.
class _Button extends StatelessWidget {
  const _Button({
    required this.color,
    required this.value,
    required this.onPressed,
  });
  final Color color;
  final String value;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        key: ValueKey(value),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            value,
          ),
        ),
      ),
    );
  }
}
