import 'package:app_links/app_links.dart';

abstract class DeepLinkService {
  Stream<Uri> get uriStream;
  Future<Uri?> getInitialUri();
}

class AppLinksDeepLinkService implements DeepLinkService {
  AppLinksDeepLinkService({AppLinks? appLinks})
      : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  @override
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;

  @override
  Future<Uri?> getInitialUri() {
    return _appLinks.getInitialLink();
  }
}
