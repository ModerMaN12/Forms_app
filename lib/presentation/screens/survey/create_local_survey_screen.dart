import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/question_model.dart';
import '../../../core/localization/locale_provider.dart';
import '../../providers/local_survey_provider.dart';
import '../../widgets/question_widgets/question_editor_widget.dart';

class CreateLocalSurveyScreen extends ConsumerStatefulWidget {
  const CreateLocalSurveyScreen({super.key});

  @override
  ConsumerState<CreateLocalSurveyScreen> createState() => _CreateLocalSurveyScreenState();
}

class _CreateLocalSurveyScreenState extends ConsumerState<CreateLocalSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<QuestionModel> _questions = [];

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
          text: ref.read(appLocalizationsProvider).newQuestion,
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
    final l10n = ref.read(appLocalizationsProvider);
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addAtLeastOne)),
      );
      return;
    }

    await ref.read(localSurveyProvider.notifier).createSurvey(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          questions: _questions.map((q) {
            final json = q.toJson();
            json.remove('id');
            return json;
          }).toList(),
        );

    if (!mounted) return;
    if (ref.read(localSurveyProvider).error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(localSurveyProvider).error!)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createLocalSurvey)),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n.surveyTitle),
                    validator: (v) => v == null || v.isEmpty ? l10n.required : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: l10n.surveyDescription),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.questionsCap, style: Theme.of(context).textTheme.titleLarge),
                      PopupMenuButton<QuestionType>(
                        icon: const Icon(Icons.add_circle),
                        tooltip: l10n.addQuestion,
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
                  if (_questions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(l10n.addQuestion, style: TextStyle(color: Colors.grey[500])),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSurvey,
                  child: Text(l10n.createSurveyOffline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
