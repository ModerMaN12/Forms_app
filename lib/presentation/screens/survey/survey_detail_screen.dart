import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/survey_model.dart';
import '../../providers/survey_provider.dart';
import 'edit_survey_screen.dart';
import '../results/results_screen.dart';

class SurveyDetailScreen extends ConsumerWidget {
  final SurveyModel survey;

  const SurveyDetailScreen({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(survey.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditSurveyScreen(survey: survey),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 16),
          _buildActions(context, ref),
          const SizedBox(height: 24),
          Text('Questions (${survey.questions.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...survey.questions.asMap().entries.map((e) => _buildQuestionItem(context, e.value, e.key + 1)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(survey.description.isEmpty ? 'No description' : survey.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Access: ', style: Theme.of(context).textTheme.titleSmall),
                Text(survey.accessType.displayName),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Status: ', style: Theme.of(context).textTheme.titleSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: survey.isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    survey.isActive ? 'Active' : 'Draft',
                    style: TextStyle(color: survey.isActive ? Colors.green : Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Responses: ${survey.responseCount}', style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (!survey.isActive)
          ElevatedButton.icon(
            onPressed: () {
              ref.read(surveyProvider.notifier).publishSurvey(survey.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Survey published!')),
              );
            },
            icon: const Icon(Icons.public),
            label: const Text('Publish'),
          ),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResultsScreen(surveyId: survey.id, surveyTitle: survey.title)),
          ),
          icon: const Icon(Icons.bar_chart),
          label: const Text('Results'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            final url = 'http://localhost:8000/s/${survey.id}';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Share link: $url')),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Share Link'),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(BuildContext context, dynamic question, int number) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('$number')),
        title: Text(question.text),
        subtitle: Text(question.questionType.displayName),
        trailing: Icon(question.isRequired ? Icons.star : Icons.star_border, color: Colors.amber),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Survey'),
        content: const Text('Are you sure? This will delete all responses too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(surveyProvider.notifier).deleteSurvey(survey.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
