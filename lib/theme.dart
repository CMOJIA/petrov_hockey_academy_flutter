import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  focusColor: const Color(0xFF172439),
  // IconTheme
  iconTheme: IconThemeData(
    color: const Color(0xFFe3e3e3),
  ),
  // Тема BottomNavigationBar
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    showSelectedLabels: false,
    showUnselectedLabels: false,
    backgroundColor: Color(0xFFA73F40),
    landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    selectedItemColor: const Color(0xFF172439),
    unselectedItemColor: const Color(0xFFe3e3e3),
    type: BottomNavigationBarType.shifting,
  ),

  // Тема Card
  cardTheme: CardTheme(
    color: Color(0xFFA73F40),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),
  // Тема TextButton
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
        shape: MaterialStateProperty.all<StadiumBorder>(
          const StadiumBorder(),
        ),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(Color(0xFFA73F40)),
        textStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 18,
          ),
        )),
  ),
  // Тема BottonSheet
  bottomSheetTheme: BottomSheetThemeData(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    backgroundColor: const Color(0xFFe3e3e3),
  ),
  // Тема ListTile
  listTileTheme: ListTileThemeData(
    tileColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    iconColor: const Color(0xFF172439),
  ),
  // Тема диалоговых окон
  dialogTheme: DialogTheme(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
  ),
  // Тема SnackBar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFFA73F40),
    contentTextStyle: TextStyle(
      fontSize: 16,
      color: const Color(0xFFe3e3e3),
    ),
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(30)),
    ),
  ),
  // Тема ElevatedButton
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      foregroundColor: MaterialStateProperty.all(const Color(0xFFe3e3e3)),
      backgroundColor: MaterialStateProperty.all(const Color(0xFFA73F40)),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 20,
          letterSpacing: 1,
          color: const Color(0xFFe3e3e3),
        ),
      ),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Color(0xFF172439), selectionHandleColor: Color(0xFFA73F40)),
  appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF172439),
      foregroundColor: const Color(0xFFe3e3e3)),
  // TextTheme
  textTheme: GoogleFonts.openSansTextTheme(TextTheme(
    bodySmall: TextStyle(
      color: const Color(0xFFe3e3e3),
      fontSize: 14,
    ),
    bodyMedium: TextStyle(
      color: const Color(0xFFe3e3e3),
      fontSize: 16,
    ),
    bodyLarge: TextStyle(
      color: const Color(0xFFe3e3e3),
      fontSize: 18,
    ),
    displaySmall: TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: const TextStyle(
      fontSize: 18,
      color: Colors.black87,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
    ),
    displayLarge: const TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    labelLarge: const TextStyle(),
    titleLarge: TextStyle(
      color: const Color(0xFFe3e3e3),
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
    ),
  )),
  primaryColorDark: const Color(0xFF172439),
  primaryColorLight: const Color(0xFFe3e3e3),
  primaryColor: Color(0xFFA73F40),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF172439),
    secondary: Color(0xFFa73f40),
  ),
  scaffoldBackgroundColor: const Color(0xFFe3e3e3),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Color(0xFFa73f40)),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF172439)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFa73f40), width: 2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    prefixIconColor: Color(0xFF172439),
    suffixIconColor: Color(0xFF172439),
  ),
);
