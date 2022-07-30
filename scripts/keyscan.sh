set -eu

ssh-keyscan -H $1 >> ~/.ssh/known_hosts