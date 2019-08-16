# Run pod lint and integration tests on macOS

set -eu

./Scripts/pod-lint.sh
./Scripts/run-ios-tests.sh
