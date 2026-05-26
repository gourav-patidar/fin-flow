import 'package:flutter/material.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

final class ProfileThemeChanged extends ProfileEvent {
  const ProfileThemeChanged(this.mode);
  final ThemeMode mode;
}

final class ProfileBiometricToggled extends ProfileEvent {
  const ProfileBiometricToggled({required this.enabled, this.uid});
  final bool enabled;
  final String? uid;
}

final class ProfileExportPdfRequested extends ProfileEvent {
  const ProfileExportPdfRequested();
}

final class ProfileExportCsvRequested extends ProfileEvent {
  const ProfileExportCsvRequested();
}
