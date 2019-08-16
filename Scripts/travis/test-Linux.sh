# Run integration tests on Linux

# we want to use the dockerfile
docker build - < Dockerfile -t restkit:linux-tests --build-arg git_path=$TRAVIS_BRANCH
docker run restkit:linux-tests
docker system prune -a -f
