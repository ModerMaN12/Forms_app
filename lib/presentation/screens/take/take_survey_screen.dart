import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/response_repository.dart';
import '../../../data/repositories/providers.dart';
import '../../../core/localization/locale_provider.dart';
import '../../widgets/question_widgets/question_display_widget.dart';

class TakeSurveyScreen extends ConsumerStatefulWidget {
  final int surveyId;
  final String surveyTitle;

  const TakeSurveyScreen({super.key, required this.surveyId, required this.surveyTitle});

  @override
  ConsumerState<TakeSurveyScreen> createState() => _TakeSurveyScreenState();
}

class _TakeSurveyScreenState extends ConsumerState<TakeSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Map<int, dynamic> _answers = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setAnswer(int questionId, dynamic value) {
    setState(() => _answers[questionId] = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final answers = _answers.entries.map((e) {
      return {'question_id': e.key, 'value': e.value};
    }).toList();

    try {
      final repo = ResponseRepository(dio: ref.read(dioProvider));
      await repo.submitResponse(
        surveyId: widget.surveyId,
        respondentName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        answers: answers,
      );
      if (!mounted) return;
      final l10n = ref.read(appLocalizationsProvider);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: Text(l10n.thankYou),
          content: Text(l10n.responseSubmitted),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.surveyTitle)),
      body: Form(
        key: _formKey,
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
                        decoration: InputDecoration(
                          labelText: l10n.yourNameOptional,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(3, (index) {
                    final qId = index + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QuestionDisplayWidget(
                        questionId: qId,
                        text: 'Question $qId',
                        type: 'single_choice',
                        options: ['Option A', 'Option B', 'Option C'],
                        isRequired: true,
                        onAnswer: (v) => _setAnswer(qId, v),
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
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.submit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
