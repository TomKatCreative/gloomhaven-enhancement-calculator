import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gloomhaven_enhancement_calc/data/constants.dart';

/// A rich text editor for character notes using Flutter Quill.
///
/// Supports bold, italic, underline, headers, and ordered/unordered lists.
/// Stores content as Delta JSON format for persistence.
class RichTextNotes extends StatefulWidget {
  final String initialNotes;
  final bool isEditMode;
  final bool isReadOnly;
  final ValueChanged<String> onChanged;

  const RichTextNotes({
    super.key,
    required this.initialNotes,
    required this.isEditMode,
    required this.isReadOnly,
    required this.onChanged,
  });

  @override
  State<RichTextNotes> createState() => _RichTextNotesState();
}

class _RichTextNotesState extends State<RichTextNotes> {
  late QuillController _controller;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _controller = QuillController(
      document: _parseDocument(widget.initialNotes),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _controller.readOnly = widget.isReadOnly || !widget.isEditMode;
    _controller.addListener(_onDocumentChange);
  }

  /// Parses notes string into a Quill Document.
  ///
  /// Handles three cases:
  /// 1. Empty string → empty Document
  /// 2. Valid Delta JSON → parsed Document
  /// 3. Plain text (legacy) → Document with text inserted
  Document _parseDocument(String notes) {
    if (notes.isEmpty) {
      return Document();
    }
    try {
      final json = jsonDecode(notes);
      if (json is List) {
        return Document.fromJson(json);
      }
    } catch (_) {
      // Not valid JSON, treat as plain text
    }
    // Fallback: treat as plain text (legacy notes)
    final doc = Document();
    doc.insert(0, notes);
    return doc;
  }

  void _onDocumentChange() {
    final delta = _controller.document.toDelta().toJson();
    widget.onChanged(jsonEncode(delta));
  }

  @override
  void didUpdateWidget(RichTextNotes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update read-only state when edit mode changes
    _controller.readOnly = widget.isReadOnly || !widget.isEditMode;
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChange);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _requestFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isEditMode && !widget.isReadOnly) {
      return GestureDetector(
        onTap: _requestFocus,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toolbar
              QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  toolbarIconAlignment: WrapAlignment.spaceEvenly,
                  showDividers: false,
                  multiRowsDisplay: false,
                  // Hide unused buttons
                  showStrikeThrough: false,
                  showBackgroundColorButton: false,
                  showClearFormat: false,
                  showCodeBlock: false,
                  showQuote: false,
                  showLink: false,
                  showSearchButton: false,
                  showInlineCode: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showAlignmentButtons: true,
                  showIndent: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showClipboardCut: false,
                  showClipboardCopy: false,
                  showClipboardPaste: false,
                  showUndo: true,
                  showRedo: true,
                ),
              ),
              const Divider(height: 1),
              // Editor
              Padding(
                padding: const EdgeInsets.all(smallPadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 100),
                  child: QuillEditor(
                    controller: _controller,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: QuillEditorConfig(
                      placeholder: 'Items, reminders, wishlist...',
                      autoFocus: false,
                      expands: false,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // View mode: read-only display
    if (_isDocumentEmpty()) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      // color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(mediumPadding),
        child: QuillEditor.basic(controller: _controller),
      ),
    );
  }

  /// Checks if the document is effectively empty (just a newline).
  bool _isDocumentEmpty() {
    final plainText = _controller.document.toPlainText();
    return plainText.trim().isEmpty;
  }
}
