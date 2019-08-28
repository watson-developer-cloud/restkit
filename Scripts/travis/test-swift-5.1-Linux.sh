# NOTE: this is a temporary script to run the RestKit build on the latest snapshot for the 5.1 swift preview
# it will be replaced by the swift 5.1 Docker image once it is made available

wget https://swift.org/builds/swift-5.1-branch/ubuntu1604/swift-5.1-DEVELOPMENT-SNAPSHOT-2019-08-28-a/swift-5.1-DEVELOPMENT-SNAPSHOT-2019-08-28-a-ubuntu16.04.tar.gz

tar xzvf swift-5.1-DEVELOPMENT-SNAPSHOT-2019-08-28-a-ubuntu16.04.tar.gz

export PATH=swift-5.1-DEVELOPMENT-SNAPSHOT-2019-08-28-a-ubuntu16.04/usr/bin:$PATH

# for docker image builds this is provided via the travis environment and then
# passed in as a build arg. we have to set this manually as we cannot use
# the root directory that we use in docker
export IBM_CREDENTIALS_FILE=$HOME/ibm-credentials.env

swift build

swift test
