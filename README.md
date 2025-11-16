<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>NeighborNet - README</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial; line-height:1.6; color:#111; padding:20px; max-width:900px; margin:auto; }
    h1,h2{ color:#0b5cff; }
    pre { background:#f6f8fa; padding:12px; border-radius:6px; overflow:auto; }
    ul { margin-top:0; }
    .muted { color:#555; font-size:0.95em; }
  </style>
</head>
<body>
  <h1>NeighborNet — Neighborhood Safety & Complaint App</h1>

  <p class="muted">A simple mobile app for citizens of Lahore to report crimes and civic issues, view basic heatmaps, and increase community safety.</p>

  <h2>Overview</h2>
  <p>NeighborNet enables users to report street crimes, harassment, theft, and civic problems such as broken streetlights or sanitation issues. The app includes complaint tracking, a basic heatmap UI, and community awareness tools.</p>

  <h2>Tech Stack</h2>
  <ul>
    <li><strong>Frontend:</strong> Flutter, Dart</li>
    <li><strong>Backend:</strong> Python, Django, SQLite</li>
    <li><strong>Version Control:</strong> Git &amp; GitHub</li>
  </ul>

  <h2>Features</h2>
  <ul>
    <li>User signup & login</li>
    <li>Submit and view complaints</li>
    <li>Basic heatmap interface (UI)</li>
    <li>Django REST API with SQLite</li>
  </ul>

  <h2>Setup</h2>

  <h3>Backend (Django)</h3>
  <pre><code>cd neighbornet_backend
python manage.py migrate
python manage.py runserver
</code></pre>

  <h3>Frontend (Flutter)</h3>
  <pre><code>cd neighbornet_app
flutter pub get
flutter run -d chrome
</code></pre>

  <h2>Future Enhancements</h2>
  <ul>
    <li>Push notifications</li>
    <li>AI-based crime predictions</li>
    <li>Urdu &amp; multilingual support</li>
  </ul>
</body>
</html>
