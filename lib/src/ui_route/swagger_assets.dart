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
    <header class="custom-header">
      <b>{{BRANDING_NAME}}</b>
      <nav>
        {{NAV_LINKS}}
      </nav>
    </header>
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
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
}

/* Custom Header Styling (Matching Scalar for consistency) */
.custom-header {
  height: 56px;
  background-color: #1b1b1b;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(255,255,255,0.1);
  color: #fff;
  font-size: 14px;
  padding: 0 24px;
  position: sticky;
  top: 0;
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.custom-header b {
  font-size: 18px;
  letter-spacing: -0.02em;
  background: linear-gradient(135deg, #fff 0%, #aaa 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.custom-header nav {
  display: flex;
  align-items: center;
  gap: 24px;
}
.custom-header a {
  text-decoration: none;
  color: #aaa;
  font-weight: 500;
  transition: color 0.2s ease;
}
.custom-header a:hover {
  color: #fff;
}

.swagger-ui .topbar {
  display: none; /* Hide the default Swagger topbar in favor of our custom one */
}

{{CUSTOM_CSS}}
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
