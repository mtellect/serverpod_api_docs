import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:path/path.dart' as p;
import 'api_proxy_route.dart';
import 'scalar_assets.dart';

/// A development-friendly route that serves a custom-branded Scalar API Reference.
/// 
/// This route handles serving the Scalar HTML, its assets via CDN redirection,
/// and provides an internal REST-to-RPC proxy for testing endpoints.
class ScalarUIRoute extends Route {
  final Directory _projectRoot;
  final String _mountPath;
  final String _specPath;
  final String _title;
  final String _brandingName;
  final List<Map<String, String>> _navLinks;
  final String? _apiTitle;
  final String? _apiVersion;
  final String? _apiDescription;
  final List<Map<String, String>>? _serverUrls;
  final String _customCss;
  final Map<String, dynamic> _config;

  /// Creates a new Scalar UI route.
  /// 
  /// [projectRoot] is the directory where the apispec.json file is located.
  /// [mountPath] is the URL path where the Scalar UI will be served, must end with a slash.
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
    String? apiTitle,
    String? apiVersion,
    String? apiDescription,
    List<Map<String, String>>? serverUrls,
  })  : assert(mountPath.endsWith('/'), 'mountPath must end with a trailing slash.'),
        _projectRoot = projectRoot,
        _mountPath = mountPath,
        _specPath = customSpecPath ?? p.join(mountPath, 'apispec.json'),
        _title = title,
        _brandingName = brandingName,
        _navLinks = navLinks,
        _apiTitle = apiTitle,
        _apiVersion = apiVersion,
        _apiDescription = apiDescription,
        _serverUrls = serverUrls,
        _customCss = customCss,
        _config = {
          'showDeveloperTools': 'never',
          'isEditable': false,
          'hideClientButton': true,
          if (theme != null) 'theme': theme,
          if (proxyUrl != null) 'proxyUrl': proxyUrl,
          'showSidebar': showSidebar,
          ...?customConfig,
        },
        super(methods: {
          Method.get,
          Method.post,
          Method.put,
          Method.patch,
          Method.delete,
          Method.options,
          Method.head,
          Method.trace,
          Method.connect,
        });

  bool _isMainPage(String path) {
    return path == _mountPath || path == p.join(_mountPath, 'index.html');
  }

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final path = request.url.path;
    final pathSegments = request.url.pathSegments;

    // Handle Internal API Proxy (_api/endpoint/method or api-proxy/endpoint/method)
    if (pathSegments.contains('_api') || pathSegments.contains('api-proxy')) {
      final apiIndex = pathSegments.indexOf('_api') != -1 
          ? pathSegments.indexOf('_api') 
          : pathSegments.indexOf('api-proxy');
      final remainingSegments = pathSegments.skip(apiIndex + 1).toList();
      if (remainingSegments.length == 2) {
        return await ApiProxyRoute.handleProxyCall(
          session,
          request,
          remainingSegments[0],
          remainingSegments[1],
        );
      }
    }

    // 0. Handle Redirect for missing trailing slash
    if (path == _mountPath.substring(0, _mountPath.length - 1)) {
      return Response.movedPermanently(Uri.parse(_mountPath));
    }

    // 1. Handle API Spec JSON
    if (path == _specPath) {
      final specFile = File(p.join(_projectRoot.path, 'apispec.json'));
      if (await specFile.exists()) {
        var content = await specFile.readAsString();

        // Apply overrides if any are provided
        if (_apiTitle != null ||
            _apiVersion != null ||
            _apiDescription != null ||
            _serverUrls != null) {
          try {
            final Map<String, dynamic> spec = jsonDecode(content);

            // Update Info section
            final info = (spec['info'] as Map<String, dynamic>?) ?? {};
            if (_apiTitle != null) info['title'] = _apiTitle;
            if (_apiVersion != null) info['version'] = _apiVersion;
            if (_apiDescription != null) info['description'] = _apiDescription;
            spec['info'] = info;

            // Update Servers section
            // If no serverUrls are provided, automatically point to the internal proxy
            if (_serverUrls != null) {
              spec['servers'] = _serverUrls;
            } else {
              // Ensure we have a valid base URL for the proxy
              final String baseUrl = request.url.origin;
              spec['servers'] = [
                {
                  'url': '$baseUrl${_mountPath}_api',
                  'description': 'Internal API Proxy',
                }
              ];
            }

            content = jsonEncode(spec);
          } catch (e) {
            session.log('Error patching apispec.json in ScalarUIRoute: $e',
                level: LogLevel.error);
          }
        }

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
      final configJson = jsonEncode(_config);
      final html = ScalarAssets.indexHtmlTemplate
          .replaceFirst('{{SPEC_URL}}', _specPath)
          .replaceFirst('{{TITLE}}', _title)
          .replaceFirst('{{BRANDING_NAME}}', _brandingName)
          .replaceFirst('{{NAV_LINKS}}', _generateNavLinks())
          .replaceFirst('{{CUSTOM_CSS}}', _customCss)
          .replaceFirst('{{CONFIG}}', configJson);

      return Response.ok(
        body: Body.fromString(html, mimeType: MimeType.html),
      );
    }

    return Response.notFound();
  }

  String _generateNavLinks() {
    if (_navLinks.isEmpty) return '';
    return _navLinks
        .map((link) =>
            '<a href="${link['url']}" target="_blank" class="nav-link">${link['label']}</a>')
        .join('\n');
  }
}
