#!/usr/bin/perl

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

# Routing Preview.pl script used to view a routing list after creation
# lets one print out routing slip and create (in this instance) the hierarchy
# of reserves for the serial
use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Koha;
use C4::Auth     qw( get_template_and_user );
use C4::Output   qw( output_html_with_http_headers );
use C4::Reserves qw( AddReserve ModReserve );
use C4::Context;
use C4::Serials qw( delroutingmember getroutinglist GetSubscription GetSerials check_routing );
use URI::Escape;

use Koha::Biblios;
use Koha::Libraries;
use Koha::Patrons;

my $query          = CGI->new;
my $subscriptionid = $query->param('subscriptionid');
my $issue          = $query->param('issue');
my $routingid;
my $op  = $query->param('op') || q{};
my $dbh = C4::Context->dbh;

if ( $op eq 'cud-delete' ) {
    delroutingmember( $routingid, $subscriptionid );
    my $sth = $dbh->prepare("UPDATE serial SET routingnotes = NULL WHERE subscriptionid = ?");
    $sth->execute($subscriptionid);
    print $query->redirect("routing.pl?subscriptionid=$subscriptionid&op=new");
}

if ( $op eq 'cud-edit' ) {
    print $query->redirect("routing.pl?subscriptionid=$subscriptionid");
}

my @routinglist = getroutinglist($subscriptionid);
my $subs        = GetSubscription($subscriptionid);
my ( $tmp, @serials ) = GetSerials($subscriptionid);
my ( $template, $loggedinuser, $cookie );

my $library;
if ( $op eq 'cud-save_and_preview' ) {

    # get biblio information....
    my $biblionumber = $subs->{'bibnum'};

    my $biblio = Koha::Biblios->find($biblionumber);
    my $items  = $biblio->items->search_ordered;
    my $branch =
          $items->count
        ? $items->next->holding_branch->branchcode
        : $subs->{branchcode};
    $library = Koha::Libraries->find($branch);

    if ( C4::Context->preference('RoutingListAddReserves') ) {

        my $notes;
        my $title = $subs->{'bibliotitle'};
        for my $routing (@routinglist) {
            my $sth = $dbh->prepare('SELECT * FROM reserves WHERE biblionumber = ? AND borrowernumber = ? LIMIT 1');
            $sth->execute( $biblionumber, $routing->{borrowernumber} );
            my $reserve = $sth->fetchrow_hashref;

            if ( $routing->{borrowernumber} == $reserve->{borrowernumber} ) {
                ModReserve(
                    {
                        rank           => $routing->{ranking},
                        biblionumber   => $biblionumber,
                        borrowernumber => $routing->{borrowernumber},
                        branchcode     => $branch
                    }
                );
            } else {
                AddReserve(
                    {
                        branchcode     => $branch,
                        borrowernumber => $routing->{borrowernumber},
                        biblionumber   => $biblionumber,
                        priority       => $routing->{ranking},
                        notes          => $notes,
                        title          => $title,
                    }
                );
            }
        }
    }
    print $query->redirect(
        "/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid&print_routing_list_issue="
            . $query->param('issue_escaped') );
    exit;
} elsif ( $op eq 'print' ) {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "serials/routing-preview-slip.tt",
            query         => $query,
            type          => "intranet",
            flagsrequired => { serials => '*' },
        }
    );
} else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name => "serials/routing-preview.tt",
            query         => $query,
            type          => "intranet",
            flagsrequired => { serials => '*' },
        }
    );
}

$template->param( libraryname => $library->branchname ) if $library;

my $memberloop = [];
for my $routing (@routinglist) {
    my $member = Koha::Patrons->find( $routing->{borrowernumber} )->unblessed;
    $member->{name} = "$member->{firstname} $member->{surname}";
    push @{$memberloop}, $member;
}

my $routingnotes = $serials[0]->{'routingnotes'};
$routingnotes =~ s/\n/\<br \/\>/g;

$template->param(
    title                                            => $subs->{'bibliotitle'},
    issue                                            => $issue,
    issue_escaped                                    => URI::Escape::uri_escape_utf8($issue),
    subscriptionid                                   => $subscriptionid,
    memberloop                                       => $memberloop,
    routingnotes                                     => $routingnotes,
    hasRouting                                       => check_routing($subscriptionid),
    ( uc( C4::Context->preference("marcflavour") ) ) => 1
);

output_html_with_http_headers $query, $cookie, $template->output;
