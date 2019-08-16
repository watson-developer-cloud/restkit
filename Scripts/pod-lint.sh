#!/bin/bash

# This script runs a linter on the RestKit pod
# This must be run to ensure that every pod is ready to be published to Cocoapods.

pod lib lint IBMWatsonRestKit.podspec
