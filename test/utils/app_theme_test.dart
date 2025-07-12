import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahovska_app/utils/app_theme.dart';
import 'package:sahovska_app/constants/app_colors.dart';

void main() {
  group('AppTheme', () {
    test('should provide light theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);
    });

    test('should have correct primary color', () {
      final theme = AppTheme.lightTheme;

      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
    });

    test('should have correct app bar theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.appBarTheme.backgroundColor, AppColors.primary);
      expect(theme.appBarTheme.foregroundColor, AppColors.textOnPrimary);
      expect(theme.appBarTheme.elevation, 2);
    });

    test('should have correct card theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.cardTheme.color, AppColors.cardBackground);
      expect(theme.cardTheme.elevation, 2);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('should have correct elevated button theme', () {
      final theme = AppTheme.lightTheme;
      final buttonTheme = theme.elevatedButtonTheme.style!;

      expect(
        buttonTheme.backgroundColor!.resolve({MaterialState.pressed}),
        AppColors.buttonPrimary,
      );
      expect(
        buttonTheme.foregroundColor!.resolve({MaterialState.pressed}),
        AppColors.buttonText,
      );
    });

    test('should have correct input decoration theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.inputDecorationTheme.filled, true);
      expect(theme.inputDecorationTheme.fillColor, AppColors.inputBackground);
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    });

    test('should get correct notification type color', () {
      expect(
        AppTheme.getNotificationTypeColor('general'),
        AppColors.generalNotification,
      );
      expect(
        AppTheme.getNotificationTypeColor('tournament'),
        AppColors.tournamentNotification,
      );
      expect(
        AppTheme.getNotificationTypeColor('camp'),
        AppColors.campNotification,
      );
      expect(
        AppTheme.getNotificationTypeColor('training'),
        AppColors.trainingNotification,
      );
      expect(
        AppTheme.getNotificationTypeColor('unknown'),
        AppColors.generalNotification,
      );
    });

    test('should get correct status color', () {
      expect(AppTheme.getStatusColor('success'), AppColors.success);
      expect(AppTheme.getStatusColor('SUCCESS'), AppColors.success);
      expect(AppTheme.getStatusColor('warning'), AppColors.warning);
      expect(AppTheme.getStatusColor('error'), AppColors.error);
      expect(AppTheme.getStatusColor('info'), AppColors.info);
      expect(AppTheme.getStatusColor('unknown'), AppColors.info);
    });

    test('should have correct scaffold background color', () {
      final theme = AppTheme.lightTheme;

      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('should have correct dialog theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.dialogTheme.backgroundColor, AppColors.surface);
      expect(theme.dialogTheme.shape, isA<RoundedRectangleBorder>());
    });

    test('should have correct snack bar theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.snackBarTheme.backgroundColor, AppColors.textPrimary);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
    });

    test('should have correct progress indicator theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.progressIndicatorTheme.color, AppColors.primary);
      expect(theme.progressIndicatorTheme.linearTrackColor, AppColors.surfaceVariant);
    });

    test('should have correct text theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.textTheme.displayLarge, isNotNull);
      expect(theme.textTheme.bodyLarge, isNotNull);
      expect(theme.textTheme.labelMedium, isNotNull);
    });

    test('dark theme should be available', () {
      final darkTheme = AppTheme.darkTheme;

      expect(darkTheme, isA<ThemeData>());
      // Note: Currently returns light theme, but structure is there for dark theme
    });
  });
}