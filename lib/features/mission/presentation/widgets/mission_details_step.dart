import 'package:flutter/material.dart';

class MissionDetailsData {
  final String baseLocation;
  final String destination;
  final String travelDate;
  final String returnDate;
  final String departureTime;
  final String arrivalTime;
  final String purpose;
  final String additionalInfo;
  final bool overnightRequired;

  const MissionDetailsData({
    required this.baseLocation,
    required this.destination,
    required this.travelDate,
    required this.returnDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.purpose,
    required this.additionalInfo,
    required this.overnightRequired,
  });

  int get numberOfTravelDays {
    final departure = _parseDate(travelDate);
    final arrival = _parseDate(returnDate);

    if (departure == null || arrival == null) {
      return 1;
    }

    final difference = arrival.difference(departure).inDays;

    return difference < 0 ? 1 : difference + 1;
  }

  static DateTime? _parseDate(String value) {
    final parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }
}

class MissionDetailsStep extends StatefulWidget {
  final MissionDetailsData initialData;
  final ValueChanged<MissionDetailsData> onChanged;

  const MissionDetailsStep({
    super.key,
    required this.initialData,
    required this.onChanged,
  });

  @override
  State<MissionDetailsStep> createState() => _MissionDetailsStepState();
}

class _MissionDetailsStepState extends State<MissionDetailsStep> {
  late final TextEditingController _purposeController;
  late final TextEditingController _additionalInfoController;

  late String _baseLocation;
  late String _destination;

  late String _travelDate;
  late String _returnDate;

  late String _departureTime;
  late String _arrivalTime;

  late bool _overnightRequired;

  @override
  void initState() {
    super.initState();

    _purposeController = TextEditingController(
      text: widget.initialData.purpose,
    );

    _additionalInfoController = TextEditingController(
      text: widget.initialData.additionalInfo,
    );

    _baseLocation = widget.initialData.baseLocation;
    _destination = widget.initialData.destination;

    _travelDate = widget.initialData.travelDate;
    _returnDate = widget.initialData.returnDate;

    _departureTime = widget.initialData.departureTime;
    _arrivalTime = widget.initialData.arrivalTime;

    _overnightRequired = widget.initialData.overnightRequired;
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(
      MissionDetailsData(
        baseLocation: _baseLocation,
        destination: _destination,
        travelDate: _travelDate,
        returnDate: _returnDate,
        departureTime: _departureTime,
        arrivalTime: _arrivalTime,
        purpose: _purposeController.text,
        additionalInfo: _additionalInfoController.text,
        overnightRequired: _overnightRequired,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              _notifyChanged();
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
                _baseLocation = value;
                _notifyChanged();
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
                _destination = value;
                _notifyChanged();
              }
            },
          ),

          const SizedBox(height: 6),

          const Text(
            'The destination zone determines the accommodation rate.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

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

          _sectionTitle(
            number: '4',
            title: 'ACCOMMODATION',
            colorScheme: colorScheme,
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () {
              _overnightRequired = !_overnightRequired;
              _notifyChanged();
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
              _notifyChanged();
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
