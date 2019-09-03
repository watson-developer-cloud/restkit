# Run integration tests on Linux
set -eu

SWIFT_VERSION=$1

if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
  TARGET_BRANCH="$TRAVIS_BRANCH"
  GIT_SLUG="$TRAVIS_REPO_SLUG"
else
  TARGET_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
  GIT_SLUG="$TRAVIS_PULL_REQUEST_SLUG"
fi

GIT_PATH="https://github.com/$GIT_SLUG.git"

# we want to use the dockerfile
docker build - < ./Docker/$SWIFT_VERSION/Dockerfile -t restkit:linux-tests-$SWIFT_VERSION --build-arg git_path=$GIT_PATH --build-arg git_branch=$TARGET_BRANCH --build-arg vcap_services=$VCAP_SERVICES --build-arg ibm_credentials_file=$IBM_CREDENTIALS_FILE

docker run restkit:linux-tests-$SWIFT_VERSION
docker system prune -a -f
