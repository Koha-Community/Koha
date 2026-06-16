package Koha::BackgroundJob::PatronImport;

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
use Try::Tiny qw( catch try );

use Koha::List::Patron qw( AddPatronList AddPatronsToList );
use Koha::Patrons::Import;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::PatronImport - Import patrons from a CSV file as a background job

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: patron_import

=cut

sub job_type { return 'patron_import' }

=head3 process

Process the job.

=cut

sub process {
    my ( $self, $args ) = @_;

    return if $self->status eq 'cancelled';

    $self->start;

    my $file_content = $args->{file_content};
    open my $fh, '<', \$file_content or die "Cannot create in-memory file handle: $!";

    my $result = try {
        Koha::Patrons::Import->new->import_patrons(
            {
                file                            => $fh,
                defaults                        => $args->{defaults},
                matchpoint                      => $args->{matchpoint},
                overwrite_cardnumber            => $args->{overwrite_cardnumber},
                overwrite_passwords             => $args->{overwrite_passwords},
                preserve_extended_attributes    => $args->{preserve_extended_attributes},
                preserve_fields                 => $args->{preserve_fields},
                update_dateexpiry               => $args->{update_dateexpiry},
                update_dateexpiry_from_today    => $args->{update_dateexpiry_from_today},
                update_dateexpiry_from_existing => $args->{update_dateexpiry_from_existing},
                send_welcome                    => $args->{send_welcome},
                step_callback                   => sub { $self->step },
            }
        );
    } catch {
        $self->status('failed')->store;
        return;
    };

    my $data = $self->decoded_data;
    delete $data->{file_content};    # No longer needed; free DB space

    if ($result) {
        if ( $args->{createpatronlist} && @{ $result->{imported_borrowers} // [] } ) {
            my $list = AddPatronList( { name => $args->{patronlistname} } );
            AddPatronsToList( { list => $list, borrowernumbers => $result->{imported_borrowers} } );
            $data->{patron_list_name} = $args->{patronlistname};
        }

        $data->{feedback}      = $result->{feedback};
        $data->{errors}        = $result->{errors};
        $data->{imported}      = $result->{imported};
        $data->{overwritten}   = $result->{overwritten};
        $data->{already_in_db} = $result->{already_in_db};
        $data->{invalid}       = $result->{invalid};
        $data->{total} = $result->{imported} + $result->{overwritten} + $result->{already_in_db} + $result->{invalid};
    }

    $self->finish($data);
}

=head3 enqueue

Enqueue the new job.

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    return unless $args->{file_content};

    my $line_count = scalar grep { /\S/ } split /\n/, $args->{file_content};

    $self->SUPER::enqueue(
        {
            job_size  => $line_count > 1 ? $line_count - 1 : 1,
            job_args  => $args,
            job_queue => 'long_tasks',
        }
    );
}

1;
