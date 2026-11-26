#!/bin/sh
set -eu

OUT_DIR="${OUT_DIR:-/out}"
mkdir -p "$OUT_DIR"

# Sync freshly built Windows binaries into the shared volume
rm -rf "${OUT_DIR:?}"/*
cp -a /dist/. "$OUT_DIR/"

# Generate appsettings.local.json from environment variables
BROKER_HOST="${PRINT_BROKER_HOST:-rabbitmq.stand.local}"
BROKER_PORT="${PRINT_BROKER_PORT:-5672}"
BROKER_USER="${PRINT_BROKER_USER:-guest}"
BROKER_PASS="${PRINT_BROKER_PASS:-guest}"
STORAGE_ENDPOINT="${PRINT_STORAGE_ENDPOINT:-minio.stand.local:9000}"
STORAGE_ACCESS_KEY="${PRINT_STORAGE_ACCESS_KEY:-minioadmin}"
STORAGE_SECRET_KEY="${PRINT_STORAGE_SECRET_KEY:-minioadmin}"
STORAGE_BUCKET="${PRINT_STORAGE_BUCKET:-photostand}"
STORAGE_USE_SSL="${PRINT_STORAGE_USE_SSL:-false}"
PRINTER_NAME="${PRINTER_NAME:-}"
PAPER_WIDTH="${PAPER_WIDTH_INCHES:-6.0}"
PAPER_HEIGHT="${PAPER_HEIGHT_INCHES:-4.0}"

cat > "$OUT_DIR/appsettings.local.json" <<EOF
{
  "Broker": {
    "Host": "${BROKER_HOST}",
    "Port": ${BROKER_PORT},
    "Username": "${BROKER_USER}",
    "Password": "${BROKER_PASS}",
    "JobsQueue": "print.jobs",
    "ResultsQueue": "print.status"
  },
  "Storage": {
    "Endpoint": "${STORAGE_ENDPOINT}",
    "AccessKey": "${STORAGE_ACCESS_KEY}",
    "SecretKey": "${STORAGE_SECRET_KEY}",
    "Bucket": "${STORAGE_BUCKET}",
    "TempDirectory": "./tmp/",
    "UseSSL": ${STORAGE_USE_SSL}
  },
  "Printing": {
    "PrinterName": "${PRINTER_NAME}",
    "PaperWidthInches": ${PAPER_WIDTH},
    "PaperHeightInches": ${PAPER_HEIGHT}
  }
}
EOF

echo "PrintSvc Windows bundle exported to $OUT_DIR (Broker=${BROKER_HOST}:${BROKER_PORT}, Storage=${STORAGE_ENDPOINT})"
