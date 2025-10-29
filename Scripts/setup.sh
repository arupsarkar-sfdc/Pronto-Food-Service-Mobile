#!/bin/bash

# Development environment setup script

echo "🔧 Setting up development environment..."

# Install SwiftLint if not installed
if ! command -v swiftlint &> /dev/null; then
    echo "Installing SwiftLint..."
    brew install swiftlint
fi

# Install SwiftFormat if not installed
if ! command -v swiftformat &> /dev/null; then
    echo "Installing SwiftFormat..."
    brew install swiftformat
fi

echo "✅ Development environment setup complete!"
