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


package Koha::OAI::Server::ResumptionToken;

use Modern::Perl;
use HTTP::OAI;

use base ("HTTP::OAI::ResumptionToken");


# Extends HTTP::OAI::ResumptionToken
# A token is identified by:
# - metadataPrefix
# - from
# - until
# - offset


sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new(%args);

    my ($metadata_prefix, $offset, $from, $until, $set);
    if ( $args{ resumptionToken } ) {
        ($metadata_prefix, $offset, $from, $until, $set)
            = split( '/', $args{resumptionToken} );
    }
    else {
        $metadata_prefix = $args{ metadataPrefix };
        $from = $args{ from } || '1970-01-01';
        $until = $args{ until };
        unless ( $until) {
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime( time );
            $until = sprintf( "%.4d-%.2d-%.2d", $year+1900, $mon+1,$mday );
        }
        #Add times to the arguments, when necessary, so they correctly match against the DB timestamps
        $from .= 'T00:00:00Z' if length($from) == 10;
        $until .= 'T23:59:59Z' if length($until) == 10;
        $offset = $args{ offset } || 0;
        $set = $args{set} || '';
    }

    $self->{ metadata_prefix } = $metadata_prefix;
    $self->{ offset          } = $offset;
    $self->{ from            } = $from;
    $self->{ until           } = $until;
    $self->{ set             } = $set;
    $self->{ from_arg        } = _strip_UTC_designators($from);
    $self->{ until_arg       } = _strip_UTC_designators($until);

    $self->resumptionToken(
        join( '/', $metadata_prefix, $offset, $from, $until, $set ) );
    $self->cursor( $offset );

    return $self;
}

sub _strip_UTC_designators {
    my ( $timestamp ) = @_;
    $timestamp =~ s/T/ /g;
    $timestamp =~ s/Z//g;
    return $timestamp;
}

1;
