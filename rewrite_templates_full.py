import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/templates/templates_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Extract prompt generator tab
prompt_idx = text.find('Widget _buildPromptGeneratorTab() {')
examples_idx = text.find('Widget _buildExamplesTab() {')
generate_idx = text.find('void _generatePrompt() {')

prompt_tab = text[prompt_idx:examples_idx].strip()
examples_tab = text[examples_idx:generate_idx].strip()
generate_method = text[generate_idx:].strip()

new_content = """import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../editor/template_editor_screen.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Template> _templates = [];
  bool _isLoading = true;

  final _promptPositionController = TextEditingController();
  final _promptCompanyController = TextEditingController();
  final _promptSkillsController = TextEditingController();
  final _promptToneController = TextEditingController();
  bool _initializedTone = false;
  String _generatedPrompt = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTone) {
      _promptToneController.text = AppLocalizations.of(context)!.promptToneDefault;
      _initializedTone = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final dao = ref.read(databaseProvider).templatesDao;
    final templates = await dao.getAllTemplates();
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptPositionController.dispose();
    _promptCompanyController.dispose();
    _promptSkillsController.dispose();
    _promptToneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.person_outline), text: 'Lebensläufe'),
              Tab(icon: Icon(Icons.mail_outline), text: 'Anschreiben'),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'KI-Workspace'),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Prompt Generator'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplatesList('lebenslauf'),
                _buildTemplatesList('anschreiben'),
                _buildKiWorkspaceTab(),
                _buildPromptGeneratorTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: (_tabController.index == 0 || _tabController.index == 1)
          ? FloatingActionButton(
              onPressed: () => _createNewTemplate(_tabController.index == 0 ? 'lebenslauf' : 'anschreiben'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTemplatesList(String type) {
    final filtered = _templates.where((t) => t.type == type).toList();
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Noch keine Dokumente', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _createNewTemplate(type),
              icon: const Icon(Icons.add),
              label: Text('Neues Dokument anlegen'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final template = filtered[index];
        IconData icon = type == 'lebenslauf' ? Icons.person_outline : Icons.mail_outline;

        return Card(
          child: ListTile(
            leading: Icon(icon, size: 32),
            title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              template.type.toUpperCase(),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTemplate(template),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteTemplate(template),
                ),
              ],
            ),
            onTap: () => _editTemplate(template),
          ),
        );
      },
    );
  }

  Widget _buildKiWorkspaceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('KI-Workspace', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Chatte mit deinem lokalen LLM.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _createNewTemplate(String type) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateEditorScreen(template: null, initialType: type))).then((_) => _loadTemplates());
  }

  void _editTemplate(Template template) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateEditorScreen(template: template))).then((_) => _loadTemplates());
  }

  void _deleteTemplate(Template template) async {
    final db = ref.read(databaseProvider);
    await db.templatesDao.deleteTemplate(template);
    _loadTemplates();
  }

"""

new_content += "  " + prompt_tab + "\n\n  " + generate_method + "\n}\n"

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(new_content)

print("Screen generated cleanly!")
