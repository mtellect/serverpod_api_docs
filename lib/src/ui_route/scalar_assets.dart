/// Default assets for the Scalar API reference distribution.
class ScalarAssets {
  static const String indexHtmlTemplate = '''
<!doctype html>
<html>
  <head>
    <title>{{TITLE}}</title>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1" />
    <style>
      body {
        margin: 0;
      }
      :root {
        --scalar-custom-header-height: 56px;
      }
      .custom-header {
        height: var(--scalar-custom-header-height);
        background-color: var(--scalar-background-1);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        border-bottom: 1px solid var(--scalar-border-color);
        color: var(--scalar-color-1);
        font-size: 14px;
        padding: 0 24px;
        position: sticky;
        top: 0;
        z-index: 1000;
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-family: var(--scalar-font-body);
        transition: all 0.3s ease;
      }
      .custom-header b {
        font-size: 18px;
        letter-spacing: -0.02em;
        background: linear-gradient(135deg, var(--scalar-color-1) 0%, var(--scalar-color-2) 100%);
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
        color: var(--scalar-color-2);
        font-weight: 500;
        transition: color 0.2s ease;
      }
      .custom-header a:hover {
        color: var(--scalar-color-1);
      }
      .scalar-sidebar-footer {
        display: none !important;
      }
      /* Fallback for when the container above is nested differently */
      .scalar-sidebar-footer a,
      .scalar-sidebar-footer nav,
      .scalar-sidebar-integrations {
        display: none !important;
      }
      {{CUSTOM_CSS}}
    </style>
  </head>
  <body>
    <header class="custom-header scalar-app">
      <b>{{BRANDING_NAME}}</b>
      <nav>
        {{NAV_LINKS}}
      </nav>
    </header>
    <div id="scalar-app"></div>

    <!-- Load the Script -->
    <script src="https://cdn.jsdelivr.net/npm/@scalar/api-reference"></script>

    <!-- Initialize the Scalar API Reference -->
    <script>
      const specUrl = "{{SPEC_URL}}";
      const config = {{CONFIG}};
      
      Scalar.createApiReference('#scalar-app', {
        url: specUrl,
        ...config
      });
    </script>
  </body>
</html>
''';

  /// Predefined Scalar themes
  static const String themeDefault = 'default';
  static const String themeMars = 'mars';
  static const String themeDeepSpace = 'deepSpace';
  static const String themeSaturn = 'saturn';
  static const String themeSolarized = 'solarized';
  static const String themePurple = 'purple';
  static const String themeNone = 'none';
}
