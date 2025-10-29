#!/bin/bash

# Fix remaining README.md conflicts in Xcode project
# This script specifically targets README.md files causing build conflicts

set -e

PROJECT_NAME="ProntoFoodDeliveryApp"
PROJECT_FILE="${PROJECT_NAME}.xcodeproj/project.pbxproj"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🔧 Fixing README.md build conflicts..."

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    print_error "Project file not found: $PROJECT_FILE"
    exit 1
fi

print_step "Backing up project file..."
cp "$PROJECT_FILE" "${PROJECT_FILE}.readme_backup"
print_success "Backup created: ${PROJECT_FILE}.readme_backup"

print_step "Finding all README.md files..."
ALL_README_FILES=$(find . -name "README.md" -type f | grep -v ".git" | sort)

echo "Found README.md files:"
echo "$ALL_README_FILES"
echo ""

print_step "Analyzing project file for README.md references..."

# Show which README files are referenced in the project
echo "README.md files currently in Xcode project:"
grep -n "README.md" "$PROJECT_FILE" | head -10
echo ""

print_step "Removing ALL README.md file references from Xcode project..."

# Create a more aggressive removal
# Remove any line containing README.md
sed -i.tmp '/README\.md/d' "$PROJECT_FILE"

# Also remove any file reference IDs that might be orphaned
# This removes PBXFileReference entries for README files
sed -i.tmp '/fileRef.*README/d' "$PROJECT_FILE"

# Remove build file entries for README
sed -i.tmp '/PBXBuildFile.*README/d' "$PROJECT_FILE"

# Clean up temporary file
rm -f "${PROJECT_FILE}.tmp"

print_step "Validating project file..."

# Validate the project file syntax
if ! plutil -lint "$PROJECT_FILE" >/dev/null 2>&1; then
    print_error "Project file syntax is invalid. Restoring backup..."
    mv "${PROJECT_FILE}.readme_backup" "$PROJECT_FILE"
    exit 1
fi

print_success "Project file validated successfully!"

print_step "Double-checking for remaining README references..."
README_REFS=$(grep -c "README.md" "$PROJECT_FILE" || echo "0")

if [ "$README_REFS" -eq "0" ]; then
    print_success "All README.md references removed from project!"
else
    print_warning "Still found $README_REFS README.md references. Manual cleanup may be needed."
    echo ""
    echo "Remaining references:"
    grep -n "README.md" "$PROJECT_FILE"
fi

print_step "What to do with the actual README.md files?"
echo ""
echo "The files causing conflicts are likely:"
echo "- Root README.md (keep this one!)"
echo "- Sources/Core/Models/README.md"
echo "- Sources/Core/Services/README.md"
echo "- Documentation/PROJECT_STRUCTURE.md"
echo ""
echo "Options:"
echo "1) Keep all README files (recommended)"
echo "2) Delete README files in Sources/ only"
echo "3) Show me which ones to delete manually"
echo ""
read -p "Enter your choice (1, 2, or 3): " choice

case $choice in
    1)
        print_success "Keeping all README files for documentation"
        ;;
    2)
        print_step "Deleting README files in Sources/ directory only..."
        find Sources/ -name "README.md" -type f -delete 2>/dev/null || true
        print_success "Sources README files deleted"
        ;;
    3)
        echo ""
        print_step "Files you should consider removing from Xcode (not deleting):"
        echo "In Xcode Navigator:"
        echo "1. Select each README.md file in Sources/ folders"
        echo "2. In File Inspector (right panel), UNCHECK 'ProntoFoodDeliveryApp' target"
        echo "3. Keep the root README.md for project documentation"
        echo ""
        print_warning "Manual approach: Right-click problematic README files → Delete → Remove Reference (not Move to Trash)"
        ;;
    *)
        print_warning "Invalid choice. No files deleted."
        ;;
esac

echo ""
print_success "Fix attempt completed!"
print_warning "Next steps:"
echo "1. Open Xcode"
echo "2. Clean Build Folder (Product → Clean Build Folder)"
echo "3. Build the project"
echo ""
print_warning "If you still get conflicts, the issue might be duplicate file names."
print_warning "Check Build Phases → Copy Bundle Resources for any README.md entries and remove them."

echo ""
print_step "Quick diagnosis command:"
echo "If problems persist, run this in Xcode's terminal:"
echo "grep -r 'README.md' ${PROJECT_NAME}.xcodeproj/"