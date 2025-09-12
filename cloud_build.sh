#!/usr/bin/env bash
set -e
BR=build-test
git checkout -B "$BR"
git add -A
git commit -m "WIP: build en nube (APK temporal)" || echo "Nada nuevo para commitear"
git push -u origin "$BR"
echo
echo "✅ Enviado a $BR. Ve a GitHub → Actions → run más reciente → Artifacts → app-release.apk"



