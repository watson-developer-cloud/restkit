FROM swiftdocker/swift:4.1
ADD . /restkit
WORKDIR /restkit
RUN rm -rf /restkit/.build/debug && swift package resolve && swift package clean
CMD swift test
