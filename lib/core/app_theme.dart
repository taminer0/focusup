import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Font logo "FocusUp" và tiêu đề "Đăng ký": DM Serif Display
  static TextStyle logo({double size = 40, Color? color}) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: size,
        color: color ?? AppColors.green,
      );

  static ThemeData get light {
    // Font chung cho cả app: Plus Jakarta Sans
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
        onPrimary: AppColors.white,
        secondary: AppColors.success,
        error: AppColors.error,
        surface: AppColors.backgroundSecondary,
        surfaceTint: Colors.transparent,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      // Nút chính (viên thuốc)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Nút viền (ví dụ nút "Tiếp tục với Google")
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.backgroundSecondary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Nút chữ (link "Đăng nhập", "Xem tất cả")
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.green,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Nút thêm nổi (dấu +)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Ô nhập liệu
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.green),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error),
      ),

      // Thẻ
      cardTheme: CardThemeData(
        color: AppColors.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      // Công tắc (Địa điểm, Google Calendar)
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.green
              : AppColors.border,
        ),
        trackOutlineColor:
        const WidgetStatePropertyAll(Colors.transparent),
      ),

      // Ô tick
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.green
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.white),
        side: const BorderSide(color: AppColors.textTertiary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // Thanh tab dưới
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Hộp thoại (đặt giới hạn app, kết nối Google Calendar)
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Vòng/thanh tiến độ
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.green,
        linearTrackColor: AppColors.greenLight,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}