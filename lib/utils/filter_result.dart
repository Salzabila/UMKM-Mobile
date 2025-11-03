import 'package:flutter/material.dart';
import 'package:aplikasi_umkm/utils/enums.dart';

class FilterResult {
  final PeriodeWaktu periode;
  final DateTimeRange dateRange;

  FilterResult({required this.periode, required this.dateRange});
}