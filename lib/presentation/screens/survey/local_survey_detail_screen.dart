import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/local_survey_provider.dart';
import '../../../data/models/local_survey.dart';
import 'edit_local_survey_screen.dart';
import '../take/take_local_survey_screen.dart';
import '../results/local_results_screen.dart';

class LocalSurveyDetailScreen extends ConsumerStatefulWidget {
  final String surveyId;

  const LocalSurveyDetailScreen({super.key, required this.surveyId});

  @override
  ConsumerState<LocalSurveyDetailScreen> createState() => _LocalSurveyDetailScreenState();
}

class _LocalSurveyDetailScreenState extends ConsumerState<LocalSurveyDetailScreen> {
  LocalSurvey? _survey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(localSurveyRepositoryProvider);
    final survey = await repo.getById(widget.surveyId);
    setState(() {
      _survey = survey;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_survey == null) return const Scaffold(body: Center(child: Text('Survey not found')));

    final survey = _survey!;

    return Scaffold(
      appBar: AppBar(
        title: Text(survey.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditLocalSurveyScreen(surveyId: survey.id)),
            ).then((_) => _load()),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, survey.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(survey.description.isEmpty ? 'No description' : survey.description),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Status: ', style: Theme.of(context).textTheme.titleSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Offline', style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Responses: ${survey.responseCount}', style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TakeLocalSurveyScreen(surveyId: survey.id),
                    ),
                  ).then((_) => _load()),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Take Survey'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocalResultsScreen(surveyId: survey.id),
                    ),
                  ),
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Results'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Questions (${survey.questions.length})', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...survey.questions.asMap().entries.map((e) {
            final q = e.value;
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${e.key + 1}')),
                title: Text(q.text),
                subtitle: Text(q.questionType.displayName),
                trailing: Icon(q.isRequired ? Icons.star : Icons.star_border, color: Colors.amber),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Survey'),
        content: const Text('Delete this local survey and all its responses?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(localSurveyProvider.notifier).deleteSurvey(id);
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
