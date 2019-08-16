FROM swiftdocker/swift:4.1
ARG git_path
RUN git clone $git_path
WORKDIR /restkit
RUN swift build
CMD swift test
