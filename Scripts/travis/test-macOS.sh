# Run pod lint and integration tests on macOS

set -e

brew update >/dev/null

./Scripts/pod-lint.sh
./Scripts/run-ios-tests.sh
