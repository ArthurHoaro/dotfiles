#!/bin/bash

set -e

if [[ $# != 1 ]]; then
  printf "Usage: $0 <environment ID>\nExample: '$0 20' to deploy on dev-20\n";
  exit 1;
fi

PROJECT=$(git remote -v | head -n 1 | sed 's#.*bitbucket.org:cobrowser/\(.*\)\.git.*#\1#')
if [[ $? != 0 || ${#PROJECT} == 0 ]]; then
  printf "\nCould not find Git remote project name. Are you sure you are in the right folder?\nRun 'git remote -v'\n"
  exit 5
fi

ENVIRONMENT=$1
BRANCH=$(git branch --show-current)

if [[ -z "${KPUBLISH_DEBUG}" ]]; then
#  KPUBLISH_OUTPUT='--quiet'
  KPUBLISH_OUTPUT=''
fi

if [[ $BRANCH == "develop" ]]; then
  printf "You can not run this script on develop. Please switch to fix or feature branch.\n"
  exit 2;
fi

if [[ $BRANCH == dev-* ]]; then
  printf "You already are on dev-* branch.\n"
  while true; do
    read -p 'Which feature branch would you like to publish? ' readBranch
    git show-ref --verify --quiet refs/heads/$readBranch
    if [[ $? == 0 && $readBranch != dev-* ]]; then
      BRANCH=$readBranch
      break
    else
      printf "Invalid Git branch\n"
    fi
  done
fi

echo "== 1. Stash current changes =="

if [[ -z "${STASHID}" ]]; then
  export STASHID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
fi
git stash $KPUBLISH_OUTPUT push -m "kpublish ${STASHID}"

echo "== 2. Update develop branch =="

git checkout $KPUBLISH_OUTPUT develop
git pull $KPUBLISH_OUTPUT origin develop
if [[ $(ls -l package-lock.json* | wc -l) > 0 ]]; then
  git checkout -- package.json package-lock.json
fi
git checkout $KPUBLISH_OUTPUT $BRANCH

echo "== 3. Merge latest develop into $BRANCH"

git merge $KPUBLISH_OUTPUT develop

HAS_CONFLICTS=$(git ls-files -u | wc -l)
if [[ $HAS_CONFLICTS > 0 ]]; then
  echo "Merging develop has resulted in merge conflicts. Please resolve them an rerun the script."
  exit 3
fi

echo "== 4. Push changes on $BRANCH =="

git push $KPUBLISH_OUTPUT origin $BRANCH

echo "== 5. Merge $BRANCH into dev-$ENVIRONMENT"

git checkout $KPUBLISH_OUTPUT dev-$ENVIRONMENT
git pull $KPUBLISH_OUTPUT origin dev-$ENVIRONMENT
if [[ $(ls -l package-lock.json* | wc -l) > 0 ]]; then
  git checkout -f -- package.json package-lock.json
fi
git merge $KPUBLISH_OUTPUT $BRANCH

HAS_CONFLICTS=$(git ls-files -u | wc -l)
if [[ $HAS_CONFLICTS -gt 0 ]]; then
  echo "Merging $BRANCH has resulted in merge conflicts. Please resolve them an rerun the script."
  exit 4
fi

echo "== 6. Push changes on dev-$ENVIRONMENT"

git push $KPUBLISH_OUTPUT origin dev-$ENVIRONMENT

echo "== 7. Restore local changes"

git checkout $KPUBLISH_OUTPUT $BRANCH

HAS_STASH=$(git stash $KPUBLISH_OUTPUT list | grep ${STASHID} | wc -l)
if [[ $HAS_STASH -gt 0 ]]; then
  git stash $KPUBLISH_OUTPUT pop
fi

printf "== 8. All done! Follow the pipeline here:\nhttps://bitbucket.org/cobrowser/${PROJECT}/addon/pipelines/home#!/results/branch/dev-${ENVIRONMENT/\//%%252F}/page/1\n"

