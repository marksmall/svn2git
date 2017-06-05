#!/bin/bash

# Example: ./migrate.sh [SVN url] [GIT url]

svnurl=$1
giturl=$2

# Get list of all SVN committers.
svn log --xml --quiet | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /' > users.txt

reponame = '~/bare-repo'
# Clone SVN repo using git-svn.
git svn clone ${svnurl} --no-metadata -A users.txt --stdlayout ${reponame}

# Convert svn:ignore to .gitignore
cd ${reponame}
git svn show-ignore > .gitignore
git add .gitignore
git commit -m "Convert svn:ignore to .gitignore"

# Push repository to a bare git repository.
barerepo = '~/bare-repo.git'
git init --bare ${barerepo}
cd ${barerepo}
git symbolic-ref HEAD refs/heads/trunk

# Rename trunk branch to master.
git branch -m trunk master`

# Clean up branches and tags.
git for-each-ref --format='%(refname)' refs/heads/tags | cut -d / -f 4 |
while read ref
do
  git tag "${ref}" "refs/heads/tags/${ref}";
  git branch -D "tags/${ref}";
done

# Add remote to repository.
git remote add origin ${giturl}

# Push everything to remote.
git push origin --all
git push origin --tags
