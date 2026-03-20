/// 앱 전체 ThemeData를 정의하는 파일.
import 'package:flutter/material.dart';
import 'package:nihongo/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // 기본 색상 설정
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    // appBar 스타일
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textBlack,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textBlack,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // 입력창(TextField) 스타일
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      // 기본 테두리
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),

      // 비활성 상태 테두리
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.border),
      ),

      // 포커스(클릭) 시 테두리
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      labelStyle: TextStyle(color: AppColors.textGrey),
      hintStyle: TextStyle(color: AppColors.textGrey),
    ),

    // ElevatedButton 스타일
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // TextButton 스타일
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // outlinedButton 스타일
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        side: BorderSide(
          color: AppColors.borderBlack,
          width: 1,
        ),
      ),
    ),

    // BottomNavigationBar 스타일
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.textBlack,
      unselectedItemColor: AppColors.textGrey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}