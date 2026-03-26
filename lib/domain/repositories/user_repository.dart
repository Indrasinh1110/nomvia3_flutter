import 'package:nomvia/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getCurrentUser();
  Future<List<User>> getFriends();
}
