package Koha::REST::V1::ArticleRequest;

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

use Mojo::Base 'Mojolicious::Controller';

use C4::Auth qw( haspermission );
use C4::Biblio;
use C4::Reserves;

use Koha::Patrons;
use Koha::ArticleRequest;
use Koha::ArticleRequests;
use Koha::DateUtils;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $params = $c->req->query_params->to_hash;
    my @valid_params = Koha::ArticleRequests->_resultset->result_source->columns;
    foreach my $key (keys %$params) {
        delete $params->{$key} unless grep { $key eq $_ } @valid_params;
    }
    unless ($params->{'status'}) {
        $params->{'-or'} = [
            { status => Koha::ArticleRequest::Status::Pending },
            { status => Koha::ArticleRequest::Status::Processing }
        ];
    }
    my $requests = Koha::ArticleRequests->search($params)->TO_JSON;

    # Hide non-public notes if user has no staff access
    my $user = $c->stash('koha.user');
    unless ($user && haspermission($user->userid, {catalogue => 1})) {
        foreach my $request (@{$requests}) {
            $request->{'notes'} = undef;
        }
    }

    return $c->render(status => 200, openapi => { count => 0 + @$requests, records => $requests });
}

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;

    my $borrowernumber = $body->{borrowernumber};
    my $biblionumber = $body->{biblionumber};
    my $itemnumber = $body->{itemnumber};
    my $branchcode = $body->{branchcode};
    my $title = $body->{title};
    my $author = $body->{author};
    my $volume = $body->{volume};
    my $issue = $body->{issue};
    my $date = $body->{date};
    my $pages = $body->{pages};
    my $chapters = $body->{chapters};
    my $patron_notes = $body->{patron_notes};
    my $borrower = Koha::Patrons->find($borrowernumber);
    unless ($borrower) {
        return $c->render( status  => 404,
                           openapi => {error => "Borrower not found"} );
    }

    if (my $problem = _opac_patron_restrictions($c, $borrower)) {
        return $c->render( status => 403, openapi => {
            error => "Request cannot be placed. Reason: $problem"} );
    }

    unless ($biblionumber or $itemnumber) {
        return $c->render( status => 400, openapi => {
            error => "At least one of biblionumber, itemnumber should be given"
        } );
    }

    if ($itemnumber) {
        my $item_biblionumber = C4::Biblio::GetBiblionumberFromItemnumber($itemnumber);
        if ($biblionumber and $biblionumber != $item_biblionumber) {
            return $c->render( status => 400, openapi => {
                error => "Item $itemnumber doesn't belong to biblio $biblionumber"
            } );
        }
        $biblionumber ||= $item_biblionumber;
    }

    my $ar = Koha::ArticleRequest->new(
        {
            borrowernumber => $borrowernumber,
            biblionumber   => $biblionumber,
            branchcode     => $branchcode,
            itemnumber     => $itemnumber,
            title          => $title,
            author         => $author,
            volume         => $volume,
            issue          => $issue,
            date           => $date,
            pages          => $pages,
            chapters       => $chapters,
            patron_notes   => $patron_notes,
        }
    )->store();

    return $c->render( status => 201, openapi => $ar );
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $id = $c->validation->param('article_request_id');
    my $request = Koha::ArticleRequests->find($id);

    unless ($request && $request->status ne Koha::ArticleRequest::Status::Canceled) {
        return $c->render( status  => 404,
                           openapi => {error => "Request not found"} );
    }

    if (my $problem = _opac_patron_restrictions($c, $c->stash('koha.user'))) {
        return $c->render( status => 403, openapi => {
            error => "Request cannot be modified. Reason: $problem"} );
    }

    my $body = $c->req->json;
    $request->branchcode($body->{branchcode}) if ($body->{branchcode});
    $request->store();
    
    return $c->render( status => 200, openapi => $request );
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $user = $c->stash('koha.user');
    my $id = $c->validation->param('article_request_id');
    my $request = Koha::ArticleRequests->find($id);

    unless ($request && $request->status ne Koha::ArticleRequest::Status::Canceled) {
        return $c->render( status  => 404,
                           openapi => {error => "Request not found"} );
    }

    if (my $problem = _opac_patron_restrictions($c, $user)) {
        return $c->render( status => 403, openapi => {
            error => "Request cannot be cancelled. Reason: $problem"} );
    }

    if ($user
        && ($c->stash('is_owner_access') || $c->stash('is_guarantor_access'))
        && !_can_request_be_canceled_from_opac($request, $user->borrowernumber)
    ) {
        return $c->render( status  => 403, openapi =>
                          {error => "Request cannot be cancelled by patron."});
    }

    $request->cancel();

    return $c->render( status => 200, openapi => {} );
}

# Restrict operations via REST API if patron has some restrictions.
#
# The following reasons can be returned:
#
# 1. debarred
# 2. gonenoaddress
# 3. cardexpired
# 4. maximumholdsreached
# 5. (cardlost, but this is returned via different error message. See KD-2165)
#
sub _opac_patron_restrictions {
    my ($c, $patron) = @_;

    $patron = ref($patron) eq 'Koha::Patron'
                ? $patron
                : Koha::Patrons->find($patron);
    return 0 unless $patron;
    return 0 if (!$c->stash('is_owner_access')
                 && !$c->stash('is_guarantor_access'));
    my @problems = $patron->status_not_ok;
    foreach my $problem (@problems) {
        $problem = ref($problem);
        next if $problem =~ /Debt/;
        next if $problem =~ /Checkout/;
        $problem =~ s/Koha::Exceptions::(.*::)*//;
        return lc($problem);
    }
    return 0;
}

=head2 _can_request_be_canceled_from_opac

    $ok = _can_request_be_canceled_from_opac($request, $borrowernumber);

    returns 1 if request can be cancelled by user from OPAC.
    First check if request belongs to user, next checks if request is not completed

=cut

sub _can_request_be_canceled_from_opac {
    my ($request, $borrowernumber) = @_;

    return unless $request and $borrowernumber;
    
    return 0 unless $request->borrowernumber == $borrowernumber;
    return 0 if ( $request->status ne 'PENDING' );

    return 1;
}

1;
