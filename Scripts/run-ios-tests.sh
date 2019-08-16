set -o pipefail

xcodebuild clean test -scheme RestKit -destination "platform=iOS Simulator,name=iPhone X,OS=12.1" | xcpretty
