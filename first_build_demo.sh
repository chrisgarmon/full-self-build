#!/usr/bin/env bash
set -euo pipefail

echo "=== First Build Demo ==="

: "${REQUEST_CREATE_URL:=${REQUEST_CREATE_URL:-}}"
: "${VALIDATE_SPEC_URL:=${VALIDATE_SPEC_URL:-}}"
: "${GENERATE_CODE_URL:=${GENERATE_CODE_URL:-}}"

if [ -z "$REQUEST_CREATE_URL" ]; then
  read -p "Paste request_create_function URL: " REQUEST_CREATE_URL
fi
if [ -z "$VALIDATE_SPEC_URL" ]; then
  read -p "Paste validate_function_spec URL: " VALIDATE_SPEC_URL
fi
if [ -z "$GENERATE_CODE_URL" ]; then
  read -p "Paste generate_function_code URL: " GENERATE_CODE_URL
fi

read -p "Firebase ID token if required (ENTER to skip): " ID_TOKEN || true
AUTH_HEADER=""
if [ -n "${ID_TOKEN:-}" ]; then
  AUTH_HEADER="-H Authorization: Bearer $ID_TOKEN"
fi

SPEC_FILE="$(mktemp)"
cat > "$SPEC_FILE" <<'EOF'
{
  "specVersion": "1.0",
  "proposer": "chatgpt@garmon",
  "signature": "fake",
  "function": {
    "name": "generateSongHooks",
    "runtime": "node18",
    "visibility": "internal",
    "scopes": ["firestore.write:hooks"],
    "dependencies": ["firebase-admin","firebase-functions"],
    "entrypoint": "index.handler",
    "memoryMb": 256,
    "timeoutSec": 30,
    "env": ["DATASET=hooks_v1"],
    "routes": [{"method":"POST","path":"/hooks/generate"}]
  },
  "tests": {
    "unit": [{"name":"returns_5_hooks","input":{"theme":"hope"},"expect":{"count":5}}],
    "smoke": [{"url":"/hooks/generate","method":"POST","body":{"theme":"love"}}]
  },
  "risk": { "dataRead": [], "dataWrite": ["firestore:hooks_generated/*"], "estimatedQPS": 2 },
  "notes": "Minimal hook generator"
}
EOF

echo "1) request_create_function ..."
CREATE_RESP=$(curl -s -X POST "$REQUEST_CREATE_URL" -H "Content-Type: application/json" $AUTH_HEADER -d "{\"data\": $(cat "$SPEC_FILE") }")
echo "Response: $CREATE_RESP"
BUILD_ID=$(echo "$CREATE_RESP" | sed -n 's/.*\"buildId\":\"\([^\"]*\)\".*/\1/p')
if [ -z "$BUILD_ID" ]; then
  echo "No buildId. Exiting."; exit 1;
fi

echo "2) validate_function_spec ..."
VALIDATE_RESP=$(curl -s -X POST "$VALIDATE_SPEC_URL" -H "Content-Type: application/json" $AUTH_HEADER -d "{\"data\": {\"buildId\": \"$BUILD_ID\"} }")
echo "Response: $VALIDATE_RESP"

echo "3) generate_function_code ..."
GEN_RESP=$(curl -s -X POST "$GENERATE_CODE_URL" -H "Content-Type: application/json" $AUTH_HEADER -d "{\"data\": {\"buildId\": \"$BUILD_ID\"} }")
echo "Response: $GEN_RESP"

echo "=== Watch GitHub PR + Actions for build $BUILD_ID ==="
