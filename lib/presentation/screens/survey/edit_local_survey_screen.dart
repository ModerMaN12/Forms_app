import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/question_model.dart';
import '../../../core/localization/locale_provider.dart';
import '../../providers/local_survey_provider.dart';
import '../../widgets/question_widgets/question_editor_widget.dart';

class EditLocalSurveyScreen extends ConsumerStatefulWidget {
  final String surveyId;

  const EditLocalSurveyScreen({super.key, required this.surveyId});

  @override
  ConsumerState<EditLocalSurveyScreen> createState() => _EditLocalSurveyScreenState();
}

class _EditLocalSurveyScreenState extends ConsumerState<EditLocalSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<QuestionModel> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localSurveyRepositoryProvider);
    final survey = await repo.getById(widget.surveyId);
    if (survey != null && mounted) {
      _titleController.text = survey.title;
      _descriptionController.text = survey.description;
      _questions = List.from(survey.questions);
    }
    setState(() => _loading = false);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = ref.read(appLocalizationsProvider);
    final repo = ref.read(localSurveyRepositoryProvider);
    final survey = await repo.getById(widget.surveyId);
    if (survey == null) return;

    if (survey.responseCount > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
          title: Text(l10n.warning),
          content: Text(l10n.warningResponsesLocal.replaceAll('@count', survey.responseCount.toString())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(l10n.deleteUpdate, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    await repo.update(
      id: widget.surveyId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      questions: _questions.map((q) {
        final json = q.toJson();
        json.remove('id');
        return json;
      }).toList(),
    );
    await ref.read(localSurveyProvider.notifier).loadSurveys();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsProvider);
    if (_loading) return Scaffold(appBar: AppBar(title: Text(l10n.editSurvey)), body: const Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editSurvey)),
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
                      Text('${l10n.questionsCap} (${_questions.length})', style: Theme.of(context).textTheme.titleLarge),
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
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(l10n.saveChanges),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
