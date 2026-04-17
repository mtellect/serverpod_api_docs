import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:path/path.dart' as p;

/// A route that serves the apispec.json file.
///
/// This route is useful when you want to serve the API specification
/// at a different path than the Swagger UI (e.g., at the root while
/// Swagger UI is at a custom path).
class ApiSpecRoute extends Route {
  /// The root directory of the project where apispec.json is located.
  final Directory _projectRoot;

  /// Optional override for the API title.
  final String? apiTitle;

  /// Optional override for the API version.
  final String? apiVersion;

  /// Optional override for the API description.
  final String? apiDescription;

  /// Optional override for the servers list.
  final List<Map<String, String>>? serverUrls;

  /// Creates a new [ApiSpecRoute] instance with optional specification overrides.
  ApiSpecRoute(
    Directory projectRoot, {
    this.apiTitle,
    this.apiVersion,
    this.apiDescription,
    this.serverUrls,
  }) : _projectRoot = projectRoot;

  /// Handles incoming HTTP requests and serves the API specification.
  @override
  Future<Response> handleCall(Session session, Request request) async {
    session.log('Serving API spec from ${_projectRoot.path}');

    // Read the file from disk ON EVERY REQUEST for live updates
    final specFile = File(p.join(_projectRoot.path, 'apispec.json'));
    if (await specFile.exists()) {
      var content = await specFile.readAsString();

      // Apply overrides if any are provided
      if (apiTitle != null ||
          apiVersion != null ||
          apiDescription != null ||
          serverUrls != null) {
        try {
          final Map<String, dynamic> spec = jsonDecode(content);

          // Update Info section
          final info = (spec['info'] as Map<String, dynamic>?) ?? {};
          if (apiTitle != null) info['title'] = apiTitle;
          if (apiVersion != null) info['version'] = apiVersion;
          if (apiDescription != null) info['description'] = apiDescription;
          spec['info'] = info;

          // Update Servers section
          if (serverUrls != null) {
            spec['servers'] = serverUrls;
          }

          content = jsonEncode(spec);
        } catch (e) {
          session.log('Error patching apispec.json: $e', level: LogLevel.error);
        }
      }

      // Build headers with cache control
      final headers = Headers.build((mh) {
        mh.cacheControl = CacheControlHeader(
          noCache: true,
          noStore: true,
          mustRevalidate: true,
        );
        mh['Pragma'] = ['no-cache'];
        mh['Expires'] = ['0'];
      });

      return Response.ok(
        body: Body.fromString(content, mimeType: MimeType.json),
        headers: headers,
      );
    } else {
      return Response.notFound(
        body: Body.fromString(
          'Error: apispec.json not found at ${specFile.path}',
        ),
      );
    }
  }
}
