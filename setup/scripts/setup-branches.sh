#!/bin/bash
set -e

echo "🌿 Setting up correct branch structure..."

# Ensure we're on main branch
git checkout main 2>/dev/null || echo "Already on main or main doesn't exist"

# Create develop branch if it doesn't exist
if ! git show-ref --verify --quiet refs/heads/develop; then
    echo "📝 Creating develop branch..."
    git checkout -b develop
    git push origin develop
    echo "✅ Develop branch created and pushed"
else
    echo "✅ Develop branch already exists"
fi

# Switch back to main
git checkout main

# Remove environment branches if they exist (these should be folders, not branches)
for branch in dev stage prod; do
    if git show-ref --verify --quiet refs/heads/$branch; then
        echo "🗑️  Removing $branch branch (environments are folders, not branches)"
        git branch -D $branch
        git push origin --delete $branch 2>/dev/null || echo "Branch $branch not on remote"
    fi
done

echo ""
echo "✅ Branch structure setup complete!"
echo ""
echo "📋 Current branches:"
git branch -a
echo ""
echo "🚀 Next steps:"
echo "1. Push to 'develop' branch → deploys to dev environment"
echo "2. Push to 'main' branch → deploys to dev → stage → prod (with approvals)"
echo "3. Create feature branches from 'develop'"
echo ""
echo "📖 See docs/GITHUB_ACTIONS_GUIDE.md for detailed workflow instructions"
