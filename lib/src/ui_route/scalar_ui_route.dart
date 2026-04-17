import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:path/path.dart' as p;
import 'scalar_assets.dart';

/// A development-friendly route that serves an enhanced Scalar API reference with a custom header.
///
/// Scalar is a modern alternative to Swagger UI that provides a more aesthetic
/// and interactive API documentation interface.
class ScalarUIRoute extends Route {
  /// The root directory of the project where apispec.json is located.
  final Directory _projectRoot;

  /// The base path where the Scalar UI will be mounted (e.g., '/scalar/').
  final String _mountPath;

  /// The full path to the API specification JSON file.
  final String _specPath;

  /// The title of the page.
  final String _title;

  /// Custom Scalar configuration.
  final Map<String, dynamic> _config;

  /// Branding name for the header.
  final String _brandingName;

  /// Navigation links for the header.
  final List<Map<String, String>> _navLinks;

  /// Custom CSS for the page.
  final String _customCss;

  /// Creates a new ScalarUIRoute instance with an enhanced header and initialization options.
  ///
  /// [projectRoot] is the directory where the apispec.json file is located.
  /// [mountPath] is the URL path where the Scalar UI will be served, must end with a slash.
  /// [customSpecPath] allows overriding the URL from which Scalar loads the API specification.
  /// [title] sets the browser tab title.
  /// [brandingName] sets the name displayed in the top-left of the custom header.
  /// [navLinks] provides a list of maps (label/url) to display in the header navigation.
  /// [customCss] allows providing additional CSS styles.
  /// [theme] selects the Scalar theme (use constants from [ScalarAssets]).
  /// [proxyUrl] sets a proxy URL for avoiding CORS issues if the spec is on another domain.
  /// [showSidebar] toggles the sidebar visibility.
  /// [customConfig] allows providing additional Scalar-specific configuration.
  ScalarUIRoute(
    Directory projectRoot, {
    String mountPath = '/scalar/',
    String? customSpecPath,
    String title = 'Serverpod API Reference',
    String brandingName = 'Scalar',
    List<Map<String, String>> navLinks = const [],
    String customCss = '',
    String? theme,
    String? proxyUrl,
    bool showSidebar = true,
    Map<String, dynamic>? customConfig,
  })  : assert(mountPath.endsWith('/'), 'mountPath must end with a trailing slash.'),
        _projectRoot = projectRoot,
        _mountPath = mountPath,
        _specPath = customSpecPath ?? p.join(mountPath, 'apispec.json'),
        _title = title,
        _brandingName = brandingName,
        _navLinks = navLinks,
        _customCss = customCss,
        _config = {
          'showDeveloperTools': 'never',
          'isEditable': false,
          'hideClientButton': true,
          if (theme != null) 'theme': theme,
          if (proxyUrl != null) 'proxyUrl': proxyUrl,
          'showSidebar': showSidebar,
          ...?customConfig,
        };

  bool _isMainPage(String path) {
    String normalizedMount = _mountPath.endsWith('/') && _mountPath.length > 1
        ? _mountPath.substring(0, _mountPath.length - 1)
        : _mountPath;
    String normalizedPath =
        path.endsWith('/') && path.length > 1 ? path.substring(0, path.length - 1) : path;
    return normalizedPath == normalizedMount;
  }

  @override
  Future<Response> handleCall(Session session, Request request) async {
    final path = request.url.path;

    // 1. Handle API Spec JSON
    if (path == _specPath) {
      final specFile = File(p.join(_projectRoot.path, 'apispec.json'));
      if (await specFile.exists()) {
        final content = await specFile.readAsString();
        return Response.ok(
          body: Body.fromString(content, mimeType: MimeType.json),
          headers: Headers.build((mh) {
            mh.cacheControl = CacheControlHeader(noCache: true, noStore: true);
          }),
        );
      }
      return Response.notFound(body: Body.fromString('apispec.json not found'));
    }

    // 2. Handle Main HTML Page
    if (_isMainPage(path)) {
      final specUrl = _specPath.startsWith('/') ? _specPath.substring(1) : _specPath;

      // Build nav links HTML
      final navLinksHtml = _navLinks
          .map((link) => '<a href="${link['url']}">${link['label']}</a>')
          .join('\n        ');

      final html = ScalarAssets.indexHtmlTemplate
          .replaceAll('{{TITLE}}', _title)
          .replaceAll('{{SPEC_URL}}', specUrl)
          .replaceAll('{{BRANDING_NAME}}', _brandingName)
          .replaceAll('{{NAV_LINKS}}', navLinksHtml)
          .replaceAll('{{CUSTOM_CSS}}', _customCss)
          .replaceAll('{{CONFIG}}', jsonEncode(_config));

      return Response.ok(
        body: Body.fromString(html, mimeType: MimeType.html),
      );
    }

    // 3. Handle Redirect for missing trailing slash
    if (path == _mountPath.substring(0, _mountPath.length - 1)) {
      return Response.movedPermanently(Uri.parse(_mountPath));
    }

    return Response.notFound();
  }
}
