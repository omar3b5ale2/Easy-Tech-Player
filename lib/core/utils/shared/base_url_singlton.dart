import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class SharedState {
  String baseUrl = "";
}

void setupSingleton() {
  getIt.registerSingleton<SharedState>(SharedState());
}
