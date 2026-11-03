import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Tiêu đề màn hình (vd: "Danh sách nhiệm vụ")
  static TextStyle get title => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // Tiêu đề từng phần (vd: "Nhiệm vụ hôm nay")
  static TextStyle get heading => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Nội dung thường
  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Chữ phụ, chú thích (vd: "18:30 - 19:30")
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Chữ trên nút
  static TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
}