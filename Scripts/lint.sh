#!/bin/bash

# Run SwiftLint on the project

echo "🔍 Running SwiftLint..."

if command -v swiftlint &> /dev/null; then
    swiftlint
else
    echo "❌ SwiftLint not installed. Run 'Scripts/setup.sh' first."
    exit 1
fi
