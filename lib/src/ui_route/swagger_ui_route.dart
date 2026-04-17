import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:path/path.dart' as p;
import 'swagger_assets.dart';

/// A development-friendly route that serves a standard distribution Swagger UI.
///
/// This version supports custom branding and navigation links to maintain
/// consistency with the Scalar UI.
class SwaggerUIRoute extends Route {
  /// The root directory of the project where apispec.json is located.
  final Directory _projectRoot;

  /// The base path where the Swagger UI will be mounted (e.g., '/swagger/').
  final String _mountPath;

  /// The full path to the API specification JSON file.
  final String _specPath;

  /// Custom CSS for the index.css file.
  final String _indexCss;

  /// Custom JS for the swagger-initializer.js file.
  final String _initializerJs;

  /// The title of the page.
  final String _title;

  /// Branding name for the header.
  final String _brandingName;

  /// Navigation links for the header.
  final List<Map<String, String>> _navLinks;

  /// Creates a new SwaggerUIRoute instance with support for standard customization and branding.
  ///
  /// [projectRoot] is the directory where the apispec.json file is located.
  /// [mountPath] is the URL path where the Swagger UI will be served, must end with a slash.
  /// [customSpecPath] allows overriding the URL from which the Swagger UI loads the API specification.
  /// [title] sets the browser tab title.
  /// [brandingName] sets the name displayed in the top-left of the custom header.
  /// [navLinks] provides a list of maps (label/url) to display in the header navigation.
  /// [customCss] allows providing additional CSS styles.
  /// [customIndexCss] allows providing the entire index.css content (overrides branding/customCss defaults).
  /// [customInitializerJs] allows overriding the Swagger UI initialization logic.
  SwaggerUIRoute(
    Directory projectRoot, {
    String mountPath = '/swagger/',
    String? customSpecPath,
    String title = 'Serverpod API - Swagger UI',
    String brandingName = 'Swagger',
    List<Map<String, String>> navLinks = const [],
    String customCss = '',
    String? customIndexCss,
    String? customInitializerJs,
  })  : assert(mountPath.endsWith('/'), 'mountPath must end with a trailing slash.'),
        _projectRoot = projectRoot,
        _mountPath = mountPath,
        _specPath = customSpecPath ?? p.join(mountPath, 'apispec.json'),
        _brandingName = brandingName,
        _navLinks = navLinks,
        _indexCss = (customIndexCss ?? SwaggerAssets.defaultIndexCss)
            .replaceAll('{{CUSTOM_CSS}}', customCss),
        _initializerJs = (customInitializerJs ?? SwaggerAssets.defaultInitializerJs)
            .replaceAll('{{SPEC_URL}}', customSpecPath ?? 'apispec.json'),
        _title = title;

  bool _isPathUnderMount(String path, String subPath) {
    return path == p.join(_mountPath, subPath);
  }

  bool _isMainPage(String path) {
    return path == _mountPath || path == p.join(_mountPath, 'index.html');
  }

  @override
  Future<Response> handleCall(Session session, Request request) async {
    final path = request.url.path;

    // 0. Handle Redirect for missing trailing slash
    // Ensuring we are at the canonical mount point with a trailing slash
    // is critical so that relative asset links in the HTML work correctly.
    if (path == _mountPath.substring(0, _mountPath.length - 1)) {
      return Response.movedPermanently(Uri.parse(_mountPath));
    }

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

    // 2. Handle redirected assets (Heavy files)
    if (_isPathUnderMount(path, 'swagger-ui.css')) {
      return Response.found(Uri.parse('${SwaggerAssets.cdnBase}/swagger-ui.css'));
    }
    if (_isPathUnderMount(path, 'swagger-ui-bundle.js')) {
      return Response.found(Uri.parse('${SwaggerAssets.cdnBase}/swagger-ui-bundle.js'));
    }
    if (_isPathUnderMount(path, 'swagger-ui-standalone-preset.js')) {
      return Response.found(Uri.parse('${SwaggerAssets.cdnBase}/swagger-ui-standalone-preset.js'));
    }
    if (_isPathUnderMount(path, 'favicon-32x32.png')) {
      return Response.found(Uri.parse('${SwaggerAssets.cdnBase}/favicon-32x32.png'));
    }
    if (_isPathUnderMount(path, 'favicon-16x16.png')) {
      return Response.found(Uri.parse('${SwaggerAssets.cdnBase}/favicon-16x16.png'));
    }

    // 3. Handle Local Assets (Customizable)
    if (_isPathUnderMount(path, 'index.css')) {
      return Response.ok(
        body: Body.fromString(_indexCss, mimeType: MimeType('text', 'css')),
      );
    }
    if (_isPathUnderMount(path, 'swagger-initializer.js')) {
      return Response.ok(
        body: Body.fromString(_initializerJs, mimeType: MimeType('application', 'javascript')),
      );
    }

    // 4. Handle Main HTML Page
    if (_isMainPage(path)) {
      // Build nav links HTML
      final navLinksHtml = _navLinks
          .map((link) => '<a href="${link['url']}">${link['label']}</a>')
          .join('\n        ');

      final html = SwaggerAssets.indexHtmlTemplate
          .replaceAll('{{TITLE}}', _title)
          .replaceAll('{{BRANDING_NAME}}', _brandingName)
          .replaceAll('{{NAV_LINKS}}', navLinksHtml);

      return Response.ok(
        body: Body.fromString(html, mimeType: MimeType.html),
      );
    }

    return Response.notFound();
  }
}
