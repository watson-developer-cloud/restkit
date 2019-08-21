# Run integration tests on Linux
set -eu

if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  TARGET_BRANCH="$TRAVIS_BRANCH"
  GIT_SLUG="$TRAVIS_REPO_SLUG"
else
  TARGET_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
  GIT_SLUG="$TRAVIS_PULL_REQUEST_SLUG"
fi

GIT_PATH="https://github.com/$GIT_SLUG.git"

# we want to use the dockerfile
docker build - < Dockerfile -t restkit:linux-tests --build-arg git_path=$GIT_PATH --build-arg git_branch=$TARGET_BRANCH
docker run restkit:linux-tests
docker system prune -a -f
