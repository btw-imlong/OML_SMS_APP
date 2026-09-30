import 'package:flutter/material.dart';

import './widgets/mission_type_card.dart';
import './widgets/mission_progress.dart';
import './widgets/mission_details_step.dart';

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

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return Column(
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
          ],
        );

      case 1:
        return const MissionDetailsStep();

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New mission request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 5),

              Text(
                'Step ${_currentStep + 1} of ${_steps.length} · ${_steps[_currentStep]}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.save,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(width: 3),

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
                color: const Color.fromARGB(255, 220, 220, 220),
                height: 1.0,
                width: double.infinity,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),

                child: MissionProgress(
                  currentStep: _currentStep,
                  steps: _steps,
                ),
              ),
            ],
          ),
        ),

        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Expanded(child: _buildCurrentStep()),

            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      child: const Text('← Back'),
                    ),
                  ),

                if (_currentStep > 0) const SizedBox(width: 12),

                Expanded(
                  child: FilledButton(
                    onPressed: _missionType == null
                        ? null
                        : () {
                            if (_currentStep < _steps.length - 1) {
                              setState(() {
                                _currentStep++;
                              });
                            }
                          },
                    child: const Text('Continue →'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
