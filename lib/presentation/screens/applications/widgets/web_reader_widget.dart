/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

/// Widget das heruntergeladenen HTML-Content als lesbaren, selektierbaren Text anzeigt.
/// Dient als "Reader Mode" für Websites in der Split-View.
class WebReaderWidget extends StatelessWidget {
  final String htmlContent;
  final String? url;
  final ValueChanged<String>? onTextSelected;

  const WebReaderWidget({
    super.key,
    required this.htmlContent,
    this.url,
    this.onTextSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parsedText = _parseHtmlToText(htmlContent);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    url ?? 'Website-Vorschau',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SelectionArea(
              onSelectionChanged: (value) {
                // Selection changed callback is handled via the contextual menu
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  parsedText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: colorScheme.onSurface,
                  ),
                  contextMenuBuilder: (context, editableTextState) {
                    final selectedText = editableTextState
                        .textEditingValue
                        .selection
                        .textInside(editableTextState.textEditingValue.text);

                    return AdaptiveTextSelectionToolbar.buttonItems(
                      anchors: editableTextState.contextMenuAnchors,
                      buttonItems: [
                        if (selectedText.isNotEmpty && onTextSelected != null)
                          ContextMenuButtonItem(
                            label: '📋 In Feld übernehmen',
                            onPressed: () {
                              onTextSelected!(selectedText.trim());
                              editableTextState.hideToolbar();
                            },
                          ),
                        ...editableTextState.contextMenuButtonItems,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parst HTML in lesbaren Plaintext mit Absätzen und Überschriften.
  String _parseHtmlToText(String html) {
    try {
      final document = html_parser.parse(html);
      final body = document.body;
      if (body == null) return html;

      final buffer = StringBuffer();
      _walkNodes(body, buffer);

      // Clean up multiple newlines
      return buffer.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    } catch (e) {
      return html;
    }
  }

  void _walkNodes(dom.Node node, StringBuffer buffer) {
    if (node is dom.Text) {
      final text = node.text.replaceAll(RegExp(r'\s+'), ' ');
      if (text.trim().isNotEmpty) {
        buffer.write(text);
      }
      return;
    }

    if (node is dom.Element) {
      final tag = node.localName?.toLowerCase() ?? '';

      // Skip invisible elements
      if (tag == 'script' ||
          tag == 'style' ||
          tag == 'noscript' ||
          tag == 'nav' ||
          tag == 'footer') {
        return;
      }

      // Add newlines before block elements
      if ([
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
        'p',
        'div',
        'br',
        'li',
        'tr',
        'section',
        'article',
      ].contains(tag)) {
        buffer.write('\n');
      }

      // Add heading markers
      if (tag.startsWith('h') && tag.length == 2) {
        buffer.write('\n━━━ ');
      }

      for (final child in node.nodes) {
        _walkNodes(child, buffer);
      }

      // Close headings
      if (tag.startsWith('h') && tag.length == 2) {
        buffer.write(' ━━━\n');
      }

      // Add newlines after block elements
      if (['p', 'div', 'br', 'li', 'tr', 'section', 'article'].contains(tag)) {
        buffer.write('\n');
      }

      // List items
      if (tag == 'li') {
        // Prefix handled by the newline above
      }
    }
  }
}
