import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/survey_model.dart';
import '../../../data/models/question_model.dart';
import '../../providers/survey_provider.dart';
import '../../widgets/question_widgets/question_editor_widget.dart';

class EditSurveyScreen extends ConsumerStatefulWidget {
  final SurveyModel survey;

  const EditSurveyScreen({super.key, required this.survey});

  @override
  ConsumerState<EditSurveyScreen> createState() => _EditSurveyScreenState();
}

class _EditSurveyScreenState extends ConsumerState<EditSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late AccessType _accessType;
  late List<QuestionModel> _questions;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.survey.title);
    _descriptionController = TextEditingController(text: widget.survey.description);
    _accessType = widget.survey.accessType;
    _questions = List.from(widget.survey.questions);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addQuestion(QuestionType type) {
    setState(() {
      _questions.add(
        QuestionModel(
          text: 'New Question',
          questionType: type,
          options: (type == QuestionType.singleChoice || type == QuestionType.multipleChoice)
              ? ['Option 1', 'Option 2']
              : null,
          order: _questions.length,
        ),
      );
    });
  }

  void _updateQuestion(int index, QuestionModel question) {
    setState(() => _questions[index] = question);
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      for (int i = 0; i < _questions.length; i++) {
        _questions[i] = _questions[i].copyWith(order: i);
      }
    });
  }

  void _moveQuestion(int index, bool up) {
    setState(() {
      if (up && index > 0) {
        final temp = _questions[index];
        _questions[index] = _questions[index - 1];
        _questions[index - 1] = temp;
      } else if (!up && index < _questions.length - 1) {
        final temp = _questions[index];
        _questions[index] = _questions[index + 1];
        _questions[index + 1] = temp;
      }
      for (int i = 0; i < _questions.length; i++) {
        _questions[i] = _questions[i].copyWith(order: i);
      }
    });
  }

  Future<void> _saveSurvey() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.survey.responseCount > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
          title: const Text('Warning!'),
          content: const Text(
            'This survey already has responses. Editing questions will DELETE all previous responses. Continue?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Delete & Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    await ref.read(surveyProvider.notifier).updateSurvey(
          surveyId: widget.survey.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          accessType: _accessType.value,
          questions: _questions.map((q) => q.toJson()).toList(),
        );

    if (!mounted) return;
    if (ref.read(surveyProvider).error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(surveyProvider).error!)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit: ${widget.survey.title}')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.survey.responseCount > 0)
                    Card(
                      color: Colors.orange.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Has ${widget.survey.responseCount} responses. Changing questions will delete them.',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.survey.responseCount > 0) const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Survey Title'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AccessType>(
                    initialValue: _accessType,
                    decoration: const InputDecoration(labelText: 'Access Type'),
                    items: AccessType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.displayName));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _accessType = v);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Questions (${_questions.length})', style: Theme.of(context).textTheme.titleLarge),
                      PopupMenuButton<QuestionType>(
                        icon: const Icon(Icons.add_circle),
                        onSelected: _addQuestion,
                        itemBuilder: (_) => QuestionType.values.map((t) {
                          return PopupMenuItem(value: t, child: Text(t.displayName));
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._questions.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuestionEditorWidget(
                        question: e.value,
                        index: e.key,
                        totalQuestions: _questions.length,
                        onUpdate: (q) => _updateQuestion(e.key, q),
                        onRemove: () => _removeQuestion(e.key),
                        onMove: (up) => _moveQuestion(e.key, up),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSurvey,
                  child: const Text('Save Changes'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
