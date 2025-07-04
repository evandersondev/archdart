import '../repositories/user_repository.dart';

class UserEntity {
  final IUserRepository repository;

  UserEntity(this.repository);
}
