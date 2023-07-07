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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user checkauth );
use C4::Serials qw( CloseSubscription ReopenSubscription GetSubscription GetExpirationDate GetSerials HasSubscriptionStrictlyExpired CountIssues HasItems DelSubscription check_routing abouttoexpire can_edit_subscription );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use C4::Context;
use C4::Search qw( enabled_staff_search_views );

use Koha::AdditionalFields;
use Koha::AuthorisedValues;
use Koha::DateUtils qw( output_pref );
use Koha::Acquisition::Bookseller;
use Koha::Subscriptions;

use Carp qw( carp );

use Koha::SharedContent;

my $query = CGI->new;
my $op = $query->param('op') || q{};
my $issueconfirmed = $query->param('issueconfirmed');
my $dbh            = C4::Context->dbh;
my $subscriptionid = $query->param('subscriptionid');
my $subscription = Koha::Subscriptions->find( $subscriptionid );

if ( $op and $op eq "close" ) {
    C4::Serials::CloseSubscription( $subscriptionid );
} elsif ( $op and $op eq "reopen" ) {
    C4::Serials::ReopenSubscription( $subscriptionid );
}

# the subscription must be deletable if there is NO issues for a reason or another (should not happened, but...)

# Permission needed if it is a deletion (del) : delete_subscription
# Permission needed otherwise : *
my $permission = ($op eq "del") ? "delete_subscription" : "*";

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-detail.tt",
                query => $query,
                type => "intranet",
                flagsrequired => {serials => $permission},
                });

my $subs = GetSubscription($subscriptionid);

output_and_exit( $query, $cookie, $template, 'unknown_subscription')
    unless $subs;

$subs->{enddate} ||= GetExpirationDate($subscriptionid);

my ($totalissues,@serialslist) = GetSerials($subscriptionid);
$totalissues-- if $totalissues; # the -1 is to have 0 if this is a new subscription (only 1 issue)

if ($op eq 'del') {
    if ($$subs{'cannotedit'}){
        carp "Attempt to delete subscription $subscriptionid by ".C4::Context->userenv->{'id'}." not allowed";
        print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
        exit;
    }

    # Asking for confirmation if the subscription has not strictly expired yet or if it has linked issues
    my $strictlyexpired = HasSubscriptionStrictlyExpired($subscriptionid);
    my $linkedissues = CountIssues($subscriptionid);
    my $countitems   = HasItems($subscriptionid);
    if ($strictlyexpired == 0 || $linkedissues > 0 || $countitems>0) {
        $template->param(NEEDSCONFIRMATION => 1);
        if ($strictlyexpired == 0) { $template->param("NOTEXPIRED" => 1); }
        if ($linkedissues     > 0) { $template->param("LINKEDISSUES" => 1); }
        if ($countitems       > 0) { $template->param("LINKEDITEMS"  => 1); }
    } else {
        $issueconfirmed = "1";
    }
    # If it's ok to delete the subscription, we do so
    if ($issueconfirmed eq "1") {
        &DelSubscription($subscriptionid);
        print $query->redirect("/cgi-bin/koha/serials/serials-home.pl");
        exit;
    }
}
elsif ( $op and $op eq "share" ) {
    my $mana_language = $query->param('mana_language');
    my $result = Koha::SharedContent::send_entity($mana_language, $loggedinuser, $subscriptionid, 'subscription');
    $template->param( mana_code => $result->{msg} );
    $subs->{mana_id} = $result->{id};
}

my $hasRouting = check_routing($subscriptionid);

(undef, $cookie, undef, undef)
    = checkauth($query, 0, {catalogue => 1}, "intranet");

# COMMENT hdl : IMHO, we should think about passing more and more data hash to template->param rather than duplicating code a new coding Guideline ?

