import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

final getIt = GetIt.instance;

class SharedState {
  String baseUrl = "";
  String appVersion = "";
  String buildNumber = "";
}

Future<void> setupSingleton() async {
  // Initialize PackageInfo to get app version and build number
  final packageInfo = await PackageInfo.fromPlatform();

  // Register SharedState with the app version and build number
  final sharedState = SharedState()
    ..appVersion = packageInfo.version
    ..buildNumber = packageInfo.buildNumber;


  getIt.registerSingleton<SharedState>(sharedState);
}
