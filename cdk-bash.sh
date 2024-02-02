# Docker CDK Bash Env Setup
# Add to .profile or .bashrc Example:
#  . ~/pycdk/cdk-bash.sh

#AWS Example
# export REGISTRY='421327123456.dkr.REGISTRY.us-west-2.amazonaws.com'

#Github Example
echo "🐙 Github Login"
# Read the token from the file
# Define the token file
token_file="$HOME/.github_pat_pycdk"

# Read the token from the file
token=$(cat "$token_file")

# Attempt to login to ghcr.io using the token
if docker login ghcr.io -u USERNAME --password-stdin <<< "$token" 2>&1 | grep -q "denied: denied"; then
    echo "❌ GitHub token expired or invalid. Please update $token_file with a valid token."
else
    echo "✅ Login Succeeded"
fi

export REGISTRY='ghcr.io/cumulus-technology'

#Use this env var to control the CDK version. "latest" can be replaced with a version number.
export PYCDKVER=latest

alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli:2.13.3' 
alias pycdk='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj -e PYTHONPATH=".python-local" $REGISTRY/pycdk:$PYCDKVER' 
alias cdk='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj -e PYTHONPATH=".python-local" $REGISTRY/pycdk:$PYCDKVER cdk' 
alias cdkpip='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/proj -e PYTHONPATH=".python-local" $REGISTRY/pycdk:$PYCDKVER pip' 

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

