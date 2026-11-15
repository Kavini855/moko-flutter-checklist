import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'workflow.dart';

void main() {
  runApp(const MOKOApp());
}

class MOKOApp extends StatelessWidget {
  const MOKOApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moko Checklist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Workflowscreen(),
    );
  }
}

class Workflowscreen extends StatefulWidget {
  const Workflowscreen({super.key});

  @override
  State<Workflowscreen> createState() => _WorkflowscreenState();
}

class _WorkflowscreenState extends State<Workflowscreen> {
  Workflow? workflow;
  final Set<int> completedSteps = {};

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadWorkflow();
  }

  Future<void> loadWorkflow() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final jsonString = await rootBundle.loadString(
        'assets/workflow.json',
      );

      final jsonData = jsonDecode(jsonString);
      final loadedWorkflow = Workflow.fromJson(jsonData);

      if(!mounted) return;

      setState(() {
        workflow = loadedWorkflow;
        completedSteps.clear();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        workflow = null;
        errorMessage = "Failed to load the workflow";
        isLoading = false;
      });
    }
  }

  void toggleStep(int id, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedSteps.add(id);
      } else {
        completedSteps.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moko Checklist'),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error,
              size: 50,
              color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                )
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: loadWorkflow,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ), 
          ],
        ),
          
        ),
      );
    }

    final currentWorkflow = workflow!;

    if (currentWorkflow == null || currentWorkflow.steps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox,
              color: Colors.blueGrey,
              size: 65,
            ),
            SizedBox(height: 20),
            Text(
              'No workflow steps available!!!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey,
              ),
            )
          ],
        ),
      );
    }

    final total = currentWorkflow.steps.length;
    final completed = completedSteps.length;
    final progress = completed / total;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),

          const Text(
            'Your WorkFlow',
            style: TextStyle(
              color: Color.fromARGB(255, 90, 57, 163),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            currentWorkflow.title,
            style: const TextStyle(
              color: Color.fromARGB(255, 77, 25, 188),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Complete the steps below to finish your workflow.',
            style: TextStyle(
              color: Color.fromARGB(255, 152, 114, 198),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          // Progress card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completed of $total completed',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: const Color(0xFFDBEAFE),
                  color: const Color.fromARGB(255, 113, 37, 235),
                ),

                const SizedBox(height: 12),

                Text(
                  '${(progress * 100).round()}% completed',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 133, 37, 235),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Checklist',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 14),

          // Generate checklist items from JSON
          ...currentWorkflow.steps.map((step) {
            final isCompleted =
                completedSteps.contains(step.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFFBFDBFE)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: CheckboxListTile(
                value: isCompleted,
                onChanged: (value) {
                  toggleStep(step.id, value ?? false);
                },
                activeColor: const Color(0xFF2563EB),
                controlAffinity:
                    ListTileControlAffinity.leading,
                title: Text(
                  step.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted
                        ? const Color(0xFF64748B)
                        : const Color(0xFF1E293B),
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            );
          }),

          if (completed == total) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF16A34A),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Great work! All steps are completed.',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]
        ]
      ),
    );
  }
}

