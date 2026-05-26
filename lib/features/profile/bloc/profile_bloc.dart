import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/services/theme_preferences.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/auth/data/auth_local_store.dart';
import '../../../features/transactions/data/transaction_repository.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_type.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required TransactionRepository repository,
    required ValueNotifier<ThemeMode> themeNotifier,
  })  : _themeNotifier = themeNotifier,
        super(ProfileState(
          themeMode: ThemePreferences.instance.themeMode,
          biometricEnabled:
              AuthLocalStore.instance.biometricEnabledForUid != null,
        )) {
    on<ProfileStarted>(_onStarted);
    on<ProfileThemeChanged>(_onThemeChanged);
    on<ProfileBiometricToggled>(_onBiometricToggled);
    on<ProfileExportPdfRequested>(_onExportPdf);
    on<ProfileExportCsvRequested>(_onExportCsv);

    _sub = repository.watchTransactions().listen((txns) {
      _txns = txns;
      add(const ProfileStarted());
    });
  }

  final ValueNotifier<ThemeMode> _themeNotifier;
  late final StreamSubscription<List<Transaction>> _sub;
  List<Transaction> _txns = const [];

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  // ─── Handlers ────────────────────────────────────────────────────────────

  void _onStarted(ProfileStarted event, Emitter<ProfileState> emit) {
    emit(state.copyWith(
      xpPoints: _txns.length * 10,
      streakDays: _computeStreak(_txns),
      totalTransactions: _txns.length,
      exportStatus: ProfileExportStatus.idle,
    ));
  }

  void _onThemeChanged(ProfileThemeChanged event, Emitter<ProfileState> emit) {
    ThemePreferences.instance.setThemeMode(event.mode);
    _themeNotifier.value = event.mode;
    emit(state.copyWith(themeMode: event.mode));
  }

  Future<void> _onBiometricToggled(
    ProfileBiometricToggled event,
    Emitter<ProfileState> emit,
  ) async {
    if (event.enabled && event.uid != null) {
      await AuthLocalStore.instance.enableBiometricFor(event.uid!);
    } else if (!event.enabled) {
      await AuthLocalStore.instance.disableBiometric();
    }
    emit(state.copyWith(biometricEnabled: event.enabled));
  }

  Future<void> _onExportPdf(
    ProfileExportPdfRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(exportStatus: ProfileExportStatus.loading));
    try {
      final sorted = List<Transaction>.from(_txns)
        ..sort((a, b) => b.date.compareTo(a.date));
      final bytes = await _buildPdf(sorted);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/finflow_statement.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          subject: 'FinFlow Statement');
      emit(state.copyWith(exportStatus: ProfileExportStatus.done));
    } catch (_) {
      emit(state.copyWith(
        exportStatus: ProfileExportStatus.error,
        errorMessage: 'PDF export failed. Please try again.',
      ));
    }
  }

  Future<void> _onExportCsv(
    ProfileExportCsvRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(exportStatus: ProfileExportStatus.loading));
    try {
      final sorted = List<Transaction>.from(_txns)
        ..sort((a, b) => b.date.compareTo(a.date));
      final rows = [
        ['Date', 'Type', 'Category', 'Merchant', 'Amount (INR)', 'Payment', 'Note'],
        for (final t in sorted)
          [
            '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-'
                '${t.date.day.toString().padLeft(2, '0')}',
            t.type.name,
            t.category.label,
            t.merchant,
            t.type == TransactionType.expense ? -t.amount : t.amount,
            t.paymentMethod.label,
            t.note ?? '',
          ],
      ];
      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/finflow_transactions.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)],
          subject: 'FinFlow Transactions');
      emit(state.copyWith(exportStatus: ProfileExportStatus.done));
    } catch (_) {
      emit(state.copyWith(
        exportStatus: ProfileExportStatus.error,
        errorMessage: 'CSV export failed. Please try again.',
      ));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  static int _computeStreak(List<Transaction> txns) {
    if (txns.isEmpty) return 0;
    final today = DateTime.now();
    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final day =
          DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final hasActivity = txns.any(
        (t) =>
            t.date.year == day.year &&
            t.date.month == day.month &&
            t.date.day == day.day,
      );
      if (!hasActivity) break;
      streak++;
    }
    return streak;
  }

  static Future<List<int>> _buildPdf(List<Transaction> txns) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final income = txns
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = txns
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);

    const accent = PdfColor(0.482, 0.431, 0.965);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'FinFlow',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
              pw.Text(
                'Transaction Statement',
                style: const pw.TextStyle(
                    fontSize: 12, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Divider(color: accent, height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: ${now.day}/${now.month}/${now.year}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
              pw.Text(
                'Income: ${formatINR(income)}  |  '
                'Expense: ${formatINR(expense)}  |  '
                'Net: ${formatINR(income - expense)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          if (txns.isEmpty)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(32),
                child: pw.Text('No transactions found.',
                    style:
                        const pw.TextStyle(color: PdfColors.grey)),
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Merchant', 'Category', 'Type', 'Amount'],
              data: txns.map((t) {
                final sign =
                    t.type == TransactionType.expense ? '-' : '+';
                return [
                  '${t.date.day}/${t.date.month}/${t.date.year}',
                  t.merchant,
                  t.category.label,
                  t.type == TransactionType.expense
                      ? 'Expense'
                      : 'Income',
                  '$sign ${formatINR(t.amount)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: accent),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignments: const {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
              },
              columnWidths: const {
                0: pw.FixedColumnWidth(55),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FixedColumnWidth(50),
                4: pw.FixedColumnWidth(65),
              },
            ),
        ],
      ),
    );
    return pdf.save();
  }
}
