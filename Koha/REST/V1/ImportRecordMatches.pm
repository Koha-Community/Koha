package Koha::REST::V1::ImportRecordMatches;

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

use Koha::Import::Record::Matches;

use Try::Tiny;

=head1 API

=head2 Methods

=cut

=head3 unset_chosen

Method that handles unselecting all chosen matches for an import record

DELETE /api/v1/import_batches/{import_batch_id}/records/{import_record_id}/matches/chosen

=cut

sub unset_chosen {
    my $c = shift->openapi->valid_input or return;

    my $matches = Koha::Import::Record::Matches->search({
        import_record_id => $c->param('import_record_id'),
    });
    unless ($matches) {
        return $c->render(
            status  => 404,
            openapi => { error => "No matches not found" }
        );
    }
    return try {
        $matches->update({ chosen => 0 });
        return $c->render( status => 204, openapi => $matches );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 set_chosen

Method that handles modifying if a Koha::Import::Record::Match object has been chosen for overlay

PUT /api/v1/import_batches/{import_batch_id}/records/{import_record_id}/matches/chosen

Body should contain the condidate_match_id to chose

=cut

sub set_chosen {
    my $c = shift->openapi->valid_input or return;

    my $import_record_id = $c->param('import_record_id');
    my $body = $c->req->json;
    my $candidate_match_id = $body->{'candidate_match_id'};

    my $match = Koha::Import::Record::Matches->find({
        import_record_id => $import_record_id,
        candidate_match_id => $candidate_match_id
    });

    unless ($match) {
        return $c->render(
            status  => 404,
            openapi => { error => "Match not found" }
        );
    }

    return try {
        my $matches = Koha::Import::Record::Matches->search({
            import_record_id => $import_record_id,
            chosen => 1
        });
        $matches->update({ chosen => 0}) if $matches;
        $match->set_from_api({ chosen => JSON::true });
        $match->store;
        return $c->render( status => 200, openapi => $match );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
