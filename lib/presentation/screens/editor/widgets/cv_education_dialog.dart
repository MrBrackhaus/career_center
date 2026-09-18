import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/ai_settings_provider.dart';
import '../../../providers/ai_correction_provider.dart';
import '../../../../core/utils/spell_checker.dart';

class CvEducationDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;

  const CvEducationDialog({super.key, this.initialData});

  @override
  ConsumerState<CvEducationDialog> createState() => _CvEducationDialogState();
}

class _CvEducationDialogState extends ConsumerState<CvEducationDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _institutionController;
  late TextEditingController _degreeController;
  late TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCorrecting = false;

  @override
  void initState() {
    super.initState();
    _institutionController = TextEditingController(text: widget.initialData?['institution'] ?? '');
    _degreeController = TextEditingController(text: widget.initialData?['degree'] ?? '');
    _descriptionController = TextEditingController(text: widget.initialData?['description'] ?? '');

    _startDate = widget.initialData?['startDate'] as DateTime?;
    _endDate = widget.initialData?['endDate'] as DateTime?;
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _degreeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _improveDescriptionWithAi() async {
    if (_descriptionController.text.trim().isEmpty) return;

    setState(() {
      _isCorrecting = true;
    });

    try {
      final lang = SpellChecker.currentLanguage;
      final correctedText = await ref.read(aiCorrectionProvider.notifier).correctText(_descriptionController.text, lang);
      if (correctedText != null) {
        setState(() {
          _descriptionController.text = correctedText;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler bei der KI-Korrektur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCorrecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiSettings = ref.watch(aiSettingsProvider).value;
    final isAiEnabled = aiSettings?.isAiEnabled ?? false;

    return AlertDialog(
      title: Text(widget.initialData == null ? 'Ausbildung hinzufügen' : 'Ausbildung bearbeiten'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(labelText: 'Institution', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(labelText: 'Degree', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Startdatum', border: OutlineInputBorder()),
                        child: Text(_formatDate(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Enddatum', border: OutlineInputBorder()),
                        child: Text(_formatDate(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Description (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (isAiEnabled)
                    _isCorrecting
                        ? const CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                            tooltip: 'Improve with AI',
                            onPressed: _improveDescriptionWithAi,
                          ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Describe your studies', border: OutlineInputBorder()),
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_startDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte ein Startdatum wählen')));
                return;
              }
              final result = {
                'institution': _institutionController.text.trim(),
                'degree': _degreeController.text.trim(),
                'startDate': _startDate,
                'endDate': _endDate,
                'description': _descriptionController.text.trim(),
              };
              Navigator.pop(context, result);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
