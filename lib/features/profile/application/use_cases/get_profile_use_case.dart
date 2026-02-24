import '../../data/repositories/client_repository.dart';

class GetProfileUseCase {
  GetProfileUseCase(this._repository);

  final ClientRepository _repository;

  Future<ClientProfileResult> call() {
    return _repository.getProfile();
  }
}
