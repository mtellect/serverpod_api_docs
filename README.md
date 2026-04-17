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

---

## Installation

### 1. Add as a dependency
Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  serverpod_api_docs: ^0.0.1
```

### 2. Global Activation (for the CLI)
To use the generator command globally from any directory:

```bash
dart pub global activate serverpod_api_docs
```

### 3. Development & Git Installation
If you want to use a non-published version or contribute to the package:

**Local Development (from the package root):**
```bash
dart pub global activate -s path .
```

**Via Git:**
```bash
dart pub global activate -s git https://github.com/mtellect/serverpod_api_docs.git
```

**Local/Git Dependency:**
```yaml
# In your pubspec.yaml
dependencies:
  serverpod_api_docs:
    path: ../path/to/serverpod_api_docs # For local
    # OR
    git:
      url: https://github.com/mtellect/serverpod_api_docs.git
      ref: main
```

---

## Usage: Step 1 - Generate your Specification

The foundation of both UIs is the `apispec.json` file. Run this command in your server project root:

```bash
# If activated globally
serverpod_api_docs_generate --base-url=http://localhost:8082

# OR via dart run
dart run serverpod_api_docs:generate --base-url=http://localhost:8082
```

---

## Usage: Step 2 - Choose Your Style

Use the `ApiDocs.addRoute` helper to instantly register your documentation.

### Option A: Scalar UI (Modern & Sleek)
```dart
// bin/server.dart
import 'package:serverpod_api_docs/serverpod_api_docs.dart';

ApiDocs.addRoute(
  pod,
  projectRoot,
  type: ApiDocsType.scalar,
  brandingName: 'My Brand', 
  navLinks: [
    {'label': 'Twitter', 'url': 'https://twitter.com/MyBrand'},
  ],
);
```

### Option B: Swagger UI (Classic & Professional)
```dart
// bin/server.dart
import 'package:serverpod_api_docs/serverpod_api_docs.dart';

ApiDocs.addRoute(
  pod,
  projectRoot,
  type: ApiDocsType.swagger,
  brandingName: 'API Reference',
);
```

---

## Advanced Configuration

### Manual Route Registration
If you need custom routing logic:

```dart
final scalarRoute = ScalarUIRoute(projectRoot, brandingName: 'My Brand');
pod.webServer.addRoute(scalarRoute, '/custom_docs/**');

final apiSpecRoute = ApiSpecRoute(projectRoot);
pod.webServer.addRoute(apiSpecRoute, '/apispec.json');
```

## Troubleshooting

- **Mount Path**: The `ApiDocs.addRoute` method defaults to `/docs/`. You can change this via the `mountPath` parameter.
- **Trailing Slash**: Trailing slashes in your browser (e.g., `localhost:8082/docs/`) are recommended.
- **Port 8082**: Ensure your generated `apispec.json` has a `--base-url` that matches your active server port.

## Credits

This project is a rebranded and enhanced suite built upon the excellent foundation of [serverpod_swagger](https://github.com/arsheriff2k3/serverpod_swagger) by [arsheriff2k3](https://github.com/arsheriff2k3). We are grateful for their original contribution to the Serverpod ecosystem.

## License
Apache 2.0
