FROM swift:4.1.3
ARG vcap_services
ENV VCAP_SERVICES=$vcap_services
ARG ibm_credentials_file
ENV IBM_CREDENTIALS_FILE=$ibm_credentials_file
ARG git_path
ARG git_branch
RUN git clone $git_path --branch=$git_branch
WORKDIR /restkit
RUN swift build
CMD swift test
