import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_umkm/utils/enums.dart';
import 'package:aplikasi_umkm/utils/filter_result.dart';

class PeriodeFilterSheet extends StatefulWidget {
  final FilterResult initialFilter;

  const PeriodeFilterSheet({super.key, required this.initialFilter});

  @override
  State<PeriodeFilterSheet> createState() => _PeriodeFilterSheetState();
}

class _PeriodeFilterSheetState extends State<PeriodeFilterSheet> {
  late PeriodeWaktu _selectedPeriode;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _selectedPeriode = widget.initialFilter.periode;
    _startDate = widget.initialFilter.dateRange.start;
    _endDate = widget.initialFilter.dateRange.end;
  }

  void _updateDatesForPreset(PeriodeWaktu periode) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (periode) {
      case PeriodeWaktu.hariIni:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case PeriodeWaktu.mingguIni:
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case PeriodeWaktu.bulanIni:
        start = DateTime(now.year, now.month, 1);
        break;
      case PeriodeWaktu.tahunIni:
        start = DateTime(now.year, 1, 1);
        break;
      default:
        return;
    }
    setState(() {
      _selectedPeriode = periode;
      _startDate = start;
      _endDate = end;
    });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        // Jika tanggal kustom dipilih, ubah periode menjadi 'custom'
        _selectedPeriode = PeriodeWaktu.custom;
      });
    }
  }

  void _applyFilter() {
    final result = FilterResult(
      periode: _selectedPeriode,
      dateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Periode Waktu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: PeriodeWaktu.values.where((p) => p != PeriodeWaktu.custom).map((periode) {
              final isSelected = _selectedPeriode == periode;
              return ElevatedButton(
                onPressed: () => _updateDatesForPreset(periode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: Text(periode.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim()),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildDateSelector("Mulai Tanggal", _startDate, () => _selectDate(true)),
          const SizedBox(height: 16),
          _buildDateSelector("Hingga", _endDate, () => _selectDate(false)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _applyFilter,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text("Gunakan"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(date)),
                const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}