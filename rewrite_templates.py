import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/templates/templates_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Replace tabs definition
text = text.replace(
'''          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.description), text: AppLocalizations.of(context)!.templatesTabMy),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Prompt Generator'),
              Tab(icon: Icon(Icons.library_books), text: AppLocalizations.of(context)!.templatesTabExamples),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplatesTab(),
                _buildPromptGeneratorTab(),
                _buildExamplesTab(),
              ],
            ),
          ),''',
'''          TabBar(
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
          ),''')

text = text.replace('TabController(length: 3', 'TabController(length: 4')

# Replace FAB
text = text.replace(
'''      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _createNewTemplate,
              child: const Icon(Icons.add),
            )
          : null,''',
'''      floatingActionButton: (_tabController.index == 0 || _tabController.index == 1)
          ? FloatingActionButton(
              onPressed: () => _createNewTemplate(_tabController.index == 0 ? 'lebenslauf' : 'anschreiben'),
              child: const Icon(Icons.add),
            )
          : null,''')

# Add listener to TabController to rebuild FAB
text = text.replace('_tabController = TabController(length: 4, vsync: this);\n    _loadTemplates();',
'''_tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadTemplates();''')

# Replace _buildTemplatesTab with _buildTemplatesList
text = text.replace('  Widget _buildTemplatesTab() {', '  Widget _buildTemplatesList(String type) {\n    final filtered = _templates.where((t) => t.type == type).toList();')

# Fix _templates inside _buildTemplatesList
text = text.replace('if (_templates.isEmpty) {', 'if (filtered.isEmpty) {')
text = text.replace('itemCount: _templates.length,', 'itemCount: filtered.length,')
text = text.replace('final template = _templates[index];', 'final template = filtered[index];')
text = text.replace('onPressed: _createNewTemplate,', 'onPressed: () => _createNewTemplate(type),')

# Replace _createNewTemplate method
text = text.replace(
'''  void _createNewTemplate() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplateEditorScreen(template: null))).then((_) => _loadTemplates());
  }''',
'''  void _createNewTemplate(String type) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TemplateEditorScreen(template: null, initialType: type))).then((_) => _loadTemplates());
  }''')

# Insert _buildKiWorkspaceTab right before _buildPromptGeneratorTab
ki_tab = '''
  Widget _buildKiWorkspaceTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('KI-Workspace', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Chatte mit deinem lokalen LLM (in Entwicklung).', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
'''
text = text.replace('  Widget _buildPromptGeneratorTab() {', ki_tab + '  Widget _buildPromptGeneratorTab() {')

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("Screen refactored correctly!")
