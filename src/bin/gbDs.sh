#!/usr/bin/env bash

# From https://blog.takanabe.tokyo/en/2020/04/remove-squash-merged-local-git-branches/

set -euo pipefail

echo "Removing out-dated local squash-merged branches..."
git fetch origin -p &>/dev/null
git for-each-ref refs/heads/ "--format=%(refname:short)" |
  while read -r branch; do
    ancestor=$(git merge-base origin/master $branch)
    temp=$(git commit-tree $(git rev-parse $branch^{tree}) -p $ancestor -m _)
    [[ $(git cherry origin/master $temp) == "-"* ]] && git branch -D $branch
  done
echo "Finished!"
