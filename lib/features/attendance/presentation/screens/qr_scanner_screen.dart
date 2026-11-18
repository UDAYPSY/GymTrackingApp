import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/core/theme/app_theme.dart';
import 'package:gym_manager/features/members/repositories/member_repository.dart';
import 'package:gym_manager/features/attendance/repositories/attendance_repository.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? scannedCode = barcodes.first.rawValue;
    if (scannedCode == null || scannedCode.isEmpty) return;

    setState(() => _isProcessing = true);

    final membersAsync = ref.read(membersStreamProvider);
    final members = membersAsync.value ?? [];

    final member = members.firstWhere(
      (m) => m.memberCode.toLowerCase() == scannedCode.toLowerCase(),
      orElse: () => members.firstWhere(
        (m) => m.name.toLowerCase() == scannedCode.toLowerCase(),
        orElse: () => members.first,
      ),
    );

    // Check if membership has expired
    if (member.hasExpired) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: AppTheme.error),
                SizedBox(width: 8),
                Text('Plan Expired!'),
              ],
            ),
            content: Text(
              'Member ${member.name} (${member.memberCode}) has an EXPIRED membership.\n\nPlease collect dues or renew membership before permitting entry.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _isProcessing = false);
                },
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Record check-in
    await ref.read(attendanceRepositoryProvider).markAttendance(
          memberId: member.id,
          memberName: member.name,
          memberCode: member.memberCode,
          method: AttendanceMethod.qrScan,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in logged for ${member.name}!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Member QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scanning overlay frame
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primary, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Align Member QR Code inside the frame',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
