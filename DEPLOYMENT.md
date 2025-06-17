# Deployment Guide

This guide explains how to deploy new versions of CuteAgent using the automated deployment system.

## 🚀 Quick Deployment

Use the `deploy.sh` script for automated deployments:

```bash
# Patch version (0.0.15 → 0.0.16)
./deploy.sh "Add new StationAgent features"

# Minor version (0.0.15 → 0.1.0) 
./deploy.sh "Add significant new features" minor

# Major version (0.0.15 → 1.0.0)
./deploy.sh "Breaking API changes" major
```

## 📋 What the Deploy Script Does

1. **Validates input** - Checks commit message and version type
2. **Commits changes** - Stages and commits all uncommitted changes
3. **Bumps version** - Updates version in `pyproject.toml` and `__init__.py`
4. **Creates git tag** - Creates and pushes a version tag (e.g., `v0.0.16`)
5. **Creates GitHub release** - Automatically creates a GitHub release
6. **Triggers PyPI deployment** - Release creation triggers the PyPI publishing workflow

## 🔄 Automated Workflow

### The Process Flow

```
1. Developer runs deploy.sh
   ↓
2. Script commits changes and bumps version
   ↓  
3. Script pushes tag (e.g., v0.0.16)
   ↓
4. GitHub Action detects tag push
   ↓
5. Auto-release workflow creates GitHub release
   ↓
6. Release creation triggers PyPI workflow
   ↓
7. Package published to PyPI automatically
```

### GitHub Workflows

- **`auto-release.yml`** - Creates releases when version tags are pushed
- **`pypi.yml`** - Publishes to PyPI when releases are created

## 🛠️ Requirements

### For deploy.sh script:
- `bumpversion` (auto-installed if missing)
- `gh` CLI (optional, for automatic release creation)
- Git repository with remote origin

### For GitHub Actions:
- Repository secrets:
  - `PYPI_USERNAME` - Your PyPI username
  - `PYPI_PASSWORD` - Your PyPI password/token

## 📦 Version Types

- **patch** (default): Bug fixes, small improvements (0.0.15 → 0.0.16)
- **minor**: New features, backwards compatible (0.0.15 → 0.1.0)  
- **major**: Breaking changes (0.0.15 → 1.0.0)

## 🎯 Usage Examples

### Standard Feature Addition
```bash
./deploy.sh "Add comprehensive documentation and examples"
```

### New Minor Feature
```bash
./deploy.sh "Add server coordination features" minor
```

### Breaking Changes
```bash
./deploy.sh "Refactor API for better usability" major
```

### Bug Fix
```bash
./deploy.sh "Fix authentication error handling" patch
```

## 🔍 Monitoring Deployments

### Check Status
- **GitHub Actions**: https://github.com/MasoudJB/cuteagent/actions
- **PyPI Package**: https://pypi.org/project/cuteagent/
- **Releases**: https://github.com/MasoudJB/cuteagent/releases

### Verify Deployment
```bash
# Check latest version on PyPI
pip index versions cuteagent

# Install latest version
pip install --upgrade cuteagent

# Verify in Python
python -c "import cuteagent; print(cuteagent.__version__)"
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Deploy script fails with "Not in a git repository"
```bash
# Make sure you're in the project root
cd /path/to/cuteagent
./deploy.sh "Your message"
```

#### 2. PyPI deployment fails
- Check repository secrets are set correctly
- Verify PyPI credentials in GitHub Settings → Secrets

#### 3. GitHub release not created
- Install GitHub CLI: `brew install gh` (macOS) or download from github.com/cli/cli
- Login: `gh auth login`

#### 4. Version not bumped correctly
- Check `pyproject.toml` has correct bumpversion configuration
- Verify both `pyproject.toml` and `__init__.py` are updated

### Manual Release Creation

If automatic release creation fails:

1. Go to https://github.com/MasoudJB/cuteagent/releases/new
2. Select the tag created by deploy.sh (e.g., `v0.0.16`)
3. Set title: `Release v0.0.16`
4. Add release notes
5. Click "Publish release"

This will trigger the PyPI deployment automatically.

## 🔧 Script Configuration

### Customizing deploy.sh

The script can be modified to:
- Change default branch (currently `main`)
- Modify release note templates
- Add additional validation steps
- Integrate with other tools

### Environment Variables

```bash
# Optional: Set default branch
export DEFAULT_BRANCH="main"

# Optional: GitHub repository
export GITHUB_REPOSITORY="MasoudJB/cuteagent"
```

## 📝 Best Practices

1. **Test before deploying** - Run tests locally first
2. **Write clear commit messages** - They become release notes
3. **Use semantic versioning** - Choose version type carefully
4. **Monitor deployments** - Check GitHub Actions and PyPI
5. **Keep changelog updated** - The script generates automatic changelogs

## 🔄 Rollback Process

If you need to rollback a deployment:

1. **Remove the tag**:
   ```bash
   git tag -d v0.0.16
   git push origin :refs/tags/v0.0.16
   ```

2. **Delete the release** (optional):
   ```bash
   gh release delete v0.0.16
   ```

3. **Revert version changes**:
   ```bash
   git revert HEAD
   git push origin main
   ```

Note: PyPI packages cannot be deleted, only yanked from the index.

---

## 🎉 Ready to Deploy!

Your automated deployment system is ready. Just run:

```bash
./deploy.sh "Your awesome new feature"
```

And watch the magic happen! 🚀 