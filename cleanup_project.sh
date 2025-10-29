#!/bin/bash

# Clean up .gitkeep and README files from Xcode project
# This script removes problematic files that shouldn't be in the app target

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

echo "🧹 Cleaning up .gitkeep and README files from Xcode project..."

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    print_error "Project file not found: $PROJECT_FILE"
    print_error "Make sure you're running this from the project root directory"
    exit 1
fi

print_step "Backing up project file..."
cp "$PROJECT_FILE" "${PROJECT_FILE}.backup"
print_success "Backup created: ${PROJECT_FILE}.backup"

print_step "Finding problematic files..."

# Find all .gitkeep files
GITKEEP_FILES=$(find . -name ".gitkeep" -type f)
README_FILES=$(find Sources/ -name "README.md" -type f 2>/dev/null || true)

echo "Found .gitkeep files:"
echo "$GITKEEP_FILES"
echo ""
echo "Found README.md files in Sources:"
echo "$README_FILES"
echo ""

print_step "Removing file references from Xcode project..."

# Remove .gitkeep references from project.pbxproj
if [ -n "$GITKEEP_FILES" ]; then
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            filename=$(basename "$file")
            # Remove lines containing .gitkeep references
            sed -i.tmp "/.gitkeep/d" "$PROJECT_FILE"
            echo "Removed references to: $file"
        fi
    done <<< "$GITKEEP_FILES"
fi

# Remove README.md references from project.pbxproj (only in Sources)
if [ -n "$README_FILES" ]; then
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            filename=$(basename "$file")
            filepath=$(echo "$file" | sed 's|^\./||')
            # Remove lines containing this specific README.md path
            sed -i.tmp "/$filepath/d" "$PROJECT_FILE"
            echo "Removed references to: $file"
        fi
    done <<< "$README_FILES"
fi

# Clean up temporary files
rm -f "${PROJECT_FILE}.tmp"

print_step "Asking what to do with the actual files..."

echo ""
print_warning "What would you like to do with the actual .gitkeep files?"
echo "1) Keep them (recommended - they maintain empty folders in git)"
echo "2) Delete them completely"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        print_success "Keeping .gitkeep files for git folder structure"
        ;;
    2)
        print_step "Deleting .gitkeep files..."
        if [ -n "$GITKEEP_FILES" ]; then
            while IFS= read -r file; do
                if [ -n "$file" ] && [ -f "$file" ]; then
                    rm "$file"
                    echo "Deleted: $file"
                fi
            done <<< "$GITKEEP_FILES"
        fi
        print_success "All .gitkeep files deleted"
        ;;
    *)
        print_warning "Invalid choice. Keeping .gitkeep files by default."
        ;;
esac

echo ""
print_warning "What would you like to do with README.md files in Sources?"
echo "1) Keep them (they're documentation)"
echo "2) Delete them"
echo ""
read -p "Enter your choice (1 or 2): " readme_choice

case $readme_choice in
    1)
        print_success "Keeping README.md files for documentation"
        ;;
    2)
        print_step "Deleting README.md files from Sources..."
        if [ -n "$README_FILES" ]; then
            while IFS= read -r file; do
                if [ -n "$file" ] && [ -f "$file" ]; then
                    rm "$file"
                    echo "Deleted: $file"
                fi
            done <<< "$README_FILES"
        fi
        print_success "All Sources README.md files deleted"
        ;;
    *)
        print_warning "Invalid choice. Keeping README.md files by default."
        ;;
esac

print_step "Validating project file..."

# Check if the project file is still valid
if plutil -lint "$PROJECT_FILE" >/dev/null 2>&1; then
    print_success "Project file is valid"
else
    print_error "Project file may be corrupted. Restoring backup..."
    mv "${PROJECT_FILE}.backup" "$PROJECT_FILE"
    print_error "Backup restored. Please try again or fix manually."
    exit 1
fi

print_success "Cleanup completed successfully!"
print_warning "Next steps:"
echo "1. Open Xcode"
echo "2. Clean Build Folder (Product → Clean Build Folder or Cmd+Shift+K)"
echo "3. Build the project (Product → Build or Cmd+B)"
echo ""
print_success "Your project should now build without conflicts!"

# Optional: Show file count before and after
echo ""
print_step "Summary:"
REMAINING_GITKEEP=$(find . -name ".gitkeep" -type f | wc -l | xargs)
REMAINING_README=$(find Sources/ -name "README.md" -type f 2>/dev/null | wc -l | xargs)
echo "Remaining .gitkeep files: $REMAINING_GITKEEP"
echo "Remaining README.md files in Sources: $REMAINING_README"