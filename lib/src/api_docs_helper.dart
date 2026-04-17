import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'ui_route/apispec_route.dart';
import 'ui_route/api_docs_ui_route.dart';

/// Defines the available documentation UI styles.
enum ApiDocsType {
  /// The modern, sleek Scalar API reference.
  scalar,

  /// The classic, industry-standard Swagger UI.
  swagger,
}

/// A unified helper class for registering API documentation in a Serverpod project.
class ApiDocs {
  /// A turn-key method to add API documentation to your Serverpod server.
  ///
  /// This method automatically:
  /// 1. Registers the [ApiSpecRoute] at `/apispec.json`.
  /// 2. Instantiates the UI route based on the [type] provided.
  /// 3. Registers the UI route at [mountPath] with the required `/**` tail match.
  ///
  /// Example:
  /// ```dart
  /// ApiDocs.addRoute(
  ///   pod,
  ///   projectRoot,
  ///   type: ApiDocsType.scalar,
  ///   brandingName: 'Dey Chop',
  /// );
  /// ```
  static void addRoute(
    Serverpod pod,
    Directory projectRoot, {
    ApiDocsType type = ApiDocsType.scalar,
    String mountPath = '/docs/',
    String title = 'API Reference',
    String brandingName = 'API Docs',
    List<Map<String, String>> navLinks = const [],
    String customCss = '',
    Map<String, dynamic>? customConfig,
    String? apiTitle,
    String? apiVersion,
    String? apiDescription,
    List<Map<String, String>>? serverUrls,
  }) {
    // 1. Ensure mountPath ends with a slash for consistent sub-routing
    final normalizedMountPath = mountPath.endsWith('/') ? mountPath : '$mountPath/';

    // 2. Register the API Specification Route (required by both UIs)
    final apiSpecRoute = ApiSpecRoute(
      projectRoot,
      apiTitle: apiTitle,
      apiVersion: apiVersion,
      apiDescription: apiDescription,
      serverUrls: serverUrls,
    );
    pod.webServer.addRoute(apiSpecRoute, '/apispec.json');

    // 3. Register the UI Route
    final uiRoute = ApiDocsUIRoute(
      projectRoot,
      type: type,
      mountPath: normalizedMountPath,
      title: title,
      brandingName: brandingName,
      navLinks: navLinks,
      customCss: customCss,
      customConfig: customConfig,
      apiTitle: apiTitle,
      apiVersion: apiVersion,
      apiDescription: apiDescription,
      serverUrls: serverUrls,
    );

    // Register with the /** tail match to handle sub-resources (JS, CSS, etc.)
    final routeMatch =
        normalizedMountPath.endsWith('/') ? '${normalizedMountPath}**' : '$normalizedMountPath/**';

    pod.webServer.addRoute(uiRoute, routeMatch);
  }
}
