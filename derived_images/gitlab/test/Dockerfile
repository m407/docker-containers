FROM m407/opensuse
MAINTAINER Andrey Kuvshinov <andrei@m407.ru>

RUN zypper --non-interactive ar -p 80 -f -c http://download.opensuse.org/repositories/Virtualization:/containers/openSUSE_Leap_42.2/ Virtualization:containers && \
    zypper --non-interactive --gpg-auto-import-keys in -l --no-recommends docker && \
    zypper --non-interactive clean -a;

