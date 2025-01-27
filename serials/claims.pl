#!/usr/bin/perl

# Parts Copyright 2010 Biblibre

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
use CGI         qw ( -utf8 );
use C4::Auth    qw( get_template_and_user );
use C4::Serials qw( GetSuppliersWithLateIssues GetLateOrMissingIssues updateClaim can_claim_subscription );
use C4::Output  qw( output_html_with_http_headers );
use C4::Context;
use C4::Letters qw( GetLetters SendAlerts );

use Koha::AdditionalFields;
use Koha::CsvProfiles;

my $input = CGI->new;

my $serialid     = $input->param('serialid');
my $op           = $input->param('op');
my $claimletter  = $input->param('claimletter');
my $supplierid   = $input->param('supplierid');
my $suppliername = $input->param('suppliername');

# open template first (security & userenv set here)
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'serials/claims.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { serials => 'claim_serials' },
    }
);

# supplierlist is returned in name order
my $supplierlist = GetSuppliersWithLateIssues();
for my $s ( @{$supplierlist} ) {
    $s->{count} = scalar GetLateOrMissingIssues( $s->{id} );
    if ( $supplierid && $s->{id} == $supplierid ) {
        $s->{selected} = 1;
    }
}

my $additional_fields = Koha::AdditionalFields->search( { tablename => 'subscription', searchable => 1 } );

my @serialnums = $input->multi_param('serialid');
if (@serialnums) {    # i.e. they have been flagged to generate claims
    my $err;
    eval {
        $err = SendAlerts( 'claimissues', \@serialnums, scalar $input->param("letter_code") );
        if ( not ref $err or not exists $err->{error} ) {
            C4::Serials::updateClaim( \@serialnums );
        }
    };
    if ($@) {
        $template->param( error_claim => $@ );
    } elsif ( ref $err and exists $err->{error} ) {
        if ( $err->{error} eq "no_email" ) {
            $template->param( error_claim => 'no_vendor_email' );
        } elsif ( $err->{error} =~ m|Bad or missing From address| ) {
            $template->param( error_claim => 'bad_or_missing_sender' );
        }
    } else {
        $template->param( info_claim => 1 );
    }
}

my $letters = GetLetters( { module => 'claimissues' } );

my @missingissues;
if ($supplierid) {
    my $supplier = Koha::Acquisition::Booksellers->find($supplierid);
    @missingissues = GetLateOrMissingIssues($supplierid);
    foreach my $issue (@missingissues) {
        $issue->{cannot_claim} = 1
            unless C4::Serials::can_claim_subscription($issue);

        $issue->{additional_field_values} =
            Koha::Subscriptions->find( $issue->{subscriptionid} )->get_additional_field_values_for_template;
    }
    $template->param( suppliername => $supplier->name );
}

$template->param(
    suploop                            => $supplierlist,
    missingissues                      => \@missingissues,
    supplierid                         => $supplierid,
    claimletter                        => $claimletter,
    additional_fields_for_subscription => $additional_fields,
    csv_profiles                       => Koha::CsvProfiles->search( { type => 'sql', used_for => 'late_issues' } ),
    letters                            => $letters,
    ( uc( C4::Context->preference("marcflavour") ) ) => 1
);
output_html_with_http_headers $input, $cookie, $template->output;
