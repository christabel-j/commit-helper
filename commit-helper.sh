#!/usr/bin/env bash

set -e

# Simple colours
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}         Git Commit Helper Script${NC}"
echo -e "${BLUE}=========================================${NC}"
echo

# Check if we're inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}✗ You are not inside a Git repository.${NC}"
    exit 1
fi

# Show current branch
branch=$(git branch --show-current)
echo -e "${GREEN}Current branch:${NC} $branch"
echo

# Check if there are any changes
if git diff --quiet && git diff --cached --quiet; then
    echo -e "${GREEN}✓ Working tree is clean. Nothing to commit.${NC}"
    exit 0
fi

echo -e "${YELLOW}Current Git status:${NC}"
echo "-----------------------------------------"
git status
echo

# Ask to stage
read -rp "Stage ALL changes? (y/n): " stage_response

case "$stage_response" in
    y|Y|yes|YES|Yes)
        echo
        echo -e "${GREEN}Staging all changes...${NC}"
        git add -A
        ;;
    *)
        echo
        echo -e "${YELLOW}Nothing staged. Exiting.${NC}"
        exit 0
        ;;
esac

echo
echo -e "${YELLOW}Updated Git status:${NC}"
echo "-----------------------------------------"
git status

echo
while true; do
    echo -e "${YELLOW}Review staged changes:${NC}"
    echo "-----------------------------------------"
    echo "1) View summary"
    echo "2) View full diff"
    echo "3) Continue"
    echo

    read -rp "Choice: " review_choice

    case "$review_choice" in
        1)
            echo
            echo -e "${YELLOW}Summary:${NC}"
            echo "-----------------------------------------"
            git diff --cached --stat
            echo
            ;;
        2)
            echo
            echo -e "${YELLOW}Full diff:${NC}"
            echo "-----------------------------------------"
            git diff --cached
            echo
            ;;
        3)
            break
            ;;
        *)
            echo
            echo -e "${RED}Invalid choice. Please enter 1, 2 or 3.${NC}"
            echo
            ;;
    esac
done

echo

# Confirm commit
read -rp "Commit these changes? (y/n): " commit_confirm

case "$commit_confirm" in
    y|Y|yes|YES|Yes)
        ;;
    *)
        echo
        echo -e "${YELLOW}Commit cancelled. Your changes remain staged.${NC}"
        exit 0
        ;;
esac

echo

# Get commit message
while true; do
    read -rp "Commit message: " commit_message

    if [[ -n "$commit_message" ]]; then
        break
    fi

    echo -e "${RED}Commit message cannot be empty.${NC}"
done

echo
echo -e "${GREEN}Creating commit...${NC}"
git commit -m "$commit_message"

echo

# Ask to push
read -rp "Push to remote? (y/n): " push_response

case "$push_response" in
    y|Y|yes|YES|Yes)
        echo
        echo -e "${GREEN}Pushing...${NC}"
        git push
        echo
        echo -e "${GREEN}✓ Commit and push completed successfully!${NC}"
        ;;
    *)
        echo
        echo -e "${YELLOW}Commit created, but not pushed.${NC}"
        echo -e "${YELLOW}You can push later with:${NC} git push"
        ;;
esac
