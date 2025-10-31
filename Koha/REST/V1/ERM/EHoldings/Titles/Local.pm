package Koha::REST::V1::ERM::EHoldings::Titles::Local;

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

use Koha::ERM::EHoldings::Titles;
use Koha::BackgroundJob::CreateEHoldingsFromBiblios;
use Koha::BackgroundJob::ImportKBARTFile;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );
use MIME::Base64 qw( decode_base64 encode_base64 );
use POSIX        qw( floor );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift or return;

    return try {
        my $titles_set = Koha::ERM::EHoldings::Titles->new;
        my $titles = $c->objects->search( $titles_set );
        return $c->render( status => 200, openapi => $titles );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EHoldings::Title object

=cut

sub get {
    my $c = shift or return;

    return try {
        my $title = $c->objects->find( Koha::ERM::EHoldings::Titles->search, $c->param('title_id') );

        return $c->render_resource_not_found("eHolding title")
            unless $title;

        return $c->render(
            status  => 200,
            openapi => $title,
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::ERM::EHoldings::Title object

=cut

sub add {
    my $c = shift or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $resources            = delete $body->{resources}            // [];
                my $create_linked_biblio = delete $body->{create_linked_biblio} // 0;

                my $title = Koha::ERM::EHoldings::Title->new_from_api($body)
                    ->store( { create_linked_biblio => $create_linked_biblio } );

                $title->resources($resources);

                $c->res->headers->location($c->req->url->to_string . '/' . $title->title_id);
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($title),
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::ERM::EHoldings::Title->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::ERM::EHoldings::Title object

=cut

sub update {
    my $c = shift or return;

    my $title = Koha::ERM::EHoldings::Titles->find( $c->param('title_id') );

    return $c->render_resource_not_found("eHolding title")
        unless $title;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $resources            = delete $body->{resources}            // [];
                my $create_linked_biblio = delete $body->{create_linked_biblio} // 0;

                $title->set_from_api($body)->store( { create_linked_biblio => $create_linked_biblio } );

                $title->resources($resources);

                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($title),
                );
            }
        );
    }
    catch {
        my $to_api_mapping = Koha::ERM::EHoldings::Title->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
};

=head3 delete

=cut

sub delete {
    my $c = shift or return;

    my $title = Koha::ERM::EHoldings::Titles->find( $c->param('title_id') );

    return $c->render_resource_not_found("eHolding title")
        unless $title;

    return try {
        $title->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 import_from_list

=cut

sub import_from_list {
    my $c = shift or return;

    my $body       = $c->req->json;
    my $list_id    = $body->{list_id};
    my $package_id = $body->{package_id};

    my $list   = Koha::Virtualshelves->find($list_id);
    my $patron = $c->stash('koha.user');

    unless ( $list && $list->owner == $c->stash('koha.user')->borrowernumber ) {
        return $c->render_resource_not_found("List");
    }


    return try {

        my @biblionumbers = $list->get_contents->get_column('biblionumber');
        my $params = { record_ids => \@biblionumbers, package_id => $package_id };
        my $job_id = Koha::BackgroundJob::CreateEHoldingsFromBiblios->new->enqueue( $params);

        return $c->render(
            status  => 201,
            openapi => { job_id => $job_id }
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}


=head3 import_from_kbart_file

=cut

sub import_from_kbart_file {
    my $c = shift or return;

    my $import_data          = $c->req->json;
    my $file                 = $import_data->{file};
    my $package_id           = $import_data->{package_id};
    my $create_linked_biblio = $import_data->{create_linked_biblio};

    return try {
        my @job_ids;
        my @invalid_columns;
        my $max_allowed_packet = C4::Context->dbh->selectrow_array(q{SELECT @@max_allowed_packet});

        # Check if file is in TSV or CSV format and send an error back if not
        if ( $file->{filename} !~ /\.csv$/ && $file->{filename} !~ /\.tsv$/ ) {
            return $c->render(
                status  => 201,
                openapi => { warnings => { invalid_filetype => 1 } }
            );
        }

        my ( $column_headers, $rows ) = Koha::BackgroundJob::ImportKBARTFile::read_file($file);

        # Check that the column headers in the file match the standardised KBART phase II columns
        # If not, return a warning
        my $warnings      = {};
        my @valid_headers = Koha::BackgroundJob::ImportKBARTFile::get_valid_headers();
        foreach my $header (@$column_headers) {
            if ( !grep { $_ eq $header } @valid_headers ) {
                $header = 'Empty column' if $header eq '';
                push @invalid_columns, $header;
            }
        }
        $warnings->{invalid_columns} = \@invalid_columns if scalar(@invalid_columns) > 0;

        my $params = {
            column_headers       => $column_headers,
            invalid_columns      => \@invalid_columns,
            rows                 => $rows,
            package_id           => $package_id,
            file_name            => $file->{filename},
            create_linked_biblio => $create_linked_biblio
        };
        my $outcome = Koha::BackgroundJob::ImportKBARTFile::is_file_too_large( $params, $max_allowed_packet );

        # If the file is too large, we can break the file into smaller chunks and enqueue one job per chunk
        if ( $outcome->{file_too_large} ) {
            my $max_number_of_rows = Koha::BackgroundJob::ImportKBARTFile::calculate_chunked_params_size(
                $outcome->{params_size}, $max_allowed_packet,
                scalar(@$rows)
            );

            my @chunked_files;
            push @chunked_files, [ splice @$rows, 0, $max_number_of_rows ] while @$rows;
            foreach my $chunk (@chunked_files) {
                $params->{rows} = $chunk;
                my $chunked_job_id = Koha::BackgroundJob::ImportKBARTFile->new->enqueue($params);
                push @job_ids, $chunked_job_id;
            }
        } else {
            my $job_id = Koha::BackgroundJob::ImportKBARTFile->new->enqueue($params);
            push @job_ids, $job_id;
        }

        return $c->render(
            status  => 201,
            openapi => { job_ids => \@job_ids, warnings => $warnings }
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;