#!/usr/bin/env bash
# ==============================================================================
# elf media - UAE Filming Regulations & Drone Guide Publisher
# Automated GitHub Repository Initialization & GitHub Pages Deployment Tool
# ==============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

DEFAULT_ORG="elfmedia"
DEFAULT_REPO="uae-filming-guide"

GH_ORG="${GH_ORG:-$DEFAULT_ORG}"
GH_REPO="${GH_REPO:-$DEFAULT_REPO}"
PAT="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
AUTH_MODE=""
FORCE_PUSH=false

show_help() {
  cat << EOF
elf media - GitHub Pages Deployment Tool

Usage:
  ./publish.sh [options]

Options:
  -t, --token <PAT>    GitHub Personal Access Token (PAT) with repo scope
  -o, --org <NAME>     GitHub username or organization (default: elfmedia)
  -r, --repo <NAME>    GitHub repository name (default: uae-filming-guide)
  -s, --ssh            Use SSH authentication (git@github.com:...)
  -f, --force          Force push to remote main branch
  -h, --help           Show this help message

Environment Variables:
  GITHUB_TOKEN, GH_TOKEN   Personal Access Token
  GH_ORG                   Target GitHub Organization/User
  GH_REPO                  Target Repository Name

Examples:
  ./publish.sh --token ghp_xxxx
  GITHUB_TOKEN=ghp_xxxx ./publish.sh
  ./publish.sh --ssh --org my-org --repo my-repo
EOF
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--token)
      PAT="$2"
      AUTH_MODE="https"
      shift 2
      ;;
    -o|--org)
      GH_ORG="$2"
      shift 2
      ;;
    -r|--repo)
      GH_REPO="$2"
      shift 2
      ;;
    -s|--ssh)
      AUTH_MODE="ssh"
      shift
      ;;
    -f|--force)
      FORCE_PUSH=true
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "[-] Unknown argument: $1"
      show_help
      exit 1
      ;;
  esac
done

echo "================================================================="
echo "  elf media Creative Media Production - GitHub Pages Deployer"
echo "  Target Repo: ${GH_ORG}/${GH_REPO}"
echo "  Live URL:    https://${GH_ORG}.github.io/${GH_REPO}/"
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
  echo "[+] Working tree clean, no uncommitted changes."
else
  echo "[+] Committing files with regulatory specification payload..."
  git commit -m "feat: complete UAE commercial filming regulations & GCAA drone permit guide (2026)"
fi

echo ""
echo "-----------------------------------------------------------------"
echo " Remote Setup & Authentication"
echo "-----------------------------------------------------------------"

# Interactive prompts only if in interactive terminal and parameters missing
if [ -t 0 ]; then
  if [ -z "$AUTH_MODE" ] && [ -z "$PAT" ]; then
    read -r -p "Enter GitHub Username or Organization [$GH_ORG]: " USER_ORG_INPUT || true
    if [ -n "$USER_ORG_INPUT" ]; then GH_ORG="$USER_ORG_INPUT"; fi

    read -r -p "Enter GitHub Repository Name [$GH_REPO]: " USER_REPO_INPUT || true
    if [ -n "$USER_REPO_INPUT" ]; then GH_REPO="$USER_REPO_INPUT"; fi

    echo ""
    echo "Authentication options:"
    echo " 1) HTTPS with Personal Access Token (PAT) [Recommended]"
    echo " 2) SSH (git@github.com:...)"
    read -r -p "Select authentication mode (1/2) [default: 1]: " USER_AUTH_CHOICE || true
    USER_AUTH_CHOICE=${USER_AUTH_CHOICE:-1}

    if [ "$USER_AUTH_CHOICE" = "2" ]; then
      AUTH_MODE="ssh"
    else
      AUTH_MODE="https"
      echo ""
      echo "To generate a GitHub Personal Access Token (PAT):"
      echo " 1. Go to https://github.com/settings/tokens/new"
      echo " 2. Scope: Check 'repo' (and 'workflow')"
      echo ""
      read -r -s -p "Enter your GitHub Personal Access Token (PAT): " PAT || true
      echo ""
    fi
  fi
else
  # Non-interactive mode
  if [ -z "$AUTH_MODE" ]; then
    if [ -n "$PAT" ]; then
      AUTH_MODE="https"
    else
      echo "[-] Error: Non-interactive execution detected without authentication credentials."
      echo "    Provide credentials via one of:"
      echo "      --token <YOUR_PAT>"
      echo "      GITHUB_TOKEN=<YOUR_PAT> ./publish.sh"
      echo "      --ssh"
      exit 1
    fi
  fi
fi

# Set sanitized remote origin URL (token is NEVER embedded in git config)
SANITIZED_HTTPS_URL="https://github.com/${GH_ORG}/${GH_REPO}.git"
SSH_URL="git@github.com:${GH_ORG}/${GH_REPO}.git"

if [ "$AUTH_MODE" = "ssh" ]; then
  git remote remove origin 2>/dev/null || true
  git remote add origin "$SSH_URL"
  PUSH_ARGS=()
  if [ "$FORCE_PUSH" = true ]; then PUSH_ARGS+=("-f"); fi

  echo "[+] Pushing to $SSH_URL via SSH..."
  git push "${PUSH_ARGS[@]}" origin main
  git branch --set-upstream-to=origin/main main 2>/dev/null || true
  echo "[✓] Successfully published to GitHub via SSH!"

else
  # HTTPS with PAT
  if [ -z "$PAT" ]; then
    echo "[-] Error: Personal Access Token cannot be empty."
    echo "    Generate a token at https://github.com/settings/tokens/new with 'repo' scope."
    exit 1
  fi

  git remote remove origin 2>/dev/null || true
  git remote add origin "$SANITIZED_HTTPS_URL"

  AUTH_URL="https://${GH_ORG}:${PAT}@github.com/${GH_ORG}/${GH_REPO}.git"
  PUSH_ARGS=()
  if [ "$FORCE_PUSH" = true ]; then PUSH_ARGS+=("-f"); fi

  echo "[+] Pushing to $SANITIZED_HTTPS_URL..."
  # Push directly to target URL without saving the token in .git/config
  git push "${PUSH_ARGS[@]}" "$AUTH_URL" main:main

  # Configure sanitized tracking branch without embedding the token
  git config branch.main.remote origin
  git config branch.main.merge refs/heads/main
  echo "[✓] Successfully published to GitHub!"
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
