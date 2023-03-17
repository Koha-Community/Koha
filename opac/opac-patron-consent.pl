#!/usr/bin/perl

# Copyright 2018 Rijksmuseum
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
use CGI qw/-utf8/;

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::DateUtils qw( dt_from_string );
use Koha::Patron::Consents;
use Koha::Patrons;

use constant GDPR_PROCESSING => 'GDPR_PROCESSING';

my $query = CGI->new;
my $op = $query->param('op') // q{};
my $gdpr_check = $query->param('gdpr_processing') // q{};

my ( $template, $borrowernumber, $cookie ) = get_template_and_user({
    template_name   => "opac-patron-consent.tt",
    query           => $query,
    type            => "opac",
});

my $patron = Koha::Patrons->find($borrowernumber);
my $gdpr_proc_consent;
if( C4::Context->preference('PrivacyPolicyConsent') ) {
    $gdpr_proc_consent = Koha::Patron::Consents->search({
        borrowernumber => $borrowernumber,
        type => GDPR_PROCESSING,
    })->next;
    $gdpr_proc_consent //= Koha::Patron::Consent->new({
        borrowernumber => $borrowernumber,
        type => GDPR_PROCESSING,
    });
}

# Handle saves here
if( $op eq 'gdpr_proc_save' && $gdpr_proc_consent ) {
    if( $gdpr_check eq 'agreed' ) {
        $gdpr_proc_consent->given_on( dt_from_string() );
        $gdpr_proc_consent->refused_on( undef );
    } elsif( $gdpr_check eq 'disagreed' ) {
        $gdpr_proc_consent->given_on( undef );
        $gdpr_proc_consent->refused_on( dt_from_string() );
    }
    $gdpr_proc_consent->store;
}

# If user refused GDPR consent and we enforce GDPR, logout (when saving)
if( $op =~ /save/ && C4::Context->preference('PrivacyPolicyConsent') eq 'Enforced' && $gdpr_proc_consent->refused_on )
{
    print $query->redirect('/cgi-bin/koha/opac-main.pl?logout.x=1');
    exit;
}

$template->param( patron => $patron );
if( $gdpr_proc_consent ) {
    $template->param(
        gdpr_proc_consent => $gdpr_proc_consent->given_on // q{},
        gdpr_proc_refusal => $gdpr_proc_consent->refused_on // q{},
    );
}

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
