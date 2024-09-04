#!/bin/bash

# Docker CDK Bash Env Setup
# Add to .profile or .bashrc Example:
#  . ~/pycdk/cdk-bash.sh

#AWS Example
# export REGISTRY='421327123456.dkr.REGISTRY.us-west-2.amazonaws.com'
print_header() {
    local text="$1"
    local length=$(( ${#text} + 2 ))

    # Print a line of dashes above and below the text
    printf '%*s\n' "$length" | tr ' ' '-'
    echo -e "$text"
    printf '%*s\n' "$length" | tr ' ' '-'
}

# GitHub Login
print_header "🐙 GitHub Login"

# Read the token from the file
token_file="$HOME/.github_pat_pycdk"
token=$(cat "$token_file")

result=$(docker login ghcr.io -u USERNAME --password-stdin <<< "$token" 2>&1)

if grep -q "denied: denied" <<< "$result"; then
    echo "❌ GitHub token expired or invalid. Please update $token_file with a valid token."
elif grep -q "another_error_message" <<< "$result"; then
    echo "❌ Another specific error message. Handle accordingly."
elif grep -q "Login Succeeded" <<< "$result"; then
    echo "✅ Login Succeeded"
else
    echo "❓ $result"
fi
echo    # Add a newline

# export REGISTRY='ghcr.io/cumulus-technology'
export REGISTRY='ghcr.io/cosgiant'

#Use this env var to control the CDK version. "latest" can be replaced with a version number.
export PYCDKVER=latest

alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws -e AWS_PROFILE=$AWS_PROFILE amazon/aws-cli:latest --profile $AWS_PROFILE' 
alias pycdk='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj -e AWS_PROFILE=$AWS_PROFILE -e PYTHONPATH=".python-local" $REGISTRY/pycdk:$PYCDKVER' 
alias cdk='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj -e AWS_PROFILE=$AWS_PROFILE -e PYTHONPATH=".python-local" $REGISTRY/pycdk:$PYCDKVER cdk --profile $AWS_PROFILE' 
alias cdkpip='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj -e AWS_PROFILE=$AWS_PROFILE -e PYTHONPATH=".python-local" $REGISTRY/pycdk:$PYCDKVER pip' 

# CDK Version
print_header "🚧 CDK Version"
echo "🐍 Attempt to set pycdk version based on project. If this fails, latest will be used."

if [ -f cdk_ver.sh ]; then
    source cdk_ver.sh
    echo "✅ cdk_ver.sh found and sourced successfully. 🚀"
else
    echo "❌ cdk_ver.sh not found. Please make sure the file exists in the current directory. 🚨"
fi

if [ "$PYCDKVER" == "latest" ]; then
    echo "🐍 Pycdk Version: ($PYCDKVER) 🚀"
else
    echo "🐍 Pycdk Version: $PYCDKVER"
fi
echo    # Add a newline