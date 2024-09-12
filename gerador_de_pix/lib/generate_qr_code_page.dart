import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'util.dart';

class GenerateQrCodePage extends StatefulWidget {
  const GenerateQrCodePage({super.key});

  @override
  _GenerateQrCodePageState createState() => _GenerateQrCodePageState();
}

class _GenerateQrCodePageState extends State<GenerateQrCodePage> {
  final TextEditingController _pixController = TextEditingController();
  String? _qrData;

  void _generateQrCode() {
    double? amount = double.tryParse(_pixController.text.replaceAll(',', '.'));
    if (amount != null) {
      String pixCode = generatePixCode(amount);
      setState(() {
        _qrData = pixCode;
      });
    }
  }

  void _setAndGenerateQrCode(double amount) {
    _pixController.text = amount.toStringAsFixed(2).replaceAll('.', ',');
    _generateQrCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar QR Code'),
        backgroundColor: Colors.black12,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                controller: _pixController,
                decoration: const InputDecoration(
                  labelText: 'Valor do Pix',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+,?\d*$')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _setAndGenerateQrCode(1.00),
                    child: const Text('1,00'),
                  ),
                  ElevatedButton(
                    onPressed: () => _setAndGenerateQrCode(5.00),
                    child: const Text('5,00'),
                  ),
                  ElevatedButton(
                    onPressed: () => _setAndGenerateQrCode(10.00),
                    child: const Text('10,00'),
                  ),
                  ElevatedButton(
                    onPressed: () => _setAndGenerateQrCode(50.00),
                    child: const Text('50,00'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _generateQrCode,
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Gerar QR Code'),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: _qrData != null
                    ? QrImageView(
                        data: _qrData!,
                        size: 200.0,
                        backgroundColor: Colors.white,
                      )
                    : const Text('Nenhum código gerado ainda'),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: _qrData),
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _qrData ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Texto copiado para a área de transferência'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
