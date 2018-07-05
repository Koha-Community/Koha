package Koha::REST::V1::Illrequests;

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

use Koha::Illrequests;
use Koha::Illrequestattributes;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Libraries;

=head1 NAME

Koha::REST::V1::Illrequests

=head2 Operations

=head3 list

Return a list of ILL requests, after applying filters.

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $args = $c->req->params->to_hash // {};

    # Create a hash where all keys are embedded values
    # Enables easy checking
    my %embed;
    my $args_arr = (ref $args->{embed} eq 'ARRAY') ? $args->{embed} : [ $args->{embed} ];
    if (defined $args->{embed}) {
        %embed = map { $_ => 1 }  @{$args_arr};
        delete $args->{embed};
    }

    # Get all requests
    my @requests = Koha::Illrequests->as_list;

    # Identify patrons & branches that
    # we're going to need and get them
    my $to_fetch = {
        patrons      => {},
        branches     => {},
        capabilities => {}
    };
    foreach my $req(@requests) {
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
                my $backend = Koha::Illrequest->new->load_backend($bc);
                $to_fetch->{$bc} = $backend->capabilities;
            }
        }
    }

    # Now we've got all associated users and branches,
    # we can augment the request objects
    my @output = ();
    foreach my $req(@requests) {
        my $to_push = $req->unblessed;
        foreach my $p(@{$patron_arr}) {
            if ($p->{borrowernumber} == $req->borrowernumber) {
                $to_push->{patron} = {
                    firstname  => $p->{firstname},
                    surname    => $p->{surname},
                    cardnumber => $p->{cardnumber}
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
        push @output, $to_push;
    }

    return $c->render( status => 200, openapi => \@output );
}

1;
