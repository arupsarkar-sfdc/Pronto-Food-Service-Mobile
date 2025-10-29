#!/bin/bash

# Format code using SwiftFormat

echo "🎨 Formatting code..."

if command -v swiftformat &> /dev/null; then
    swiftformat Sources/ Tests/ --swiftversion 5.7
    echo "✅ Code formatting complete!"
else
    echo "❌ SwiftFormat not installed. Run 'Scripts/setup.sh' first."
    exit 1
fi
