import 'package:flutter/material.dart';

class QuestionDisplayWidget extends StatefulWidget {
  final int questionId;
  final String text;
  final String type;
  final List<String>? options;
  final bool isRequired;
  final Function(dynamic) onAnswer;

  const QuestionDisplayWidget({
    super.key,
    required this.questionId,
    required this.text,
    required this.type,
    this.options,
    this.isRequired = true,
    required this.onAnswer,
  });

  @override
  State<QuestionDisplayWidget> createState() => _QuestionDisplayWidgetState();
}

class _QuestionDisplayWidgetState extends State<QuestionDisplayWidget> {
  String? _selectedChoice;
  final Set<String> _selectedChoices = {};
  int _rating = 0;
  int _scale = 0;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.text, style: Theme.of(context).textTheme.titleMedium),
                ),
                if (widget.isRequired) const Icon(Icons.star, color: Colors.amber, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    switch (widget.type) {
      case 'single_choice':
        return Column(
          children: (widget.options ?? []).map((opt) {
            return RadioListTile<String>(
              title: Text(opt),
              value: opt,
              groupValue: _selectedChoice,
              onChanged: (v) {
                setState(() => _selectedChoice = v);
                widget.onAnswer(v);
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );

      case 'multiple_choice':
        return Column(
          children: (widget.options ?? []).map((opt) {
            return CheckboxListTile(
              title: Text(opt),
              value: _selectedChoices.contains(opt),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedChoices.add(opt);
                  } else {
                    _selectedChoices.remove(opt);
                  }
                });
                widget.onAnswer(_selectedChoices.toList());
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        );

      case 'text':
        return TextField(
          controller: _textController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type your answer...',
          ),
          onChanged: (v) => widget.onAnswer(v),
        );

      case 'rating':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 36,
              ),
              onPressed: () {
                setState(() => _rating = i + 1);
                widget.onAnswer(i + 1);
              },
            );
          }),
        );

      case 'scale':
        return Wrap(
          spacing: 8,
          children: List.generate(10, (i) {
            final num = i + 1;
            final isSelected = _scale == num;
            return InkWell(
              onTap: () {
                setState(() => _scale = num);
                widget.onAnswer(num);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$num',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        );

      default:
        return const Text('Unknown question type');
    }
  }
}
