import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppLoadings {
  static Widget circular({Color color = AppColors.primary, double size = 24}) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
