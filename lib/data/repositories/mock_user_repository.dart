import 'package:nomvia/data/datasources/mock_data.dart';
import 'package:nomvia/domain/entities/user.dart';
import 'package:nomvia/domain/repositories/user_repository.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.currentUser;
  }

  @override
  Future<List<User>> getFriends() async {
     await Future.delayed(const Duration(milliseconds: 400));
    return MockData.friends;
  }
}
