package Koha;

# Copyright 2015 BibLibre
# Copyright 2015 Theke Solutions
#
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

use Modern::Perl;

use vars qw{ $VERSION };

#the kohaversion is divided in 4 parts :
# - #1 : the major number. 3 atm
# - #2 : the functional release. 00 atm
# - #3 : the subnumber, moves only on a public release
# - #4 : the developer version. The 4th number is the database subversion.
#        used by developers when the database changes. updatedatabase take care of the changes itself
#        and is automatically called by Auth.pm when needed.
$VERSION = "22.12.00.018";

sub version {
    return $VERSION;
}

1;

=head1 NAME

Koha - The world's first free and open source library system.

=head1 SYNOPSIS

At the moment this module only provides a version subroutine.

=head1 METHODS

=head2 version

    use Koha;

    my $version = Koha::version;

=head1 SEE ALSO

C4::Context

kohaversion.pl

=head1 AUTHORS

Jonathan Druart <jonathan.druart@biblibre.com>

Tomas Cohen Arazi <tomascohen@gmail.com>

=cut
