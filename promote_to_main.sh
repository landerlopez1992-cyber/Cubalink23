#!/usr/bin/env bash
set -e
git fetch origin
git checkout main
git pull --ff-only
git merge --no-ff build-test -m "Promote: cambios validados desde build-test"
git push origin main
echo "✅ Promovido a main."



