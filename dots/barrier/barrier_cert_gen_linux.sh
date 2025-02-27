#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Variables
BARRIER_DIR="${HOME}/.local/share/barrier/SSL"
FINGERPRINT_DIR="${BARRIER_DIR}/Fingerprints"
CERT_NAME="Barrier.pem"
DAYS_VALID=365
KEY_SIZE=4096
SUBJECT="/CN=barrier"

# Ensure directories exist
mkdir -p "$BARRIER_DIR" "$FINGERPRINT_DIR"

# Generate the SSL certificate
echo "Generating SSL certificate..."
openssl req -x509 -nodes -days "$DAYS_VALID" -subj "$SUBJECT" \
  -newkey rsa:"$KEY_SIZE" -keyout "$BARRIER_DIR/$CERT_NAME" -out "$BARRIER_DIR/$CERT_NAME"

# Generate the SHA-256 fingerprint
echo "Generating fingerprint..."
openssl x509 -fingerprint -sha256 -noout -in "$BARRIER_DIR/$CERT_NAME" > "$FINGERPRINT_DIR/Local.txt"

# Modify the fingerprint format
sed -e "s/.*=/v2:sha256:/" -i "$FINGERPRINT_DIR/Local.txt"

echo "Certificate and fingerprint generated successfully!"
echo "Certificate: $BARRIER_DIR/$CERT_NAME"
echo "Fingerprint: $FINGERPRINT_DIR/Local.txt"
