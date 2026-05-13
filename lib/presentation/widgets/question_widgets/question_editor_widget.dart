import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/question_model.dart';
import '../../../core/localization/locale_provider.dart';

class QuestionEditorWidget extends ConsumerStatefulWidget {
  final QuestionModel question;
  final int index;
  final int totalQuestions;
  final Function(QuestionModel) onUpdate;
  final VoidCallback onRemove;
  final Function(bool up) onMove;

  const QuestionEditorWidget({
    super.key,
    required this.question,
    required this.index,
    required this.totalQuestions,
    required this.onUpdate,
    required this.onRemove,
    required this.onMove,
  });

  @override
  ConsumerState<QuestionEditorWidget> createState() => _QuestionEditorWidgetState();
}

class _QuestionEditorWidgetState extends ConsumerState<QuestionEditorWidget> {
  late TextEditingController _textController;
  late List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _optionControllers = (widget.question.options ?? [])
        .map((o) => TextEditingController(text: o))
        .toList();
  }

  @override
  void dispose() {
    _textController.dispose();
    for (var c in _optionControllers) c.dispose();
    super.dispose();
  }

  void _updateText(String value) {
    widget.onUpdate(widget.question.copyWith(text: value));
  }

  void _updateOption(int index, String value) {
    final newOptions = List<String>.from(widget.question.options ?? []);
    if (index < newOptions.length) newOptions[index] = value;
    widget.onUpdate(widget.question.copyWith(options: newOptions));
  }

  void _addOption() {
    final l10n = ref.read(appLocalizationsProvider);
    final newOptions = List<String>.from(widget.question.options ?? [])..add('${l10n.option} ${_optionControllers.length + 1}');
    setState(() {
      _optionControllers.add(TextEditingController(text: newOptions.last));
    });
    widget.onUpdate(widget.question.copyWith(options: newOptions));
  }

  void _removeOption(int index) {
    if ((widget.question.options?.length ?? 0) <= 2) return;
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
    final newOptions = List<String>.from(widget.question.options ?? [])..removeAt(index);
    widget.onUpdate(widget.question.copyWith(options: newOptions));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsProvider);
    final needsOptions = widget.question.questionType == QuestionType.singleChoice ||
        widget.question.questionType == QuestionType.multipleChoice;

    String typeName(String type) {
      switch (type) {
        case 'single_choice': return l10n.singleChoice;
        case 'multiple_choice': return l10n.multipleChoice;
        case 'text': return l10n.textQuestion;
        case 'rating': return l10n.rating;
        case 'scale': return l10n.scale;
        default: return type;
      }
    }

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(child: Text('${widget.index + 1}')),
        title: TextField(
          controller: _textController,
          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: _updateText,
        ),
        subtitle: Text(typeName(widget.question.questionType.value),
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.index > 0)
              IconButton(icon: const Icon(Icons.arrow_upward, size: 20), onPressed: () => widget.onMove(true)),
            if (widget.index < widget.totalQuestions - 1)
              IconButton(icon: const Icon(Icons.arrow_downward, size: 20), onPressed: () => widget.onMove(false)),
            Switch(
              value: widget.question.isRequired,
              onChanged: (v) => widget.onUpdate(widget.question.copyWith(isRequired: v)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onRemove,
            ),
          ],
        ),
        children: [
          if (needsOptions) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ..._optionControllers.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            widget.question.questionType == QuestionType.singleChoice
                                ? Icons.radio_button_unchecked
                                : Icons.check_box_outline_blank,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: e.value,
                              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                              onChanged: (v) => _updateOption(e.key, v),
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                              onPressed: () => _removeOption(e.key),
                            ),
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addOption),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
