#!/bin/bash
GITHUB_USERNAME=$1
GIT_REPO_NAME=$2

git remote add origin git@github.com:$GITHUB_USERNAME/$GIT_REPO_NAME.git
git push --all origin
git push --tags origin