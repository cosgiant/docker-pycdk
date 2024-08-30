FROM python:3.9-alpine

# Set image labels
LABEL maintainer="mike@cumulustech.us"

# Set build args with defaults
ARG CDK_VERSION=2.12.0

# Setup
RUN echo "Creating project directory..." &&\
    mkdir /proj
WORKDIR /proj
RUN echo "Updating and installing required packages..." &&\
    apk -U --no-cache add \
    bash \
    git \
    curl \
    nodejs \
    npm &&\
    echo "Cleaning up APK cache..." &&\
    rm -rf /var/cache/apk/*

# Install essential Python packages
RUN echo "Installing essential Python packages..." &&\
    pip install beautifulsoup4 requests

# Query PyPI registry for all installable CDK modules
COPY list-cdk-packages.py .
RUN echo "Querying PyPI registry for CDK modules..." &&\
    ./list-cdk-packages.py ${CDK_VERSION} > cdk-requirements.txt &&\
    echo "Installing CDK modules from requirements file..." &&\
    pip install -r cdk-requirements.txt

# AWS CDK, AWS SDK
RUN echo "Installing AWS CDK and AWS SDK..." &&\
    npm i -g aws-cdk@${CDK_VERSION} aws-sdk

# Install additional Python packages
# (this is positioned here to take advantage of layer caching)
RUN echo "Installing additional Python packages..." &&\
    pip install Jinja2 stringcase boto3

# Configure Python bytecode behavior
RUN echo "Configuring Python bytecode behavior..." &&\
    export PYTHONDONTWRITEBYTECODE=true &&\
    export PYTHONPYCACHEPREFIX=/tmp/__pycache__

# Set default run command
CMD ["/bin/bash"]
