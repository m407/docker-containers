#!/bin/bash

HOST_NAME=`cat /etc/hostname`;

if [ -z ${REGISTRATION_TOKEN+x} ]; then
    sed -i 's|^\(\s*host:\s\)\(.*\)|\1$HOST_NAME|' /srv/www/vhosts/gitlab-ce/config/gitlab.yml;
    systemctl restart gitlab-ce-unicorn.service;

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
        --url http://$HOST_NAME/ci \
        --executor docker \
        --description "openSUSE Docker CLI Runner" \
        --docker-image "m407/docker" \
        --docker-volumes /var/run/docker.sock:/var/run/docker.sock:rw \
        --docker-pull-policy always \
        --tag-list "docker";

    gitlab-ci-multi-runner register -n \
        --url http://$HOST_NAME/ci \
        --executor docker \
        --description "openSUSE Runner" \
        --docker-image "m407/opensuse" \
        --docker-pull-policy always \
        --tag-list "simple";
    systemctl enable gitlab-runner;
    systemctl start gitlab-runner;
fi
