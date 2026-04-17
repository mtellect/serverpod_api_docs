# Serverpod API Docs (Scalar & Swagger)

A comprehensive documentation suite to automatically generate and serve **Scalar** and **Swagger UI** for a Serverpod backend.

## Features

- **Dual UI Support**: Choose between the modern **Scalar** API reference or the classic **Swagger UI**.
- **Instant Load**: Uses JSON injection to eliminate extra network requests for specifications.
- **Premium Aesthetics**: Branded with glassmorphism and dark mode support out of the box.
- **Automated Generation**: Creates OpenAPI 3.0 specifications from your Serverpod protocol definitions.
- **Intelligent Detection**: Automatic HTTP method detection and model parsing.

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

### Common Options
| Argument | Description | Example |
| --- | --- | --- |
| `--base-url` | Sets your API server URL | `--base-url=https://api.myapp.com` |
| `--auth` | Auth type (jwt, apikey, basic) | `--auth=jwt` |
| `--update` | Update existing spec | `--update` |

---

## Step 2: Choose Your Style

You can serve your documentation using either the **Scalar** or **Swagger** interface. You can even serve both at different routes!

### Option A: Scalar UI (Modern & Sleek)
Recommended for high-end projects. Features **glassmorphism**, a cleaner sidebar, and faster navigation.

```dart
// bin/server.dart
final scalarRoute = ScalarUIRoute(
  projectRoot,
  brandingName: 'Dey Chop', // Your Brand
  title: 'API Reference',
);

// Add the route (use /** for tail match)
pod.webServer.addRoute(scalarRoute, '/docs/**');
```

### Option B: Swagger UI (Classic & Professional)
The industry standard. Solid, familiar, and highly reliable.

```dart
// bin/server.dart
final swaggerRoute = SwaggerUIRoute(
  projectRoot,
  title: 'Swagger API Reference',
);

// Add the route (use /** for tail match)
pod.webServer.addRoute(swaggerRoute, '/swagger/**');
```

---

## Advanced Configuration

### Serving the JSON Spec directly
If you want to allow users to download the raw `apispec.json`, add the `ApiSpecRoute`:

```dart
final apiSpecRoute = ApiSpecRoute(projectRoot);
pod.webServer.addRoute(apiSpecRoute, '/apispec.json');
```

### Automated Updates
You can add the generator to your workflow to ensure your docs are always in sync:

```bash
# In your CI/CD or build script
dart run serverpod_api_docs:generate --update
```

## Troubleshooting

- **Trailing Slash**: Always ensure your mount path ends with a slash (e.g., `/docs/`). The package handles redirects, but explicit paths are safer.
- **Tail Match**: Always use `/**` in `addRoute` (e.g., `/docs/**`) so the UI can handle its internal sub-routing.
- **Port 8082**: By default, Serverpod's web server runs on port 8082. Ensure your `--base-url` matches your active server port.

## License
Apache 2.0
