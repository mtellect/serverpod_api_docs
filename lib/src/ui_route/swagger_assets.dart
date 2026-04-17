/// Default assets for the standard Swagger UI distribution.
class SwaggerAssets {
  static const String indexHtmlTemplate = '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>{{TITLE}}</title>
    <link rel="stylesheet" type="text/css" href="./swagger-ui.css" />
    <link rel="stylesheet" type="text/css" href="index.css" />
    <link rel="icon" type="image/png" href="./favicon-32x32.png" sizes="32x32" />
    <link rel="icon" type="image/png" href="./favicon-16x16.png" sizes="16x16" />
  </head>

  <body>
    <div id="swagger-ui"></div>
    <script src="./swagger-ui-bundle.js" charset="UTF-8"> </script>
    <script src="./swagger-ui-standalone-preset.js" charset="UTF-8"> </script>
    <script src="./swagger-initializer.js" charset="UTF-8"> </script>
  </body>
</html>
''';

  static const String defaultIndexCss = '''
html {
  box-sizing: border-box;
  overflow: -moz-scrollbars-vertical;
  overflow-y: scroll;
}

*,
*:before,
*:after {
  box-sizing: inherit;
}

body {
  margin: 0;
  background: #fafafa;
}

.swagger-ui .topbar {
  background-color: #1b1b1b;
}

.swagger-ui .topbar .download-url-wrapper .select-label {
  color: #fff;
  font-weight: bold;
}
''';

  static const String defaultInitializerJs = '''
window.onload = function() {
  const ui = SwaggerUIBundle({
    urls: [{url: "{{SPEC_URL}}", name: "Default"}],
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout",
    // Enable all OAuth-related functionality
    oauth2RedirectUrl: window.location.origin + window.location.pathname + 'oauth2-redirect.html',
    persistAuthorization: true,
    displayOperationId: false,
    withCredentials: true,
    tryItOutEnabled: true,
  });
  window.ui = ui;
};
''';

  static const String swaggerUiVersion = '5.11.0';
  static const String cdnBase = 'https://unpkg.com/swagger-ui-dist@$swaggerUiVersion';
}
