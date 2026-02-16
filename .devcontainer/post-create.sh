#!/bin/bash
set -e

echo "Setting up development environment..."

# Install frontend dependencies
cd /workspace/frontend
npm install

# Install backend dependencies
cd /workspace/backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

echo ""
echo "============================================"
echo "  Development environment ready!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Open a terminal and run: cortex"
echo "  2. Or start the app: docker compose up"
echo ""
echo "Your Snowflake config from ~/.snowflake is mounted."
echo "Run 'cortex connections list' to verify."
echo ""
