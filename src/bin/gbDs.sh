#!/usr/bin/env zsh

# From https://blog.takanabe.tokyo/en/2020/04/remove-squash-merged-local-git-branches/

set -e

git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo master
}

echo "Removing out-dated local squash-merged branches..."
git for-each-ref refs/heads/ "--format=%(refname:short)" |
  while read -r branch; do
    main=$(git_main_branch)
    ancestor=$(git merge-base origin/$main $branch)
    temp=$(git commit-tree $(git rev-parse $branch^{tree}) -p $ancestor -m _)
    [[ $(git cherry origin/$main $temp) == "-"* ]] && git branch -D $branch
  done
echo "Finished!"
