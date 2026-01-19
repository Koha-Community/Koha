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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw/-utf8/;

use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_html_with_http_headers );
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions::Patron;
use Koha::Patrons;

my $query = CGI->new;
my $op    = $query->param('op') // q{};
my $vars  = $query->Vars;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-patron-consent.tt",
        query         => $query,
        type          => "opac",
    }
);

my $patron = Koha::Patrons->find($borrowernumber)
    or Koha::Exceptions::Patron->throw("Patron id $borrowernumber not found");

# Get consent types and values
my @consents;
my $consent_types = Koha::Patron::Consents->available_types;
foreach my $consent_type ( sort keys %$consent_types ) {
    push @consents, $patron->consent($consent_type);
}

my $needs_redirect;

# Handle saves here
if ( $op && $op eq 'cud-save' ) {
    foreach my $consent (@consents) {
        my $check = $vars->{ "check_" . $consent->type };
        next if !defined($check);    # no choice made
        $needs_redirect = 1
            if $consent->type eq q/GDPR_PROCESSING/
            && !$check
            && C4::Context->preference('PrivacyPolicyConsent') eq 'Enforced';
        next if $consent->given_on && $check || $consent->refused_on && !$check;

        # No update if no consent change
        $consent->set(
            {
                given_on   => $check ? dt_from_string() : undef,
                refused_on => $check ? undef            : dt_from_string(),
            }
        )->store;
    }
}

# If user refused GDPR consent and we enforce GDPR, logout (when saving)
if ($needs_redirect) {
    print $query->redirect('/cgi-bin/koha/opac-main.pl?logout.x=1');
    exit;
}

$template->param( patron => $patron, consents => \@consents, consent_types => $consent_types );

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
