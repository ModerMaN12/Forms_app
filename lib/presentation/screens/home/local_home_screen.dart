import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/local_survey_provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../survey/create_local_survey_screen.dart';
import '../survey/local_survey_detail_screen.dart';

class LocalHomeScreen extends ConsumerStatefulWidget {
  const LocalHomeScreen({super.key});

  @override
  ConsumerState<LocalHomeScreen> createState() => _LocalHomeScreenState();
}

class _LocalHomeScreenState extends ConsumerState<LocalHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(localSurveyProvider.notifier).loadSurveys());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appLocalizationsProvider);
    final state = ref.watch(localSurveyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.localSurveys),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.back,
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateLocalSurveyScreen()),
        ).then((_) => ref.read(localSurveyProvider.notifier).loadSurveys()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(state) {
    final l10n = ref.watch(appLocalizationsProvider);

    if (state.isLoading && state.surveys.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(localSurveyProvider.notifier).loadSurveys(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state.surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.create, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(l10n.noLocalSurveys, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[500])),
            const SizedBox(height: 8),
            Text(l10n.createLocalSurveyHint, style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(localSurveyProvider.notifier).loadSurveys(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.surveys.length,
        itemBuilder: (context, index) {
          final survey = state.surveys[index];
          return _buildSurveyCard(context, l10n, survey);
        },
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, l10n, survey) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LocalSurveyDetailScreen(surveyId: survey.id)),
        ).then((_) => ref.read(localSurveyProvider.notifier).loadSurveys()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(survey.title, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(l10n.offline, style: const TextStyle(color: Colors.blue, fontSize: 11)),
                  ),
                ],
              ),
              if (survey.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(survey.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600])),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.question_answer, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${survey.questions.length} ${l10n.questions}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${survey.responseCount} ${l10n.responses}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
