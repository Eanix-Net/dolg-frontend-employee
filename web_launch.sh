#!/bin/bash
echo "Running Flutter web with HTML renderer for better CORS handling..."
flutter run -d chrome --web-renderer html --dart-define=API_URL=https://app.lawnbudy.net 