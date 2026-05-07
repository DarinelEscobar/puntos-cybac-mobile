import '../../data/repositories/client_repository.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final ClientRepository _repository;

  Future<void> call({required String reason}) {
    return _repository.deleteAccount(reason: reason);
  }
}
