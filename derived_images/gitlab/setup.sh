#!/bin/bash

if [ -z ${REGISTRATION_TOKEN+x} ]; then
    pushd /srv/www/vhosts/gitlab-ce
        chown -R root:gitlab .
        chmod -R g+rw .
        sudo -u gitlab -H rake setup RAILS_ENV=production force=yes
        sudo -u gitlab -H rake assets:precompile RAILS_ENV=production
        sudo -u gitlab -H rake webpack:compile RAILS_ENV=production
        chown -R root:gitlab .
        chmod -R g+rw .
    popd
else
    gitlab-ci-multi-runner register -n \
        --url http://localhost/ci \
        --executor docker \
        --description "openSUSEDocker-in-Dcoker Runner" \
        --docker-image "m407/docker" \
        --docker-volumes /var/run/docker.sock:/var/run/docker.sock:rw \
        --docker-pull-policy always
        --tag-list "docker"

    gitlab-ci-multi-runner register -n \
        --url http://localhost/ci \
        --executor docker \
        --description "openSUSE Docker Runner" \
        --docker-image "m407/opensuse" \
        --docker-pull-policy always
        --tag-list "simple"
fi
