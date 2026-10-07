import 'package:flutter/material.dart';

import '../../data/models/employee.dart';
import '../../data/mission_repository.dart';

class GroupParticipantStep extends StatefulWidget {
  final MissionRepository repository;
  final List<int> initialSelectedIds;
  final ValueChanged<List<int>> onChanged;

  const GroupParticipantStep({
    super.key,
    required this.repository,
    required this.initialSelectedIds,
    required this.onChanged,
  });

  @override
  State<GroupParticipantStep> createState() => _GroupParticipantStepState();
}

class _GroupParticipantStepState extends State<GroupParticipantStep> {
  List<Employee> _employees = [];

  final Set<int> _selectedIds = {};

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _selectedIds.addAll(widget.initialSelectedIds);

    _searchController.addListener(_onSearchChanged);

    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final employees = await widget.repository.getEmployees();

      if (!mounted) return;

      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load employees.';
      });
    }
  }

  void _toggleEmployee(Employee employee) {
    setState(() {
      if (_selectedIds.contains(employee.id)) {
        _selectedIds.remove(employee.id);
      } else {
        _selectedIds.add(employee.id);
      }
    });

    widget.onChanged(_selectedIds.toList());
  }

  List<Employee> get _filteredEmployees {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _employees;
    }

    return _employees.where((employee) {
      return employee.fullName.toLowerCase().contains(query) ||
          employee.employeeCode.toLowerCase().contains(query) ||
          employee.functionName.toLowerCase().contains(query) ||
          employee.jobLevel.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadEmployees,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final filteredEmployees = _filteredEmployees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select participants',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 8),

        Text(
          'Select the colleagues travelling with you.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),

        const SizedBox(height: 16),

        // Search
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search name or employee ID',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2F5FE0),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Selected count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.groups_outlined, color: Color(0xFF2F5FE0)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_selectedIds.length} participant${_selectedIds.length == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F5FE0),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: filteredEmployees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_search_outlined,
                        size: 42,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No employees found',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filteredEmployees.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final employee = filteredEmployees[index];

                    final isSelected = _selectedIds.contains(employee.id);

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          _toggleEmployee(employee);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2F5FE0)
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor: const Color(0xFFEAF0FE),
                                child: Text(
                                  employee.fullName.isNotEmpty
                                      ? employee.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF2F5FE0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      employee.fullName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      employee.employeeCode,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    Text(
                                      '${employee.jobLevel} · ${employee.functionName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  _toggleEmployee(employee);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
