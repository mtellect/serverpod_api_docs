import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../api_docs_helper.dart';
import 'scalar_ui_route.dart';
import 'swagger_ui_route.dart';

/// A unified route that serves either Scalar or Swagger UI based on the [type] parameter.
///
/// This class is the primary entry point for manually adding the documentation UI
/// to a Serverpod web server.
///
/// Example:
/// ```dart
/// final apiDocsRoute = ApiDocsUIRoute(
///   projectRoot,
///   type: ApiDocsType.scalar,
///   brandingName: 'My Brand Name',
/// );
/// pod.webServer.addRoute(apiDocsRoute, '/docs/**');
/// ```
class ApiDocsUIRoute extends Route {
  final Route _internalRoute;

  /// Creates a new [ApiDocsUIRoute] with the specified configuration.
  ///
  /// [projectRoot] is the root directory of your project.
  /// [type] determines whether to use Scalar or Swagger UI.
  /// [mountPath] should match the path where you register this route in Serverpod.
  /// [title] sets the browser tab title.
  /// [brandingName] sets the name displayed in the UI header.
  /// [navLinks] provides a list of maps (label/url) for the header navigation.
  /// [customCss] allows providing additional CSS styles.
  /// [customConfig] (Scalar only) allows providing additional Scalar-specific configuration.
  ApiDocsUIRoute(
    Directory projectRoot, {
    ApiDocsType type = ApiDocsType.scalar,
    String mountPath = '/docs/',
    String title = 'API Reference',
    String brandingName = 'API Docs',
    List<Map<String, String>> navLinks = const [],
    String customCss = '',
    Map<String, dynamic>? customConfig,
  }) : _internalRoute = type == ApiDocsType.scalar
            ? ScalarUIRoute(
                projectRoot,
                mountPath: mountPath,
                title: title,
                brandingName: brandingName,
                navLinks: navLinks,
                customCss: customCss,
                customConfig: customConfig,
              )
            : SwaggerUIRoute(
                projectRoot,
                mountPath: mountPath,
                title: title,
                brandingName: brandingName,
                navLinks: navLinks,
                customCss: customCss,
              );

  @override
  Future<Result> handleCall(Session session, Request request) async {
    return await _internalRoute.handleCall(session, request);
  }
}

/// Alias for [ApiDocsUIRoute] for better discoverability and branding.
typedef ServerPodApiUIRoute = ApiDocsUIRoute;
