#!/usr/bin/env sh

# abort on errors
set -e

# build
yarn run build

# navigate into the build output directory
cd dist

# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME

git init
git add -A
git commit -m 'deploy'

# if you are deploying to https://ahuston3.github.io
# git push -f git@github.com:ahuston3/ahuston3.github.io.git main

# if you are deploying to https://ahuston3.github.io/q3-goals
git push -f git@github.com:ahuston3/q3-goals.git main:gh-pages

cd -