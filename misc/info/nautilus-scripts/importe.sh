#!/bin/sh
#
# This script opens a gnome-terminal in the directory you select.
#
# Distributed under the terms of GNU GPL version 2 or later
#
# Copyright (C) Keith Conger <acid@twcny.rr.com>
#
# Install in your ~/Nautilus/scripts directory.
# You need to be running Nautilus 1.0.3+ to use scripts.

export KOHA_CONF="/etc/koha/koha.conf"
export PERL5LIB='/usr/local/koha/intranet/modules'
/home/responsables/valerie/.bdp/import.pl -file "$1"


