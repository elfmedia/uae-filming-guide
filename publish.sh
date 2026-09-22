#!/usr/bin/env bash
# ==============================================================================
# elf media - UAE Filming Regulations & Drone Guide Publisher
# Automated GitHub Repository Initialization & GitHub Pages Deployment Tool
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "================================================================="
echo "  elf media Creative Media Production - GitHub Pages Deployer"
echo "  Target Repo: uae-filming-guide (elfmedia.github.io/uae-filming-guide)"
echo "================================================================="
echo ""

# Ensure git is installed
if ! command -v git &> /dev/null; then
  echo "[-] Error: git is not installed on this machine."
  exit 1
fi

# Configure local git repository if not already initialized
if [ ! -d ".git" ]; then
  echo "[+] Initializing new Git repository (main branch)..."
  git init -b main
else
  echo "[+] Git repository already initialized."
  git branch -M main
fi

# Configure git committer metadata locally for this repo
git config user.name "elf media"
git config user.email "info@elfmedia.ae"

# Stage all files
git add .
if git diff-index --quiet HEAD -- 2>/dev/null; then
  echo "[+] Working tree clean, no new changes to commit."
else
  echo "[+] Committing files with regulatory specification payload..."
  git commit -m "feat: complete UAE commercial filming regulations & GCAA drone permit guide (2026)"
fi

echo ""
echo "-----------------------------------------------------------------"
echo " Remote Setup & Authentication"
echo "-----------------------------------------------------------------"

# Check for existing remote
CURRENT_REMOTE="$(git remote get-url origin 2>/dev/null || true)"

if [ -n "$CURRENT_REMOTE" ]; then
  echo "[i] Existing remote origin found: $CURRENT_REMOTE"
  read -r -p "Do you want to push to this remote? (y/n) [default: y]: " USE_CURRENT
  USE_CURRENT=${USE_CURRENT:-y}
  if [[ "$USE_CURRENT" =~ ^[Yy]$ ]]; then
    echo "[+] Pushing to origin main..."
    git push -u origin main
    echo "[✓] Successfully published to GitHub!"
    exit 0
  fi
fi

# Gather remote details
DEFAULT_ORG="elfmedia"
DEFAULT_REPO="uae-filming-guide"

echo ""
read -r -p "Enter GitHub Username or Organization [$DEFAULT_ORG]: " GH_ORG
GH_ORG=${GH_ORG:-$DEFAULT_ORG}

read -r -p "Enter GitHub Repository Name [$DEFAULT_REPO]: " GH_REPO
GH_REPO=${GH_REPO:-$DEFAULT_REPO}

echo ""
echo "Authentication options:"
echo " 1) HTTPS with Personal Access Token (PAT) [Recommended]"
echo " 2) SSH (git@github.com:...)"
read -r -p "Select authentication mode (1/2) [default: 1]: " AUTH_MODE
AUTH_MODE=${AUTH_MODE:-1}

if [ "$AUTH_MODE" = "1" ]; then
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    PAT="$GITHUB_TOKEN"
    echo "[+] Using GITHUB_TOKEN from environment."
  else
    echo ""
    echo "To generate a GitHub Personal Access Token (PAT):"
    echo " 1. Go to https://github.com/settings/tokens (or fine-grained tokens)"
    echo " 2. Generate a token with 'repo' scope."
    echo ""
    read -r -s -p "Enter your GitHub Personal Access Token (PAT): " PAT
    echo ""
  fi

  if [ -z "$PAT" ]; then
    echo "[-] Error: Token cannot be empty."
    exit 1
  fi

  REMOTE_URL="https://${GH_ORG}:${PAT}@github.com/${GH_ORG}/${GH_REPO}.git"
  # Set sanitized origin (without embedded token) in git config, then push with authenticated URL
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/${GH_ORG}/${GH_REPO}.git"

  echo "[+] Pushing to https://github.com/${GH_ORG}/${GH_REPO}.git..."
  git push -u "$REMOTE_URL" main
  echo "[✓] Successfully published to GitHub!"

elif [ "$AUTH_MODE" = "2" ]; then
  REMOTE_URL="git@github.com:${GH_ORG}/${GH_REPO}.git"
  git remote remove origin 2>/dev/null || true
  git remote add origin "$REMOTE_URL"

  echo "[+] Pushing to $REMOTE_URL..."
  git push -u origin main
  echo "[✓] Successfully published to GitHub!"
else
  echo "[-] Invalid selection."
  exit 1
fi

echo ""
echo "================================================================="
echo " [✓] Next Steps to Activate GitHub Pages (DA 96+):"
echo " 1. Open: https://github.com/${GH_ORG}/${GH_REPO}/settings/pages"
echo " 2. Under 'Build and deployment' -> 'Source':"
echo "    - Select 'GitHub Actions' (workflow will run automatically)"
echo "    - Or select 'Deploy from a branch' -> 'main' / '/(root)'"
echo " 3. Your guide will be live at: https://${GH_ORG}.github.io/${GH_REPO}/"
echo "================================================================="
