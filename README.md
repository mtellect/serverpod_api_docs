# Serverpod API Docs (Scalar & Swagger)

A comprehensive documentation suite to automatically generate and serve **Scalar** and **Swagger UI** for a Serverpod backend.

## Features

- **One-Line Integration**: Unified `ApiDocs` helper to register everything in a single call.
- **Dual UI Support**: Choose between the modern **Scalar** API reference or the classic **Swagger UI**.
- **Instant Load**: Uses JSON injection to eliminate extra network requests for specifications.
- **Premium Aesthetics**: Branded with glassmorphism and dark mode support out of the box.
- **Automated Generation**: Creates OpenAPI 3.0 specifications from your Serverpod protocol definitions.

## Requirements

- Serverpod 3.4.2 or higher
- Dart 3.0.0 or higher

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  serverpod_api_docs: ^0.0.1
```

Then run:

```bash
dart pub get
```

---

## Step 1: Generate your Specification

The foundation of both UIs is the `apispec.json` file. Run this command in your server project root:

```bash
dart run serverpod_api_docs:generate --base-url=http://localhost:8082
```

---

## Step 2: Choose Your Style

Use the `ApiDocs.addRoute` helper to instantly register your documentation. You can choose your preferred UI style with a simple enum.

### Option A: Scalar UI (Modern & Sleek)
Recommended for high-end projects. Features **glassmorphism**, a cleaner sidebar, and faster navigation.

```dart
// bin/server.dart
import 'package:serverpod_api_docs/serverpod_api_docs.dart';

ApiDocs.addRoute(
  pod,
  projectRoot,
  type: ApiDocsType.scalar, // Modern look
  brandingName: 'Dey Chop', 
  navLinks: [
    {'label': 'Twitter', 'url': 'https://twitter.com/wiremoney'},
  ],
);
```

### Option B: Swagger UI (Classic & Professional)
The industry standard. Solid, familiar, and now supports the same branding as Scalar.

```dart
// bin/server.dart
import 'package:serverpod_api_docs/serverpod_api_docs.dart';

ApiDocs.addRoute(
  pod,
  projectRoot,
  type: ApiDocsType.swagger, // Classic look
  brandingName: 'API Reference',
);
```

---

## Advanced Configuration

### Manual Route Registration
If you need custom routing logic, you can still instantiate the routes manually:

```dart
// For Scalar
final scalarRoute = ScalarUIRoute(projectRoot, brandingName: 'My Brand');
pod.webServer.addRoute(scalarRoute, '/custom_docs/**');

// For Swagger
final swaggerRoute = SwaggerUIRoute(projectRoot, title: 'My Swagger');
pod.webServer.addRoute(swaggerRoute, '/custom_swagger/**');

// Don't forget the spec route if using custom paths
final apiSpecRoute = ApiSpecRoute(projectRoot);
pod.webServer.addRoute(apiSpecRoute, '/apispec.json');
```

## Troubleshooting

- **Mount Path**: The `ApiDocs.addRoute` method defaults to `/docs/`. You can change this via the `mountPath` parameter.
- **Trailing Slash**: The package automatically handles redirects, but explicit trailing slashes in your browser (e.g., `localhost:8082/docs/`) are recommended.
- **Port 8082**: Ensure your generated `apispec.json` has a `--base-url` that matches your active server port.

## Development & Git Installation

If you want to contribute to the package or use a non-published version, you can activate it locally or via Git.

### Global Activation

To activate locally for development (from the package root):
```bash
dart pub global activate -s path .
```

To activate via Git:
```bash
dart pub global activate -s git https://github.com/mtellect/serverpod_api_docs.git
```

### Adding as a Dependency

To use a local version in your `pubspec.yaml`:
```yaml
dependencies:
  serverpod_api_docs:
    path: ../path/to/serverpod_api_docs
```

To use the Git version:
```yaml
dependencies:
  serverpod_api_docs:
    git:
      url: https://github.com/mtellect/serverpod_api_docs.git
      ref: main
```

## Credits

This project is a rebranded and enhanced suite built upon the excellent foundation of [serverpod_swagger](https://github.com/arsheriff2k3/serverpod_swagger) by [arsheriff2k3](https://github.com/arsheriff2k3). We are grateful for their original contribution to the Serverpod ecosystem.

## License
Apache 2.0
