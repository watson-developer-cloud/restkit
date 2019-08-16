FROM swiftdocker/swift:4.1
ARG git_path
ARG git_branch
RUN git clone $git_path --branch=$git_branch
WORKDIR /restkit
RUN swift build
CMD swift test
