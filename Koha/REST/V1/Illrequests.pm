package Koha::REST::V1::Illrequests;

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

use C4::Context;
use Koha::Illrequests;
use Koha::Illrequestattributes;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Libraries;
use Koha::DateUtils qw( format_sqldatetime );

=head1 NAME

Koha::REST::V1::Illrequests

=head2 Operations

=head3 list

Return a list of ILL requests, after applying filters.

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $args = $c->req->params->to_hash // {};
    my $output = [];
    my @format_dates = ( 'placed', 'updated', 'completed' );

    # Create a hash where all keys are embedded values
    # Enables easy checking
    my %embed;
    my $args_arr = (ref $args->{embed} eq 'ARRAY') ? $args->{embed} : [ $args->{embed} ];
    if (defined $args->{embed}) {
        %embed = map { $_ => 1 }  @{$args_arr};
        delete $args->{embed};
    }

    # Get the pipe-separated string of hidden ILL statuses
    my $hidden_statuses_string = C4::Context->preference('ILLHiddenRequestStatuses') // q{};
    # Turn into arrayref
    my $hidden_statuses = [ split /\|/, $hidden_statuses_string ];

    # Get all requests
    # If necessary, only get those from a specified patron
    my @requests = Koha::Illrequests->search({
        $hidden_statuses
        ? (
            -and => {
                status => { 'not in' => $hidden_statuses },
                status_alias => [ -or =>
                    { 'not in' => $hidden_statuses },
                    { '=' => undef }
                ]
            }
        )
        : (),
        $args->{borrowernumber}
        ? ( borrowernumber => $args->{borrowernumber} )
        : ()
    })->as_list;

    my $fetch_backends = {};
    foreach my $request (@requests) {
        $fetch_backends->{ $request->backend } ||=
          Koha::Illrequest->new->load_backend( $request->backend );
    }

    # Pre-load the backend object to avoid useless backend lookup/loads
    @requests = map { $_->_backend( $fetch_backends->{ $_->backend } ); $_ } @requests;

    # Identify patrons & branches that
    # we're going to need and get them
    my $to_fetch = {
        patrons      => {},
        branches     => {},
        capabilities => {}
    };
    foreach my $req (@requests) {
        $to_fetch->{patrons}->{$req->borrowernumber} = 1 if $embed{patron};
        $to_fetch->{branches}->{$req->branchcode} = 1 if $embed{library};
        $to_fetch->{capabilities}->{$req->backend} = 1 if $embed{capabilities};
    }

    # Fetch the patrons we need
    my $patron_arr = [];
    if ($embed{patron}) {
        my @patron_ids = keys %{$to_fetch->{patrons}};
        if (scalar @patron_ids > 0) {
            my $where = {
                borrowernumber => { -in => \@patron_ids }
            };
            $patron_arr = Koha::Patrons->search($where)->unblessed;
        }
    }

    # Fetch the branches we need
    my $branch_arr = [];
    if ($embed{library}) {
        my @branchcodes = keys %{$to_fetch->{branches}};
        if (scalar @branchcodes > 0) {
            my $where = {
                branchcode => { -in => \@branchcodes }
            };
            $branch_arr = Koha::Libraries->search($where)->unblessed;
        }
    }

    # Fetch the capabilities we need
    if ($embed{capabilities}) {
        my @backends = keys %{$to_fetch->{capabilities}};
        if (scalar @backends > 0) {
            foreach my $bc(@backends) {
                $to_fetch->{$bc} = $fetch_backends->{$bc}->capabilities;
            }
        }
    }

    # Now we've got all associated users and branches,
    # we can augment the request objects
    my @output = ();
    foreach my $req(@requests) {
        my $to_push = $req->unblessed;
        $to_push->{id_prefix} = $req->id_prefix;
        # Create new "formatted" columns for each date column
        # that needs formatting
        foreach my $field(@format_dates) {
            if (defined $to_push->{$field}) {
                $to_push->{$field . "_formatted"} = format_sqldatetime(
                    $to_push->{$field},
                    undef,
                    undef,
                    1
                );
            }
        }

        foreach my $p(@{$patron_arr}) {
            if ($p->{borrowernumber} == $req->borrowernumber) {
                $to_push->{patron} = {
                    patron_id => $p->{borrowernumber},
                    firstname      => $p->{firstname},
                    surname        => $p->{surname},
                    cardnumber     => $p->{cardnumber}
                };
                last;
            }
        }
        foreach my $b(@{$branch_arr}) {
            if ($b->{branchcode} eq $req->branchcode) {
                $to_push->{library} = $b;
                last;
            }
        }
        if ($embed{metadata}) {
            my $metadata = Koha::Illrequestattributes->search(
                { illrequest_id => $req->illrequest_id },
                { columns => [qw/type value/] }
            )->unblessed;
            my $meta_hash = {};
            foreach my $meta(@{$metadata}) {
                $meta_hash->{$meta->{type}} = $meta->{value};
            }
            $to_push->{metadata} = $meta_hash;
        }
        if ($embed{capabilities}) {
            $to_push->{capabilities} = $to_fetch->{$req->backend};
        }
        if ($embed{comments}) {
            $to_push->{comments} = $req->illcomments->count;
        }
        if ($embed{status_alias}) {
            $to_push->{status_alias} = $req->statusalias;
        }
        if ($embed{requested_partners}) {
            $to_push->{requested_partners} = $req->requested_partners;
        }
        push @output, $to_push;
    }

    return $c->render( status => 200, openapi => \@output );
}

1;
