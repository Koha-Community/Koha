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

use strict;
use warnings;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Output;
use C4::Context;
use C4::Letters;
use C4::Branch;    # GetBranches GetBranchesLoop
use C4::Koha qw( GetAuthorisedValues );
use Koha::AdditionalField;
use C4::Csv qw( GetCsvProfiles );

my $input = CGI->new;

my $serialid = $input->param('serialid');
my $op = $input->param('op');
my $claimletter = $input->param('claimletter');
my $supplierid = $input->param('supplierid');
my $suppliername = $input->param('suppliername');

# open template first (security & userenv set here)
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => 'serials/claims.tt',
            query => $input,
            type => 'intranet',
            authnotrequired => 0,
            flagsrequired => {serials => 'claim_serials'},
            debug => 1,
            });

# supplierlist is returned in name order
my $supplierlist = GetSuppliersWithLateIssues();
for my $s (@{$supplierlist} ) {
    $s->{count} = scalar  GetLateOrMissingIssues($s->{id});
    if ($supplierid && $s->{id} == $supplierid) {
        $s->{selected} = 1;
    }
}

my $additional_fields = Koha::AdditionalField->all( { tablename => 'subscription', searchable => 1 } );
for my $field ( @$additional_fields ) {
    if ( $field->{authorised_value_category} ) {
        $field->{authorised_value_choices} = GetAuthorisedValues( $field->{authorised_value_category} );
    }
}

my $branchloop = GetBranchesLoop();

my @serialnums=$input->param('serialid');
if (@serialnums) { # i.e. they have been flagged to generate claims
    my $err;
    eval {
        $err = SendAlerts('claimissues',\@serialnums,$input->param("letter_code"));
        if ( not ref $err or not exists $err->{error} ) {
           UpdateClaimdateIssues(\@serialnums);
        }
    };
    if ( $@ ) {
        $template->param(error_claim => $@);
    } elsif ( ref $err and exists $err->{error} ) {
        if ( $err->{error} eq "no_email" ) {
            $template->param( error_claim => 'no_vendor_email' );
        } elsif ( $err->{error} =~ m|Bad or missing From address| ) {
            $template->param( error_claim => 'no_loggedin_user_email' );
        }
    } else {
        $template->param( info_claim => 1 );
    }
}

my $letters = GetLetters({ module => 'claimissues' });

my @missingissues;
if ($supplierid) {
    @missingissues = GetLateOrMissingIssues($supplierid);
}

$template->param(
        suploop => $supplierlist,
        missingissues => \@missingissues,
        supplierid => $supplierid,
        claimletter => $claimletter,
        branchloop   => $branchloop,
        additional_fields_for_subscription => $additional_fields,
        csv_profiles => C4::Csv::GetCsvProfiles( "sql" ),
        letters => $letters,
        (uc(C4::Context->preference("marcflavour"))) => 1
        );
output_html_with_http_headers $input, $cookie, $template->output;