for my $date ( qw(startdate enddate firstacquidate histstartdate histenddate) ) {
    $subs->{$date} = output_pref( { str => $subs->{$date}, dateonly => 1 } )
        if $subs->{$date};
}
my $av = Koha::AuthorisedValues->search({ category => 'LOC', authorised_value => $subs->{location} });
$subs->{location} = $av->count ? $av->next->lib : '';
$av = Koha::AuthorisedValues->search({ category => 'CCODE', authorised_value => $subs->{ccode} });
$subs->{ccode} = $av->count ? $av->next->lib : '';
$subs->{abouttoexpire}  = abouttoexpire($subs->{subscriptionid});
$template->param(%{ $subs });
$template->param(biblionumber_for_new_subscription => $subs->{bibnum});
my @irregular_issues = split /;/, $subs->{irregularity};

my $frequency = C4::Serials::Frequency::GetSubscriptionFrequency($subs->{periodicity});
my $numberpattern = C4::Serials::Numberpattern::GetSubscriptionNumberpattern($subs->{numberpattern});

$template->param(
    available_additional_fields => Koha::AdditionalFields->search( { tablename => 'subscription' } ),
    additional_field_values => { map { $_->field->name => $_->value } $subscription->additional_field_values->as_list },
);

# FIXME Do we want to hide canceled orders?
my $orders = Koha::Acquisition::Orders->search( { subscriptionid => $subscriptionid }, { order_by => [ { -desc => 'timestamp' }, \[ "field(orderstatus, 'ordered', 'partial', 'complete')" ] ] } );
my $orders_grouped;
while ( my $o = $orders->next ) {
    if ( $o->ordernumber == $o->parent_ordernumber ) {
        $orders_grouped->{$o->parent_ordernumber}->{datereceived} = $o->datereceived;
        $orders_grouped->{$o->parent_ordernumber}->{orderstatus} = $o->orderstatus;
        $orders_grouped->{$o->parent_ordernumber}->{basket} = $o->basket;
    }
    $orders_grouped->{$o->parent_ordernumber}->{quantity} += $o->quantity;
    $orders_grouped->{$o->parent_ordernumber}->{ecost_tax_excluded} += sprintf('%.2f', $o->ecost_tax_excluded * $o->quantity);
    $orders_grouped->{$o->parent_ordernumber}->{ecost_tax_included} += sprintf('%.2f', $o->ecost_tax_included * $o->quantity);
    $orders_grouped->{$o->parent_ordernumber}->{unitprice_tax_excluded} += sprintf('%.2f', $o->unitprice_tax_excluded * $o->quantity);
    $orders_grouped->{$o->parent_ordernumber}->{unitprice_tax_included} += sprintf('%.2f', $o->unitprice_tax_included * $o->quantity);
    push @{$orders_grouped->{$o->parent_ordernumber}->{orders}}, $o;
}

$template->param(
    subscription => $subscription,
    subscriptionid => $subscriptionid,
    serialslist => \@serialslist,
    hasRouting  => $hasRouting,
    routing => C4::Context->preference("RoutingSerials"),
    totalissues => $totalissues,
    cannotedit => (not C4::Serials::can_edit_subscription( $subs )),
    frequency => $frequency,
    numberpattern => $numberpattern,
    has_X           => ($numberpattern->{'numberingmethod'} =~ /{X}/) ? 1 : 0,
    has_Y           => ($numberpattern->{'numberingmethod'} =~ /{Y}/) ? 1 : 0,
    has_Z           => ($numberpattern->{'numberingmethod'} =~ /{Z}/) ? 1 : 0,
    intranetstylesheet => C4::Context->preference('intranetstylesheet'),
    intranetcolorstylesheet => C4::Context->preference('intranetcolorstylesheet'),
    irregular_issues => scalar @irregular_issues,
    orders_grouped => $orders_grouped,
    (uc(C4::Context->preference("marcflavour"))) => 1,
    mana_comments => $subs->{comments},
);

output_html_with_http_headers $query, $cookie, $template->output;
