import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/survey_provider.dart';
import '../survey/create_survey_screen.dart';
import '../survey/survey_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../take/take_survey_screen.dart';
import '../../widgets/survey_card.dart' as widget;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(surveyProvider.notifier).loadSurveys());
  }

  @override
  Widget build(BuildContext context) {
    final surveyState = ref.watch(surveyProvider);

    return Scaffold(
      body: _currentIndex == 0 ? _buildSurveysList(surveyState) : const ProfileScreen(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateSurveyScreen()),
              ).then((_) => ref.read(surveyProvider.notifier).loadSurveys()),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.poll), label: 'Surveys'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSurveysList(surveyState) {
    if (surveyState.isLoading && surveyState.surveys.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (surveyState.error != null && surveyState.surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(surveyState.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(surveyProvider.notifier).loadSurveys(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (surveyState.surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.create, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No surveys yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Tap + to create your first survey'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(surveyProvider.notifier).loadSurveys(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: surveyState.surveys.length,
        itemBuilder: (context, index) {
          final survey = surveyState.surveys[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: widget.SurveyCardWidget(
              survey: survey,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SurveyDetailScreen(survey: survey)),
              ).then((_) => ref.read(surveyProvider.notifier).loadSurveys()),
              onTakeSurvey: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TakeSurveyScreen(surveyId: survey.id, surveyTitle: survey.title)),
              ),
            ),
          );
        },
      ),
    );
  }
}
