import '../services/client/network_client.dart';

abstract class UserInterFace {
  final NetworkClient client;

  UserInterFace({required this.client});
}

class UserRepositories extends UserInterFace {
  UserRepositories._() : super(client: NetworkClient());

  factory UserRepositories() => UserRepositories._();
}
