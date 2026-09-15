import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignatureDialog extends StatefulWidget {
  const SignatureDialog({super.key});

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      final bytes = await _controller.toPngBytes();
      if (bytes != null) {
        final base64String = base64Encode(bytes);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_signature', base64String);
        if (mounted) Navigator.pop(context, base64String);
        return;
      }
    }
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unterschrift zeichnen'),
      content: Container(
        width: 400,
        height: 200,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Signature(
          controller: _controller,
          backgroundColor: Colors.white,
        ),
      ),
      actions: [
        TextButton(onPressed: () => _controller.clear(), child: const Text('Löschen')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        FilledButton(onPressed: _saveSignature, child: const Text('Speichern')),
      ],
    );
  }
}
