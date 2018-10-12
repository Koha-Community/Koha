#!/usr/bin/perl

# Copyright 2017 BibLibre
#
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

use CGI qw( -utf8 );

use C4::Auth;
use C4::Output;
use C4::Serials;
use Koha::Subscriptions;
use Koha::Acquisition::Booksellers;
use Koha::AdditionalField;
use Koha::DateUtils;

my $cgi = new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => 'serials/subscription-batchedit.tt',
    query => $cgi,
    type => 'intranet',
    authnotrequired => 0,
    flagsrequired => {serials => 'edit_subscription'},
});

my @subscriptionids = $cgi->multi_param('subscriptionid');

my @subscriptions;
foreach my $subscriptionid (@subscriptionids) {
    my $subscription = Koha::Subscriptions->find($subscriptionid);

    push @subscriptions, $subscription if $subscription;
}

my $additional_fields = Koha::AdditionalField->all({tablename => 'subscription'});

my $batchedit = $cgi->param('batchedit');
if ($batchedit) {
    my %params = (
        aqbooksellerid => scalar $cgi->param('booksellerid'),
        location => scalar $cgi->param('location'),
        branchcode => scalar $cgi->param('branchcode'),
        itemtype => scalar $cgi->param('itemtype'),
        notes => scalar $cgi->param('notes'),
        internalnotes => scalar $cgi->param('internalnotes'),
        serialsadditems => scalar $cgi->param('serialsadditems'),
        enddate => dt_from_string(scalar $cgi->param('enddate')),
    );

    my $field_values = {};
    foreach my $field (@$additional_fields) {
        my $value = $cgi->param('field_' . $field->{id});
        $field_values->{$field->{id}} = $value;
    }

    foreach my $subscription (@subscriptions) {
        next unless C4::Serials::can_edit_subscription( $subscription->unblessed ); # This should be moved to Koha::Subscription->can_edit
        while (my ($key, $value) = each %params) {
            if (defined $value and $value ne '') {
                $subscription->$key($value);
            }
        }

        foreach my $field (@$additional_fields) {
            my $value = $field_values->{$field->{id}};
            if (defined $value and $value ne '') {
                $field->{values} //= {};
                $field->{values}->{$subscription->subscriptionid} = $value;
            }
        }

        $subscription->store;
    }

    foreach my $field (@$additional_fields) {
        if (defined $field->{values}) {
            $field->insert_values();
        }
    }

    my $redirect_url = $cgi->param('referrer') // '/cgi-bin/koha/serials/serials-home.pl';
    print $cgi->redirect($redirect_url);
    exit;
}

$template->param(
    subscriptions => \@subscriptions,
    booksellers => [ Koha::Acquisition::Booksellers->search() ],
    additional_fields => $additional_fields,
    referrer => scalar $cgi->param('referrer'),
);

output_html_with_http_headers $cgi, $cookie, $template->output;
