set -e

git pull # Needed to get the new version created by semantic-release
pod trunk push "IBMWatsonRestKit.podspec"
