import "package:flutter/material.dart";

class MissionPurposeSection extends StatefulWidget {
  const MissionPurposeSection({super.key});

  @override
  State<MissionPurposeSection> createState() => _MissionPurposeSectionState();
}

class _MissionPurposeSectionState extends State<MissionPurposeSection> {
  final TextEditingController _purposeController = TextEditingController();

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mission purpose',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _purposeController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter the purpose of this mission',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
