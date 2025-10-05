#!/usr/bin/env bash
set -euo pipefail

GH_OWNER="chrisgarmon"
REPO_NAME="regenerate"
GCP_PROJECT_ID="regeneratemusicco"

BACKEND_RUN_UNIT_TESTS_URL="https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/run_unit_tests"
BACKEND_DEPLOY_PREVIEW_URL="https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/deploy_preview"
BACKEND_SMOKE_URL="https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/run_smoke_tests"
BACKEND_PROMOTE_URL="https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/promote_to_prod"

echo "Prefilled setup script ready. Edit these vars at the top before running."
