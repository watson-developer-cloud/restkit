set -o pipefail

xcodebuild clean test -scheme RestKit -destination "platform=iOS Simulator,name=iPhone 8" | xcpretty
