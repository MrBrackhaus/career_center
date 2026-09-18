import 'package:flutter/material.dart';

class CvCustomItemDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CvCustomItemDialog({super.key, this.initialData});

  @override
  State<CvCustomItemDialog> createState() => _CvCustomItemDialogState();
}

class _CvCustomItemDialogState extends State<CvCustomItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _sectionNameCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _dateRangeCtrl;
  late TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    _sectionNameCtrl = TextEditingController(text: widget.initialData?['sectionName'] ?? '');
    _titleCtrl = TextEditingController(text: widget.initialData?['title'] ?? '');
    _subtitleCtrl = TextEditingController(text: widget.initialData?['subtitle'] ?? '');
    _dateRangeCtrl = TextEditingController(text: widget.initialData?['dateRange'] ?? '');
    _descriptionCtrl = TextEditingController(text: widget.initialData?['description'] ?? '');
  }

  @override
  void dispose() {
    _sectionNameCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _dateRangeCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Abschnitt hinzufügen' : 'Abschnitt bearbeiten'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _sectionNameCtrl,
                decoration: const InputDecoration(labelText: 'Abschnittsname (z.B. Zertifikate, Hobbys)'),
                validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titel'),
                validator: (v) => v == null || v.isEmpty ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subtitleCtrl,
                decoration: const InputDecoration(labelText: 'Untertitel (optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateRangeCtrl,
                decoration: const InputDecoration(labelText: 'Datum / Zeitraum (optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Beschreibung (optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'sectionName': _sectionNameCtrl.text.trim(),
                'title': _titleCtrl.text.trim(),
                'subtitle': _subtitleCtrl.text.trim(),
                'dateRange': _dateRangeCtrl.text.trim(),
                'description': _descriptionCtrl.text.trim(),
              });
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
