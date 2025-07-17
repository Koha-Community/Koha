package Koha::HoldGroup;

# Copyright 2020 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use base qw(Koha::Object);

=head1 NAME

Koha::HoldGroup - Koha Hold Group object class

=head1 API

=head2 Class Methods

=cut

=head3 to_api

    my $json = $hold_group->to_api;

Overloaded method that returns a JSON representation of the Koha::HoldGroup object,
suitable for API output. The related Koha::Holds objects are merged as expected
on the API.

=cut

sub to_api {
    my ( $self, $args ) = @_;

    my $json_hold_group = $self->SUPER::to_api($args);
    return unless $json_hold_group;

    $args = defined $args ? {%$args} : {};
    delete $args->{embed};

    my $holds = $self->holds;

    Koha::Exceptions::RelatedObjectNotFound->throw( accessor => 'holds', class => 'Koha::HoldGroup' )
        unless $holds;

    my @json_holds;
    for my $hold ($holds) {
        push @json_holds, $hold->to_api($args);
    }

    return { %$json_hold_group, holds => @json_holds };
}

=head3 holds

    $holds = $hold_group->holds

Return all holds associated with this group

=cut

sub holds {
    my ($self) = @_;

    my $holds_rs = $self->_result->reserves->search;
    return Koha::Holds->_new_from_dbic($holds_rs);
}

=head3 target_hold_id

    $holds = $hold_group->target_hold_id

Return the target_hold_id

=cut

sub target_hold_id {
    my ($self) = @_;

    return unless $self->_result->hold_group_target_hold;

    return $self->_result->hold_group_target_hold->reserve_id;
}

=head3 skip_non_target_holds_query

    $where{'me.hold_group_id'} = Koha::HoldGroup::skip_non_target_holds_query('dbix')

Static method, returns the query part be added if DisplayAddHoldGroups
Accepts a $query_type of 'dbix' or 'sql' and returns the respective query
The query is designed to skip non target holds that are part of a hold group which already has a hold target

=cut

sub skip_non_target_holds_query {
    my ($query_type) = @_;

    return unless C4::Context->preference('DisplayAddHoldGroups');

    my $query_types = {
        'dbix' => [
            -or => { '=' => undef },
            [
                -and => { '!=' => undef },
                {
                    -not_in => \
                        'SELECT hold_group_id FROM hold_group_target_holds WHERE reserve_id IS NOT NULL AND hold_group_id IS NOT NULL'
                }
            ]
        ],
        'sql' =>
            'AND (hold_group_id IS NULL OR hold_group_id IS NOT NULL AND reserves.hold_group_id NOT IN (SELECT hold_group_id FROM hold_group_target_holds WHERE reserve_id IS NOT NULL AND hold_group_id IS NOT NULL))'
    };

    return unless $query_type && exists $query_types->{$query_type};

    return $query_types->{$query_type};
}

=head3 _type

=cut

sub _type {
    return 'HoldGroup';
}

=head1 AUTHORS

Josef Moravec <josef.moravec@gmail.com>

=cut

1;
