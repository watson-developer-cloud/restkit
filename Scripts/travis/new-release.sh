# Uses the semantic-release tool to automatically release a new version to Github
# Includes:
	# New git tag
	# Github release with release notes and an attached pre-built SDK
	# Updated CHANGELOG
	# Updated version number in source files

set -e

sudo easy_install pip >/dev/null
source ~/.nvm/nvm.sh
nvm install 10
sudo pip install bumpversion >/dev/null
npm install -g semantic-release@15.9.0 --silent
npm install -g @semantic-release/exec --silent
npm install -g @semantic-release/changelog --silent
npm install -g @semantic-release/git --silent
brew update >/dev/null

npx semantic-release --repository-url https://${GH_TOKEN}@github.com/watson-developer-cloud/restkit --debug
