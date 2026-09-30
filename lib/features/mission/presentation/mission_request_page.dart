import 'package:flutter/material.dart';

import './widgets/mission_type_card.dart';
import './widgets/mission_progress.dart';

class MissionRequestPage extends StatefulWidget {
  const MissionRequestPage({super.key});

  @override
  State<MissionRequestPage> createState() => _MissionRequestPageState();
}

class _MissionRequestPageState extends State<MissionRequestPage> {
  int _currentStep = 0;
  String? _missionType;
  final List<String> _steps = [
    'Type',
    'Details',
    'Transport',
    'Allowance',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New mission request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Text(
                'Step 1 of 5 · Type',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.save,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Save Draft',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(
                  255,
                  220,
                  220,
                  220,
                ), // Adjusted color slightly so it isn't pure solid black
                height: 1.0,
                width: double.infinity,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  15,
                  20,
                  10,
                ), // Added top spacing below the line
                child: MissionProgress(
                  currentStep: _currentStep,
                  steps: _steps,
                ),
              ),
            ],
          ),
        ),

        shape: Border(bottom: BorderSide(color: Colors.black, width: 0.5)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who is travelling on this mission?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 24),

            MissionTypeCard(
              title: 'Individual mission',
              description:
                  'Only you travel. Allowance is calculated for your grade.',
              isSelected: _missionType == 'individual',
              onTap: () {
                setState(() {
                  _missionType = 'individual';
                });
              },
            ),

            const SizedBox(height: 12),

            MissionTypeCard(
              title: 'Group mission',
              description: 'You travel with colleagues under one mission reference and one approval workflow.',
              isSelected: _missionType == 'group',
              onTap: () {
                setState(() {
                  _missionType = 'group';
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _missionType == null
                    ? null
                    : () {
                        setState(() {
                          _currentStep = 1;
                        });
                      },
                child: const Text('Continue →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
