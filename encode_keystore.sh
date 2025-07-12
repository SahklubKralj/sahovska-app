#!/bin/bash
# Script to encode keystore for GitHub Secrets

echo "=== Encoding keystore for GitHub Actions ==="

# Check if keystore exists
if [ ! -f "android/upload-keystore.jks" ]; then
    echo "❌ Keystore not found at android/upload-keystore.jks"
    exit 1
fi

# Encode keystore to base64
echo "Encoding keystore to base64..."
base64_keystore=$(base64 -w 0 android/upload-keystore.jks)

echo ""
echo "✅ Success! Add these secrets to your GitHub repository:"
echo ""
echo "Repository Settings → Secrets and variables → Actions → New repository secret"
echo ""
echo "1. KEYSTORE_BASE64:"
echo "$base64_keystore"
echo ""
echo "2. STORE_PASSWORD:"
echo "mali2025genijalci"
echo ""
echo "3. KEY_PASSWORD:"
echo "mali2025genijalci"
echo ""
echo "4. KEY_ALIAS:"
echo "upload"
echo ""
echo "After adding secrets, push to GitHub and the build will run automatically!"