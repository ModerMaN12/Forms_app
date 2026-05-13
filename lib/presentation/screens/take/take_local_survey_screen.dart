import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/local_survey_provider.dart';
import '../../../data/models/local_response.dart';
import '../../../data/models/local_survey.dart';
import '../../widgets/question_widgets/question_display_widget.dart';

class TakeLocalSurveyScreen extends ConsumerStatefulWidget {
  final String surveyId;

  const TakeLocalSurveyScreen({super.key, required this.surveyId});

  @override
  ConsumerState<TakeLocalSurveyScreen> createState() => _TakeLocalSurveyScreenState();
}

class _TakeLocalSurveyScreenState extends ConsumerState<TakeLocalSurveyScreen> {
  LocalSurvey? _survey;
  bool _loading = true;
  final _nameController = TextEditingController();
  final Map<int, dynamic> _answers = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(localSurveyRepositoryProvider);
    final survey = await repo.getById(widget.surveyId);
    setState(() {
      _survey = survey;
      _loading = false;
    });
  }

  void _setAnswer(int questionId, dynamic value) {
    setState(() => _answers[questionId] = value);
  }

  Future<void> _submit() async {
    final survey = _survey;
    if (survey == null) return;

    for (final q in survey.questions) {
      if (q.isRequired && (_answers[q.id] == null || _answers[q.id] == '')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${q.text}" is required')),
        );
        return;
      }
    }

    setState(() => _submitting = true);

    final response = LocalResponse(
      respondentName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      answers: Map.from(_answers),
    );

    final repo = ref.read(localSurveyRepositoryProvider);
    await repo.addResponse(widget.surveyId, response);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Thank You!'),
        content: const Text('Your response has been saved locally.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_survey == null) return const Scaffold(body: Center(child: Text('Survey not found')));

    final survey = _survey!;

    return Scaffold(
      appBar: AppBar(title: Text(survey.title)),
      body: Form(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your name (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...survey.questions.map((q) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuestionDisplayWidget(
                        questionId: q.id ?? -1,
                        text: q.text,
                        type: q.questionType.value,
                        options: q.options,
                        isRequired: q.isRequired,
                        onAnswer: (v) => _setAnswer(q.id ?? -1, v),
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
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
