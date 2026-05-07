import 'package:url_launcher/url_launcher.dart';

abstract class ExternalLinkService {
  Future<bool> open(Uri uri);
}

class UrlLauncherExternalLinkService implements ExternalLinkService {
  @override
  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
