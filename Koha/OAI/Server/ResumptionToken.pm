# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
# Copyright The National Library of Finland, University of Helsinki 2016-2021
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
# - cursor
# - deleted
# - deleted count (not used anymore, but preserved for back-compatibility)
# - nextId

sub new {
    my ( $class, %args ) = @_;

    my $self = $class->SUPER::new(%args);

    my ( $metadata_prefix, $cursor, $from, $until, $set, $deleted, $next_id );
    if ( $args{resumptionToken} ) {

        # Note: undef in place of deleted record count for back-compatibility
        ( $metadata_prefix, $cursor, $from, $until, $set, $deleted, undef, $next_id ) =
            split( '/', $args{resumptionToken} );
        $next_id = 0 unless $next_id;
    } else {
        $metadata_prefix = $args{metadataPrefix};
        $from            = $args{from}  || '';
        $until           = $args{until} || '';

        # Add times to the arguments, when necessary, so they correctly match against the DB timestamps
        $from  .= 'T00:00:00Z' if length($from) == 10;
        $until .= 'T23:59:59Z' if length($until) == 10;
        $cursor  = $args{cursor} // 0;
        $set     = $args{set} || '';
        $deleted = defined $args{deleted} ? $args{deleted} : 1;
        $next_id = $args{next_id} // 0;
    }

    # metadata_prefix can be undef (e.g. listSets)
    $metadata_prefix //= '';

    $self->{metadata_prefix} = $metadata_prefix;
    $self->{cursor}          = $cursor;
    $self->{from}            = $from;
    $self->{until}           = $until;
    $self->{set}             = $set;
    $self->{from_arg}        = _strip_UTC_designators($from);
    $self->{until_arg}       = _strip_UTC_designators($until);
    $self->{deleted}         = $deleted;
    $self->{next_id}         = $next_id;

    # Note: put zero where deleted record count used to be for back-compatibility
    $self->resumptionToken( join( '/', $metadata_prefix, $cursor, $from, $until, $set, $deleted, 0, $next_id ) );
    $self->cursor($cursor);

    return $self;
}

sub _strip_UTC_designators {
    my ($timestamp) = @_;
    $timestamp =~ s/T/ /g;
    $timestamp =~ s/Z//g;
    return $timestamp;
}

1;
