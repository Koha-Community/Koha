#!/usr/bin/perl
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.
#

use Modern::Perl;
use ExtUtils::MakeMaker::Config;

=head1 NAME

build-resources.PL - helper for the Koha packager and installer

=head1 SYNOPSIS

    perl build-resources.PL

=head1 DESCRIPTION

This helper script ensures that src JS and SCSS files are compiled for packaging.

=cut

my $install_command = "yarn install --frozen-lockfile";
system($install_command);

my $build_command = "yarn build:prod";
system($build_command);

1;
