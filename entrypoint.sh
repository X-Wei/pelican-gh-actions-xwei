#!/bin/bash

# exit when any command fails
set -e

if [ -z "$GITHUB_ACTOR" ]
then
  # If running locally: generate html to "pelican_dir/output/" for preview.
  mkdir -p /home/blog && cd /home/blog
  cd pelican_dir && make html && cd ..
else 
  # If running on Github Actions: make html and commit to $remote_branch.
  echo "REPO: $GITHUB_REPOSITORY"
  echo "ACTOR: $GITHUB_ACTOR"

  echo '=================== Building blog ==================='
  cd pelican_dir && make publish && cd ..

  echo '=================== Publish to GitHub Pages ==================='
  remote_repo="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
  remote_branch=${GH_PAGES_BRANCH:=gh-pages}
  git init
  git remote add deploy "$remote_repo"
  git checkout $remote_branch || git checkout --orphan $remote_branch
  git config user.name "${GITHUB_ACTOR}"
  git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
  git add .
  echo -n 'Files to Commit:' && ls -l | wc -l
  timestamp=$(date +%s%3N)
  git commit -m "[ci skip] Automated deployment to GitHub Pages on $timestamp"
  git push deploy $remote_branch --force
  rm -fr .git
  cd ../
fi
echo '=================== Done  ==================='