# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
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

package Koha::OAI::Server::DeletedRecord;

use Modern::Perl;
use HTTP::OAI;
use HTTP::OAI::Metadata::OAI_DC;

use base ("HTTP::OAI::Record");

sub new {
    my ($class, $timestamp, $setSpecs, %args) = @_;

    my $self = $class->SUPER::new(%args);

    $timestamp =~ s/ /T/, $timestamp .= 'Z';
    $self->header( new HTTP::OAI::Header(
        status      => 'deleted',
        identifier  => $args{identifier},
        datestamp   => $timestamp,
    ) );

    foreach my $setSpec (@$setSpecs) {
        $self->header->setSpec($setSpec);
    }

    return $self;
}

1;
