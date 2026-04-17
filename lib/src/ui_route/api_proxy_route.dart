import 'dart:convert';
import 'package:serverpod/serverpod.dart';

/// A route that acts as a proxy to handle REST-like paths (e.g., /endpoint/method)
/// used by Scalar and Swagger UI, translating them into standard Serverpod RPC calls.
class ApiProxyRoute extends Route {
  /// Creates a new ApiProxyRoute and allows all standard HTTP methods.
  ApiProxyRoute()
      : super(methods: {
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

  @override
  Future<Result> handleCall(Session session, Request request) async {
    var segments = request.url.pathSegments;

    // If the route is mounted at /api-proxy/**, skip the first segment
    if (segments.isNotEmpty && segments.first == 'api-proxy') {
      segments = segments.skip(1).toList();
    }

    // We only handle paths like /endpointName/methodName (exactly 2 segments remaining)
    if (segments.length != 2) {
      return Response.notFound();
    }

    return await handleProxyCall(session, request, segments[0], segments[1]);
  }

  /// The core logic for proxying a REST-style call to a Serverpod endpoint.
  /// 
  /// This is static so it can be reused internally by other routes.
  static Future<Result> handleProxyCall(
    Session session,
    Request request,
    String endpointName,
    String methodName,
  ) async {
    // Access the internal router to find the endpoint connector
    final dynamic dispatch = session.serverpod.endpoints;
    final Map<String, dynamic> connectors = dispatch.connectors;
    final dynamic connector = connectors[endpointName];

    if (connector == null) {
      return Response.notFound(
        body: Body.fromString('Endpoint "$endpointName" not found.'),
      );
    }

    // Try to find the method connector within the endpoint connector
    final Map<String, dynamic> methodConnectors = connector.methodConnectors;
    final dynamic methodConnector = methodConnectors[methodName];

    if (methodConnector == null) {
      return Response.notFound(
        body: Body.fromString(
          'Method "$methodName" not found on endpoint "$endpointName".',
        ),
      );
    }

    try {
      // Parse the incoming body as JSON parameters
      final bodyString = await request.readAsString();
      Map<String, dynamic> params = {};

      if (bodyString.isNotEmpty) {
        try {
          params = jsonDecode(bodyString);
        } catch (e) {
          return Response.badRequest(
            body: Body.fromString('Invalid JSON body: $e'),
          );
        }
      }

      // Execute the method via the connector
      final result = await methodConnector.call(session, params);

      // Return the serialized result
      return Response.ok(
        body: Body.fromString(jsonEncode(result), mimeType: MimeType.json),
      );
    } catch (e, stackTrace) {
      session.log('Error in ApiProxyRoute: $e',
          level: LogLevel.error, stackTrace: stackTrace);
      return Response.internalServerError(
        body: Body.fromString('Internal Server Error: $e'),
      );
    }
  }
}
