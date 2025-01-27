package Koha::Authority::MergeRequests;

# Copyright Rijksmuseum 2017
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
use MARC::File::XML;

use C4::Context;
use Koha::Authority::MergeRequest;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use parent qw(Koha::Objects);

=head1 NAME

Koha::Authority::MergeRequests - Koha::Objects class for need_merge_authorities

=head1 SYNOPSIS

use Koha::Authority::MergeRequests;

=head1 DESCRIPTION

Description

=head1 METHODS

=head2 CLASS METHODS

=head3 cron_cleanup

    Koha::Authority::MergeRequests->cron_cleanup({
        reset_hours => 24, remove_days => 90,
    });

    Removes all entries with status "done" older than remove_days.
    Set all entries with status "in progress" back to 0 when the timestamp
    is older than reset_hours.
    Defaults: reset_hours = 1, remove_days = 30.

=cut

sub cron_cleanup {
    my ( $class_or_self, $params ) = @_;
    my $reset_hours = $params->{reset_hours} || 1;
    my $remove_days = $params->{remove_days} || 30;
    my $parser      = Koha::Database->new->schema->storage->datetime_parser;

    my $dt = dt_from_string;
    $dt->subtract( hours => $reset_hours );
    $class_or_self->search(
        {
            done      => 2,
            timestamp => { '<' => $parser->format_datetime($dt) },
        }
    )->update( { done => 0 } );

    $dt = dt_from_string;
    $dt->subtract( days => $remove_days );
    $class_or_self->search(
        {
            done      => 1,
            timestamp => { '<' => $parser->format_datetime($dt) },
        }
    )->delete;
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'NeedMergeAuthority';
}

=head3 object_class

Returns name of corresponding Koha object class

=cut

sub object_class {
    return 'Koha::Authority::MergeRequest';
}

=head1 AUTHOR

Marcel de Rooy (Rijksmuseum)

Koha Development Team

=cut

1;
