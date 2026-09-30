import 'package:flutter/material.dart';

class MissionDetailsStep extends StatefulWidget {
  const MissionDetailsStep({super.key});

  @override
  State<MissionDetailsStep> createState() => _MissionDetailsStepState();
}

class _MissionDetailsStepState extends State<MissionDetailsStep> {
  final TextEditingController _purposeController = TextEditingController();

  final TextEditingController _additionalInfoController =
      TextEditingController();

  String _baseLocation = 'HQ — Phnom Penh (Norodom Blvd)';
  String _destination = 'Kampong Thom, Kampong Thom — Provincia';

  String _travelDate = '09/16/2026';
  String _returnDate = '09/16/2026';

  String _departureTime = '8:00 AM';
  String _arrivalTime = '5:00 PM';

  bool _overnightRequired = true;

  @override
  void dispose() {
    _purposeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. MISSION PURPOSE
          _sectionTitle(
            number: '1',
            title: 'MISSION PURPOSE',
            colorScheme: colorScheme,
          ),

          const SizedBox(height: 12),

          _fieldLabel(
            'What is the mission for?',
            required: true,
            counter: '${_purposeController.text.length}/220',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _purposeController,
            maxLength: 220,
            maxLines: 4,
            onChanged: (_) {
              setState(() {});
            },
            decoration: const InputDecoration(
              hintText: 'e.g. Core network upgrade acceptance testing at the Siem Reap regional hub',
              counterText: '',
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Be specific — approvers use this to assess necessity.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          // 2. ROUTE
          _sectionTitle(number: '2', title: 'ROUTE', colorScheme: colorScheme),

          const SizedBox(height: 12),

          _fieldLabel('Base location', required: true),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: _baseLocation,
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(
                value: 'HQ — Phnom Penh (Norodom Blvd)',
                child: Text('HQ — Phnom Penh (Norodom Blvd)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _baseLocation = value;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          _fieldLabel('Destination', required: true),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: _destination,
            decoration: const InputDecoration(),
            items: const [
              DropdownMenuItem(
                value: 'Kampong Thom, Kampong Thom — Provincia',
                child: Text('Kampong Thom, Kampong Thom — Provincia'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _destination = value;
                });
              }
            },
          ),

          const SizedBox(height: 6),

          const Text(
            'The destination zone determines the accommodation rate.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          // 3. SCHEDULE
          _sectionTitle(
            number: '3',
            title: 'SCHEDULE',
            colorScheme: colorScheme,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _dateField(
                  label: 'Travel date',
                  value: _travelDate,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  label: 'Return date',
                  value: _returnDate,
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _timeField(
                  label: 'Departure time',
                  value: _departureTime,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timeField(
                  label: 'Arrival / return time',
                  value: _arrivalTime,
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Meal information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 18),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Times affect your meal eligibility',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Breakfast is eligible when departure is at or before 06:30 and dinner when the return is at or after 19:00.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF33507A),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. ACCOMMODATION
          _sectionTitle(
            number: '4',
            title: 'ACCOMMODATION',
            colorScheme: colorScheme,
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              setState(() {
                _overnightRequired = !_overnightRequired;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _overnightRequired
                          ? colorScheme.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: colorScheme.primary),
                    ),
                    child: _overnightRequired
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overnight accommodation required',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Same-day missions are not normally eligible for accommodation.',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF1DD),
              border: Border.all(color: const Color(0xFFF0DBA9)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  color: Color(0xFFB7791F),
                  size: 18,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Same-day mission',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB7791F),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your travel and return dates are the same, so no nights will be calculated. Extend the return date if you will stay overnight.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF8A6220),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _fieldLabel(
            'Additional information',
            counter: '${_additionalInfoController.text.length}/280',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _additionalInfoController,
            maxLength: 280,
            maxLines: 4,
            onChanged: (_) {
              setState(() {});
            },
            decoration: const InputDecoration(
              hintText: 'Anything approvers should know — site contacts, equipment, safety notes',
              counterText: '',
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String number,
    required String title,
    required ColorScheme colorScheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEF0F3))),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false, String? counter}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F1728),
            ),
            children: [
              TextSpan(text: label),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE0533D)),
                ),
            ],
          ),
        ),

        if (counter != null)
          Text(
            counter,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF9CA3AF)),
          ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: true),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          onTap: onTap,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.calendar_today_outlined, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _timeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: true),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: value),
          onTap: onTap,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.access_time, size: 17),
          ),
        ),
      ],
    );
  }
}
