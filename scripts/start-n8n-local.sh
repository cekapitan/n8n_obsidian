#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "Missing .env file. Copy .env.example to .env and edit values first."
  exit 1
fi

set -a
source .env
set +a

exec n8n start
