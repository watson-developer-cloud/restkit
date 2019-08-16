xcodebuild clean test \
-scheme RestKit \
-destination "platform=iOS Simulator,name=iPhone X,OS=12.4" | xcpretty || RC=${RC:~$?}\
/
