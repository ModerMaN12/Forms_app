import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../data/models/local_survey.dart';
import '../../providers/local_survey_provider.dart';
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
    final l10n = ref.watch(appLocalizationsProvider);

    if (_loading) return Scaffold(body: const Center(child: CircularProgressIndicator()));
    if (_survey == null) return Scaffold(body: Center(child: Text(l10n.surveyNotFound)));

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
                  Text(l10n.description, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(survey.description.isEmpty ? l10n.noDescription : survey.description),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('${l10n.status}: ', style: Theme.of(context).textTheme.titleSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(l10n.offline, style: const TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${l10n.responsesCap}: ${survey.responseCount}', style: Theme.of(context).textTheme.titleSmall),
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
                    MaterialPageRoute(builder: (_) => TakeLocalSurveyScreen(surveyId: survey.id)),
                  ).then((_) => _load()),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.takeSurvey),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LocalResultsScreen(surveyId: survey.id)),
                  ),
                  icon: const Icon(Icons.bar_chart),
                  label: Text(l10n.results),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('${l10n.questionsCap} (${survey.questions.length})', style: Theme.of(context).textTheme.titleMedium),
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
    final l10n = ref.read(appLocalizationsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteSurveyLocalConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(localSurveyProvider.notifier).deleteSurvey(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
