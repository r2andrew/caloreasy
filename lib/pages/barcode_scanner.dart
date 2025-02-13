// credit:
// https://github.com/juliansteenbakker/mobile_scanner/blob/develop/example/README.md

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {

  final _mobileScannerController = MobileScannerController(
    autoStart: false
  );

  // on this subscription, receive barcode
  StreamSubscription<Object?>? _subscription;

  // used to prevent multiple pops
  var _validBarcodeFound = false;

  @override
  void initState() {
    // lock to portrait
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // listen for barcode
    _subscription = _mobileScannerController.barcodes.listen(_handleBarcodes);

    super.initState();

    // start controller to start scanning
    unawaited(_mobileScannerController.start());
  }

  @override
  void dispose() {

    // Cancel the stream subscription.
    unawaited(_subscription?.cancel());

    _subscription = null;

    super.dispose();

    // Dispose the controller.
    _mobileScannerController.dispose();
  }

  void _handleBarcodes(BarcodeCapture barcodeCapture) {
    // Discard all events when the scanner is disabled or when already a valid
    // barcode is found.
    if (_validBarcodeFound) {
      return;
    }
    for(Barcode barcode in barcodeCapture.barcodes) {
      _validBarcodeFound = true;
      Navigator.of(context).pop(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _mobileScannerController,
            fit: BoxFit.contain,
          )
        ],
      )
    );
  }
}
