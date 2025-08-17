#!/bin/bash

# API Testing Script for Manual Verification
set -e

API_URL="${1:-http://ecs-nginx-demo-alb-1121756053.eu-central-1.elb.amazonaws.com}"
echo "🧪 Testing DevOps Demo API at: $API_URL"
echo "============================================"

# Test 1: Custom health Check
echo ""
echo "1️⃣  Testing page for custom string..."
HEALTH_RESPONSE=$(curl -s "$API_URL")
if echo "$HEALTH_RESPONSE" | grep -q "202508corrupted13 by JL"; then
    echo "✅ Custom string found"
else
    echo "❌ Custom string not found"
    echo "Response: $HEALTH_RESPONSE"
    exit 1   # <-- non-zero exit code makes workflow fail
fi