#!/bin/bash

mkdir -p /opt/GIT
cd /opt/GIT

if [ ! -d development_environment ]
then
  git clone https://github.com/dogbonnahNB/development_environment.git development_environment
fi

cd development_environment
#git fetch
#git clean -fxd
#git reset --hard

#TAG=${TAG:-$(git tag | tail -n 1)}
#echo "Running with Tag: ${TAG}"
#git checkout ${TAG}

ansible-galaxy install -r requirements.yml

ansible-playbook -i hostfile -v site.yml  --flush-cache   --force-handlers 

exit
