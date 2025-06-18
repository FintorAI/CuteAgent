#!/bin/bash

# deploy.sh - Automated deployment script for CuteAgent
# 
# DEPLOYMENT RULES:
# 1. Commit message is REQUIRED - describes what changed
# 2. Version type defaults to 'patch' (bug fixes, small changes)
# 3. Script automatically: commits changes → bumps version → creates tag → pushes to remote
# 4. Use 'minor' for new features, 'major' for breaking changes
#
# Usage: ./deploy.sh "Your commit message" [patch|minor|major]
#
# Examples:
#   ./deploy.sh "Fix bug in state management"           # patch (default)
#   ./deploy.sh "Add new feature" minor                 # minor version bump
#   ./deploy.sh "Breaking API changes" major           # major version bump

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
    echo ""
    echo "Usage: ./deploy.sh \"Your commit message\" [patch|minor|major]"
    echo ""
    echo "🚀 DEPLOYMENT RULES:"
    echo "  • Commit message is REQUIRED (describes what changed)"
    echo "  • Version type defaults to 'patch' if not specified"
    echo "  • Script will commit all changes + bump version + create tag + push"
    echo ""
    echo "📋 VERSION TYPES:"
    echo "  patch  - Bug fixes, small changes (default)"
    echo "  minor  - New features, backwards compatible"
    echo "  major  - Breaking changes, API changes"
    echo ""
    echo "✅ EXAMPLES:"
    echo "  ./deploy.sh \"Fix StationAgent initialization bug\""
    echo "  ./deploy.sh \"Fix StationAgent initialization bug\" patch"
    echo "  ./deploy.sh \"Add new initial_state parameter\" minor"
    echo "  ./deploy.sh \"Remove deprecated shared_state_url\" major"
    echo ""
    echo "⚠️  IMPORTANT:"
    echo "  • Always describe WHAT you changed in the commit message"
    echo "  • Use patch for most changes (bug fixes, small improvements)"
    echo "  • Use minor for new features that don't break existing code"
    echo "  • Use major for breaking changes that affect users"
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

# Add all current changes to git staging
print_status "Staging all uncommitted changes..."
git add .

# Check if there are staged changes to commit
if ! git diff --cached --quiet; then
    print_status "Committing staged changes..."
    git commit -m "$COMMIT_MESSAGE"
    print_success "Changes committed successfully"
else
    print_status "No changes to commit"
fi

# Get current version from the tool
CURRENT_VERSION=$(bump-my-version show current_version)
print_status "Current version: $CURRENT_VERSION"

# Bump version, commit, and tag in one atomic operation
print_status "Bumping version and creating tag..."
bump-my-version bump "$VERSION_TYPE" --message "Release v{new_version}"

# Get new version
NEW_VERSION=$(bump-my-version show new_version)
print_success "Version bumped from $CURRENT_VERSION to $NEW_VERSION"

# Push commit and tags to the remote repository
print_status "Pushing commit and tags to remote repository..."
git push origin main
git push --tags

print_success "Commit and tag v$NEW_VERSION pushed successfully!"

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
print_status "  - Committed: $COMMIT_MESSAGE"
print_status "  - Version: $CURRENT_VERSION → $NEW_VERSION"
print_status "  - Tag: v$NEW_VERSION"
print_status "  - PyPI deployment will start automatically after release creation"
print_status ""
print_status "🎯 Next steps:"
print_status "  1. Monitor GitHub Actions for release creation"
print_status "  2. Verify PyPI deployment completes successfully"
print_status "  3. Test the new version: pip install --upgrade cuteagent"

echo ""

echo ""
print_status "You can monitor the deployment at:"
print_status "  - GitHub Actions: https://github.com/MasoudJB/cuteagent/actions"
print_status "  - PyPI: https://pypi.org/project/cuteagent/" 