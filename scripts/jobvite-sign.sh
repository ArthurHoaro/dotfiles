#!/usr/bin/env bash
#
# sign-jobvite.sh
#
# Usage:
#   # 1) Pass payload via stdin:
#   cat payload.json | ./sign-jobvite.sh "YOUR_SIGNING_KEY"
#
#   # 2) Or pass payload file as second argument:
#   ./sign-jobvite.sh "YOUR_SIGNING_KEY" path/to/payload.json
#
# Output:
#   A Base64-encoded HMAC-SHA256 signature of the exact payload bytes.
#

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <SigningKey> [payload_file]" >&2
  exit 1
fi

SIGNING_KEY="$1"

# Read the raw JSON body:
if [ -n "$2" ]; then
  # If a filename is given, read from the file
  PAYLOAD=$(command cat "$2")
else
  # Otherwise, read from stdin
  PAYLOAD=$(command cat)
fi

# Compute HMAC-SHA256 → binary → base64
#   - openssl dgst -sha256 -hmac "$SIGNING_KEY" -binary  : HMAC-SHA256(raw bytes)
#   - base64                                          : encode to Base64 string
SIGNATURE=$(printf '%s' "$PAYLOAD" \
  | openssl dgst -sha256 -hmac "$SIGNING_KEY" -binary \
  | base64)

# Print only the signature (no extra whitespace/newlines)
printf '%s' "$SIGNATURE"
echo

