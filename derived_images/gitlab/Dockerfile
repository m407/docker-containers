FROM m407/opensuse-systemd
MAINTAINER Andrey Kuvshinov <andrei@m407.ru>

ADD pgsql_config.sql pgsql_dump.sql pg.config.sh database.yml gitlab.yml nginx.conf setup.sh /tmp/
RUN zypper --non-interactive ar -c -p 40 -f http://mirror.yandex.ru/opensuse/repositories/devel:/tools:/scm/openSUSE_Leap_42.2/ devel:tools:scm && \
    zypper --non-interactive ar -c -p 40 -f http://mirror.yandex.ru/opensuse/repositories/devel:/languages:/nodejs/openSUSE_Leap_42.2/ devel:languages:nodejs && \
    zypper --non-interactive ar -c -p 50 -f http://download.opensuse.org/repositories/home:/darix:/apps/openSUSE_Leap_42.2/ home:darix:apps && \
    zypper --non-interactive --gpg-auto-import-keys ref && \
    zypper --non-interactive --gpg-auto-import-keys in gitlab-ce gitlab-ci-multi-runner zopfli nginx redis postgresql postgresql-server postgresql-contrib sendmail && \
    zypper --non-interactive --gpg-auto-import-keys in bash-completion systemd-bash-completion vim vim-data mc curl && \
    zypper --non-interactive clean -a;
RUN systemctl enable nginx postgresql redis@default gitlab-ce.target gitlab-workhorse gitlab-ce-sidekiq gitlab-ce-unicorn && \
    chmod +x /tmp/*.sh && \
    /tmp/pg.config.sh && \
    rm /tmp/pg.config.sh && \
    mv /tmp/setup.sh /opt/gitlab-setup.sh && \
    chmod +x /opt/gitlab-setup.sh && \
    mv /etc/gitlab-runner/config.toml /etc/gitlab-runner/config.toml.sample && \
    mv /tmp/nginx.conf /etc/nginx/ && \
    cp /etc/redis/default.conf.example /etc/redis/default.conf && \
    chown root:redis /etc/redis/default.conf && \
    pushd /srv/www/vhosts/gitlab-ce/config/ && \
        mv /tmp/database.yml . && \
        mv /tmp/gitlab.yml . && \
        cp secrets.yml.example secrets.yml && \
        chmod g+w secrets.yml && \
        chown -R root.gitlab . && \
        pushd .. && \
            mkdir /etc/nginx/vhosts.d && \
            cp lib/support/nginx/gitlab /etc/nginx/vhosts.d/gitlab.conf && \
        popd && \
    popd && \
    sed -i 's|^\(\s*\)\(socket.*\)|\1# \2|' /usr/share/gitlab/shell/config.yml && \
    sed -i 's|^\(\s*\)#\s\(host:.*\)|\1\2|' /usr/share/gitlab/shell/config.yml && \
    sed -i 's|^\(\s*\)#\s\(port:.*\)|\1\2|' /usr/share/gitlab/shell/config.yml && \
    chmod g+w /usr/share/gitlab/shell && \
    chown root:gitlab /usr/share/gitlab/shell;

EXPOSE 80
