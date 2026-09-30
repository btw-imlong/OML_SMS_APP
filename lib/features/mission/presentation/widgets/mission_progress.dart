import 'package:flutter/material.dart';

class MissionProgress extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const MissionProgress({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index == steps.length - 1 ? 0 : 5,
                ),
                decoration: BoxDecoration(
                  color: isActive || isCompleted
                      ? primaryColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 7),

        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;

            return Expanded(
              child: Text(
                isCompleted ? '✓ ${steps[index]}' : steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive || isCompleted
                      ? primaryColor
                      : Colors.grey[600],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
