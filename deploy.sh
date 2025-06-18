#!/bin/bash

# deploy.sh - Automated deployment script for CuteAgent
# Usage: ./deploy.sh "Your commit message" [patch|minor|major]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if commit message is provided
if [ -z "$1" ]; then
    print_error "Commit message is required!"
    echo "Usage: ./deploy.sh \"Your commit message\" [patch|minor|major]"
    echo ""
    echo "Version Types:"
    echo "  patch - Bug fixes, small changes (auto-deploy)"
    echo "  minor - New features (requires confirmation)"
    echo "  major - Breaking changes (requires confirmation)"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh \"Fix bug in state sync\" patch"
    echo "  ./deploy.sh \"Add new StationAgent features\" minor"
    echo "  ./deploy.sh \"Breaking changes to API\" major"
    echo ""
    echo "Note: Minor and major releases require manual confirmation."
    exit 1
fi

COMMIT_MESSAGE="$1"
VERSION_TYPE="${2:-patch}"  # Default to patch if not specified

# Validate version type
if [[ ! "$VERSION_TYPE" =~ ^(patch|minor|major)$ ]]; then
    print_error "Invalid version type: $VERSION_TYPE"
    echo "Valid types: patch, minor, major"
    exit 1
fi

# Safety check for minor and major versions - require confirmation
if [[ "$VERSION_TYPE" == "minor" || "$VERSION_TYPE" == "major" ]]; then
    print_warning "⚠️  You are about to create a $VERSION_TYPE version release!"
    print_warning "This indicates significant changes that may affect users."
    echo ""
    
    if [[ "$VERSION_TYPE" == "major" ]]; then
        print_warning "🚨 MAJOR version indicates BREAKING CHANGES!"
        print_warning "This will increment from X.Y.Z to (X+1).0.0"
    else
        print_warning "📈 MINOR version indicates NEW FEATURES!"
        print_warning "This will increment from X.Y.Z to X.(Y+1).0"
    fi
    
    echo ""
    print_status "Commit message: $COMMIT_MESSAGE"
    echo ""
    
    read -p "Are you sure you want to proceed with $VERSION_TYPE version bump? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        print_status "Deployment cancelled by user."
        print_status "💡 Tip: Use 'patch' for bug fixes and small changes:"
        print_status "   ./deploy.sh \"Your message\" patch"
        exit 0
    fi
    
    print_success "✅ $VERSION_TYPE version bump confirmed!"
fi

print_status "Starting deployment process..."
print_status "Commit message: $COMMIT_MESSAGE"
print_status "Version bump type: $VERSION_TYPE"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not in a git repository!"
    exit 1
fi

# Check if bump-my-version is installed
if ! command -v bump-my-version &> /dev/null; then
    print_warning "bump-my-version not found, installing..."
    pip install bump-my-version
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    print_status "Found uncommitted changes, staging all files..."
    git add .
    
    print_status "Committing changes..."
    git commit -m "$COMMIT_MESSAGE"
    print_success "Changes committed successfully!"
else
    print_warning "No uncommitted changes found."
fi

# Run full test suite before deployment
print_status "Running comprehensive test suite..."
print_status "This ensures code quality before deployment. Deployment will stop if tests fail."
echo ""

# Check if tests directory exists
if [ ! -d "tests" ]; then
    print_error "Tests directory not found! Cannot validate code before deployment."
    print_error "Please ensure tests/ directory exists with test files."
    exit 1
fi

# Run mock tests first (fast validation)
print_status "🧪 Step 1/2: Running mock tests (fast validation)..."
if ! python tests/run_tests.py mock; then
    print_error "❌ Mock tests failed! Deployment aborted."
    print_error "Please fix the failing tests before deploying."
    exit 1
fi
print_success "✅ Mock tests passed!"

# Run real API tests (comprehensive validation)
print_status "🧪 Step 2/2: Running real API tests (comprehensive validation)..."
if ! python tests/run_tests.py real dev-token-123; then
    print_error "❌ Real API tests failed! Deployment aborted."
    print_error "Please fix the failing tests or check API connectivity before deploying."
    exit 1
fi
print_success "✅ All tests passed! Code is ready for deployment."

echo ""
print_success "🎯 Test validation completed successfully!"
print_status "✅ Mock tests: PASSED"
print_status "✅ Real API tests: PASSED"
print_status "Proceeding with version bump and deployment..."
echo ""

# Get current version
CURRENT_VERSION=$(grep -E '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
print_status "Current version: $CURRENT_VERSION"

# Bump version
print_status "Bumping version ($VERSION_TYPE)..."
bump-my-version bump "$VERSION_TYPE"

# Get new version
NEW_VERSION=$(grep -E '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/')
print_success "Version bumped from $CURRENT_VERSION to $NEW_VERSION"

# Push tags and changes (bump-my-version creates the tag automatically)
print_status "Pushing tags and changes to remote repository..."
git push --tags
git push origin main

print_success "Tag v$NEW_VERSION pushed!"

# Check if gh CLI is available for creating release
if command -v gh &> /dev/null; then
    print_status "Creating GitHub release..."
    
    # Generate release notes
    RELEASE_NOTES="## Changes in v$NEW_VERSION

$COMMIT_MESSAGE

### What's Changed
- $COMMIT_MESSAGE

**Full Changelog**: https://github.com/MasoudJB/cuteagent/compare/v$CURRENT_VERSION...v$NEW_VERSION"

    # Create release
    gh release create "v$NEW_VERSION" \
        --title "Release v$NEW_VERSION" \
        --notes "$RELEASE_NOTES" \
        --generate-notes
    
    print_success "GitHub release v$NEW_VERSION created!"
    print_status "This will trigger the PyPI deployment automatically."
else
    print_warning "GitHub CLI (gh) not found. Please create the release manually:"
    print_warning "1. Go to https://github.com/MasoudJB/cuteagent/releases/new"
    print_warning "2. Select tag: v$NEW_VERSION"
    print_warning "3. Set title: Release v$NEW_VERSION"
    print_warning "4. Add release notes and publish"
fi

print_success "🚀 Deployment completed successfully!"
print_status "Summary:"
print_status "  - Tests: ✅ All passed (Mock + Real API)"
print_status "  - Committed: $COMMIT_MESSAGE"
print_status "  - Version: $CURRENT_VERSION → $NEW_VERSION"
print_status "  - Tag: v$NEW_VERSION"
print_status "  - PyPI deployment will start automatically after release creation"

echo ""
print_status "You can monitor the deployment at:"
print_status "  - GitHub Actions: https://github.com/MasoudJB/cuteagent/actions"
print_status "  - PyPI: https://pypi.org/project/cuteagent/" 