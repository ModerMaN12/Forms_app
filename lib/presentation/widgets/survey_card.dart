import 'package:flutter/material.dart';
import '../../../data/models/survey_model.dart';

class SurveyCardWidget extends StatelessWidget {
  final SurveyModel survey;
  final VoidCallback onTap;
  final VoidCallback onTakeSurvey;

  const SurveyCardWidget({
    super.key,
    required this.survey,
    required this.onTap,
    required this.onTakeSurvey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      survey.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (survey.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (survey.description.isNotEmpty)
                Text(
                  survey.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.question_answer, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${survey.questions.length} questions', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${survey.responseCount} responses', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
