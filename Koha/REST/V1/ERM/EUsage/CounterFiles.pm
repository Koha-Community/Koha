package Koha::REST::V1::ERM::EUsage::CounterFiles;

# Copyright 2023 PTFS Europe

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::ERM::EUsage::CounterFiles;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $counter_files_set = Koha::ERM::EUsage::CounterFiles->new;
        my $counter_files     = $c->objects->search($counter_files_set);
        return $c->render( status => 200, openapi => $counter_files );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EUsage::CounterFile object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $counter_file = Koha::ERM::EUsage::CounterFiles->find( $c->param('erm_counter_files_id') );

        if ( !$counter_file ) {
            return $c->render(
                status  => 404,
                openapi => { error => "Counter file not found" }
            );
        }

        $c->render_file(
            'data'     => $counter_file->file_content,
            'filename' => $counter_file->filename . '.csv'
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $counter_file = Koha::ERM::EUsage::CounterFiles->find( $c->param('erm_counter_files_id') );

    unless ($counter_file) {
        return $c->render(
            status  => 404,
            openapi => { error => "Counter file not found" }
        );
    }

    return try {
        $counter_file->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
