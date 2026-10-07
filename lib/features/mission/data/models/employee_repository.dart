import 'package:flutter_sms/core/network/dio_client.dart';
import 'package:flutter_sms/features/mission/data/models/employee.dart';

class EmployeeRepository {
  final DioClient _dioClient;

  EmployeeRepository(this._dioClient);

  Future<List<Employee>> getActiveEmployees() async {
    final response = await _dioClient.dio.get('/api/users');

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;

    return items
        .map((item) => Employee.fromJson(item as Map<String, dynamic>))
        .where((employee) => employee.isActive)
        .toList();
  }
}
