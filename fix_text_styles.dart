import 'dart:io';

void main() {
  final file = File('lib/core/theme/theme_ext.dart');
  final lines = file.readAsLinesSync();
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('TextStyle get heading1 =>')) {
      lines[i] = '  TextStyle get heading1 => (_theme.displayLarge ?? AppTextStyles.heading1).copyWith(color: ThemeExtension(context).colors.textDark);';
    } else if (lines[i].contains('TextStyle get heading2 =>')) {
      lines[i] = '  TextStyle get heading2 => (_theme.displayMedium ?? AppTextStyles.heading2).copyWith(color: ThemeExtension(context).colors.textDark);';
    } else if (lines[i].contains('TextStyle get heading3 =>')) {
      lines[i] = '  TextStyle get heading3 => (_theme.headlineMedium ?? AppTextStyles.heading3).copyWith(color: ThemeExtension(context).colors.textDark);';
    } else if (lines[i].contains('TextStyle get bodyLarge =>')) {
      lines[i] = '  TextStyle get bodyLarge => (_theme.bodyLarge ?? AppTextStyles.bodyLarge).copyWith(color: ThemeExtension(context).colors.textDark);';
    } else if (lines[i].contains('TextStyle get bodyMedium =>')) {
      lines[i] = '  TextStyle get bodyMedium => (_theme.bodyMedium ?? AppTextStyles.bodyMedium).copyWith(color: ThemeExtension(context).colors.textDark);';
    } else if (lines[i].contains('TextStyle get bodySmall =>')) {
      lines[i] = '  TextStyle get bodySmall => (_theme.bodySmall ?? AppTextStyles.bodySmall).copyWith(color: ThemeExtension(context).colors.textDark);';
    } else if (lines[i].contains('TextStyle get labelBold =>')) {
      lines[i] = '  TextStyle get labelBold => (_theme.labelLarge ?? AppTextStyles.labelBold).copyWith(color: ThemeExtension(context).colors.textDark);';
    } else if (lines[i].contains('TextStyle get labelMedium =>')) {
      lines[i] = '  TextStyle get labelMedium => (_theme.labelMedium ?? AppTextStyles.labelMedium).copyWith(color: ThemeExtension(context).colors.textDark);';
    }
  }
  
  file.writeAsStringSync('${lines.join('\n')}\n');
}
