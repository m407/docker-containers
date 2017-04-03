#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2013 SUSE LLC
#               :
# AUTHOR        : Robert Schweikert <rjschwei@suse.com>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# SuSEconfig
#--------------------------------------
suseConfig

#======================================
# Import repositories' keys
#--------------------------------------
suseImportBuildKey

#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

#======================================
# Disable recommends
#--------------------------------------
sed -i 's/.*installRecommends.*/installRecommends = no/g' /etc/zypp/zypper.conf

#======================================
# Clean systemd service files
#--------------------------------------
(cd /usr/lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
rm -f /usr/lib/systemd/system/multi-user.target.wants/*;
rm -f /etc/systemd/system/*.wants/*;
rm -f /usr/lib/systemd/system/local-fs.target.wants/*;
rm -f /usr/lib/systemd/system/sockets.target.wants/*udev*;
rm -f /usr/lib/systemd/system/sockets.target.wants/*initctl*;
rm -f /usr/lib/systemd/system/basic.target.wants/*;
rm -f /usr/lib/systemd/system/anaconda.target.wants/*;

#======================================
# Remove locale files
#--------------------------------------
(cd /usr/share/locale && find -name '*.mo' | xargs rm)


exit 0
