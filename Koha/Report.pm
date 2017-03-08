package Koha::Report;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;

use Koha::Database;
use JSON;
use Koha::Reports;

use base qw(Koha::Object);

=head1 NAME

Koha::Report - Koha Report Object class

=head1 API

=head2 Class Methods

=cut

=head3 get_search_info

Return search info

=cut

sub get_search_info {
    my $self = shift;
    my $sub_mana_info = { 'query' => shift };
    return $sub_mana_info;
}

=head3 get_sharable_info

Return properties that can be shared.

=cut

sub get_sharable_info {
    my $self             = shift;
    my $shared_report_id = shift;
    my $report           = Koha::Reports->find($shared_report_id);
    my $sub_mana_info    = {
        'savedsql'     => $report->savedsql,
        'report_name'  => $report->report_name,
        'notes'        => $report->notes,
        'report_group' => $report->report_group,
        'type'         => $report->type,
    };
    return $sub_mana_info;
}

=head3 new_from_mana

Clear a Mana report to be imported in Koha?

=cut

sub new_from_mana {
    my $self = shift;
    my $data = shift;

    $data->{mana_id} = $data->{id};

    delete $data->{exportemail};
    delete $data->{kohaversion};
    delete $data->{creationdate};
    delete $data->{lastimport};
    delete $data->{id};
    delete $data->{nbofusers};
    delete $data->{language};

    Koha::Report->new($data)->store;
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'SavedSql';
}

1;
