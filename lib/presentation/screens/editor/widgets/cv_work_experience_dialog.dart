import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/ai_settings_provider.dart';
import '../../../providers/ai_correction_provider.dart';
import '../../../../core/utils/spell_checker.dart';

class CvWorkExperienceDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialData;

  const CvWorkExperienceDialog({super.key, this.initialData});

  @override
  ConsumerState<CvWorkExperienceDialog> createState() => _CvWorkExperienceDialogState();
}

class _CvWorkExperienceDialogState extends ConsumerState<CvWorkExperienceDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _descriptionController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isCorrecting = false;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.initialData?['company'] ?? '');
    _positionController = TextEditingController(text: widget.initialData?['position'] ?? '');
    _descriptionController = TextEditingController(text: widget.initialData?['description'] ?? '');

    _startDate = widget.initialData?['startDate'] as DateTime?;
    _endDate = widget.initialData?['endDate'] as DateTime?;
    _isCurrent = widget.initialData?['isCurrent'] ?? false;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
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
      title: Text(widget.initialData == null ? 'Berufserfahrung hinzufügen' : 'Berufserfahrung bearbeiten'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Unternehmen'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Startdatum'),
                        child: Text(_formatDate(_startDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _isCurrent ? null : () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Enddatum',
                          enabled: !_isCurrent,
                        ),
                        child: Text(_isCurrent ? 'Bis heute' : _formatDate(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Ich arbeite aktuell hier'),
                value: _isCurrent,
                onChanged: (value) {
                  setState(() {
                    _isCurrent = value ?? false;
                    if (_isCurrent) {
                      _endDate = null;
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Beschreibung', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (isAiEnabled)
                    _isCorrecting
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                            tooltip: 'Improve with AI',
                            onPressed: _improveDescriptionWithAi,
                          ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Describe your responsibilities, achievements, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
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
              if (_startDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bitte ein Startdatum wählen')),
                );
                return;
              }
              if (!_isCurrent && _endDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bitte ein Enddatum wählen')),
                );
                return;
              }

              final result = {
                'company': _companyController.text.trim(),
                'position': _positionController.text.trim(),
                'startDate': _startDate,
                'endDate': _isCurrent ? null : _endDate,
                'isCurrent': _isCurrent,
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

