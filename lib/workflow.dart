class WorkflowStep {
  final int id;
  final String text;

  WorkflowStep({
    required this.id,
    required this.text,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      id: json['id'] as int,
      text: json['text'] as String,
    );
  }
}

  class Workflow {
    final String title;
    final List<WorkflowStep> steps;

  Workflow({
    required this.title,
    required this.steps,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      title: json['title'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map(
            (step) => WorkflowStep.fromJson(
              step as Map<String, dynamic>
            ),
          )
          .toList(),
    );
  }
}