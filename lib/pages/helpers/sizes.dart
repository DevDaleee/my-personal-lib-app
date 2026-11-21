import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

extension ResponsiveTextSize on BuildContext {
  double responsiveFontSize([double? small, double? large]) {
    final isSmallScreen = MediaQuery.of(this).size.height < 700;
    return isSmallScreen ? (small ?? TextSizes.xs) : (large ?? TextSizes.sm);
  }
}

class TextSizes {
  static double get usm => 9.0.sp;
  static double get xs => 12.0.sp;
  static double get sm => 14.0.sp;
  static double get md => 16.0.sp;
  static double get lg => 18.0.sp;
  static double get xl => 24.0.sp;
  static double get xxl => 32.0.sp;
}

class SpaceSizes {
  static double get xs => 4.0.sp;
  static double get sm => 8.0.sp;
  static double get md => 16.0.sp;
  static double get lg => 24.0.sp;
  static double get xl => 32.0.sp;
  static double get xxl => 40.0.sp;
  static double get ll => 50.0.sp;
  static double get llm => 56.0.sp;
  static double get xll => 60.0.sp;
  static double get xxlm => 70.0.sp;
  static double get xxxl => 80.0.sp;
}

class PaddingSizes {
  static double get xs => 2.0.sp;
  static double get sm => 8.0.sp;
  static double get md => 12.0.sp;
  static double get lg => 16.0.sp;
  static double get xl => 24.0.sp;
  static double get xxl => 32.0.sp;
}

class RadiusSizes {
  static double get xs => 8.0.sp;
  static double get sm => 12.0.sp;
  static double get md => 16.0.sp;
  static double get lg => 24.0.sp;
  static double get xl => 50.0.sp;
}
