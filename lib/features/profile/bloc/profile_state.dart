import 'package:flutter/material.dart';

enum ProfileExportStatus { idle, loading, done, error }

class ProfileState {
  const ProfileState({
    this.xpPoints = 0,
    this.streakDays = 0,
    this.totalTransactions = 0,
    this.themeMode = ThemeMode.system,
    this.biometricEnabled = false,
    this.exportStatus = ProfileExportStatus.idle,
    this.errorMessage,
  });

  final int xpPoints;
  final int streakDays;
  final int totalTransactions;
  final ThemeMode themeMode;
  final bool biometricEnabled;
  final ProfileExportStatus exportStatus;
  final String? errorMessage;

  String get xpLabel {
    if (xpPoints >= 1000) {
      return '${(xpPoints / 1000).toStringAsFixed(1)}k';
    }
    return xpPoints.toString();
  }

  ProfileState copyWith({
    int? xpPoints,
    int? streakDays,
    int? totalTransactions,
    ThemeMode? themeMode,
    bool? biometricEnabled,
    ProfileExportStatus? exportStatus,
    String? errorMessage,
  }) =>
      ProfileState(
        xpPoints: xpPoints ?? this.xpPoints,
        streakDays: streakDays ?? this.streakDays,
        totalTransactions: totalTransactions ?? this.totalTransactions,
        themeMode: themeMode ?? this.themeMode,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        exportStatus: exportStatus ?? this.exportStatus,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
