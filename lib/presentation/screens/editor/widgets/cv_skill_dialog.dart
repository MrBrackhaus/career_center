import 'package:flutter/material.dart';

class CvSkillDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CvSkillDialog({super.key, this.initialData});

  @override
  State<CvSkillDialog> createState() => _CvSkillDialogState();
}

class _CvSkillDialogState extends State<CvSkillDialog> {
  late TextEditingController _nameController;
  double _level = 3;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _level = (widget.initialData?['level'] as num?)?.toDouble() ?? 3.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      return;
    }
    
    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'level': _level.toInt(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Skill'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name der Fähigkeit',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Level: '),
                Expanded(
                  child: Slider(
                    value: _level,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _level.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _level = value;
                      });
                    },
                  ),
                ),
                Text(_level.toInt().toString()),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
