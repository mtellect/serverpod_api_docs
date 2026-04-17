import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:path/path.dart' as p;
import 'swagger_assets.dart';

/// A development-friendly route that serves a standard distribution Swagger UI.
///
/// This route handles multiple sub-paths to provide a full-featured Swagger UI,
/// including CSS, JS, and initialization scripts. Heavy assets are automatically
/// redirected to a stable CDN to keep the package lightweight.
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

  /// Creates a new SwaggerUIRoute instance with support for standard customization.
  ///
  /// [projectRoot] is the directory where the apispec.json file is located.
  /// [mountPath] is the URL path where the Swagger UI will be served, must end with a slash.
  /// [customSpecPath] allows overriding the URL from which the Swagger UI loads the API specification.
  /// [customIndexCss] allows providing custom branding styles.
  /// [customInitializerJs] allows overriding the Swagger UI initialization logic.
  /// [title] sets the browser tab title.
  SwaggerUIRoute(
    Directory projectRoot, {
    String mountPath = '/swagger/',
    String? customSpecPath,
    String? customIndexCss,
    String? customInitializerJs,
    String title = 'Serverpod API - Swagger UI',
  })  : assert(mountPath.endsWith('/'), 'mountPath must end with a trailing slash.'),
        _projectRoot = projectRoot,
        _mountPath = mountPath,
        _specPath = customSpecPath ?? p.join(mountPath, 'apispec.json'),
        _indexCss = customIndexCss ?? SwaggerAssets.defaultIndexCss,
        _initializerJs = (customInitializerJs ?? SwaggerAssets.defaultInitializerJs)
            .replaceAll('{{SPEC_URL}}', customSpecPath ?? 'apispec.json'),
        _title = title;

  bool _isPathUnderMount(String path, String subPath) {
    return path == p.join(_mountPath, subPath);
  }

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
      final html = SwaggerAssets.indexHtmlTemplate.replaceAll('{{TITLE}}', _title);
      return Response.ok(
        body: Body.fromString(html, mimeType: MimeType.html),
      );
    }

    // 5. Handle Redirect for missing trailing slash
    if (path == _mountPath.substring(0, _mountPath.length - 1)) {
      return Response.movedPermanently(Uri.parse(_mountPath));
    }

    return Response.notFound();
  }
}
