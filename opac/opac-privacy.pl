#!/usr/bin/perl
# This script lets the users change their privacy rules
#
# copyright 2009, BibLibre, paul.poulain@biblibre.com
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

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Koha::Patrons;

my $query = CGI->new;

# if OPACPrivacy is disabled, leave immediately
if ( !C4::Context->preference('OPACPrivacy') || !C4::Context->preference('opacreadinghistory') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-privacy.tt",
        query         => $query,
        type          => "opac",
    }
);

my $op                          = $query->param("op");
my $privacy                     = $query->param("privacy");
my $privacy_guarantor_checkouts = $query->param("privacy_guarantor_checkouts");
my $privacy_guarantor_fines     = $query->param("privacy_guarantor_fines");

my $patron = Koha::Patrons->find($borrowernumber);

if ( $op eq "cud-update_privacy" ) {
    if ($patron) {
        $patron->set(
            {
                privacy                     => $privacy,
                privacy_guarantor_checkouts => defined $privacy_guarantor_checkouts
                ? $privacy_guarantor_checkouts
                : $patron->privacy_guarantor_checkouts,
                privacy_guarantor_fines => defined $privacy_guarantor_fines
                ? $privacy_guarantor_fines
                : $patron->privacy_guarantor_fines,
            }
        )->store;
        $template->param( 'privacy_updated' => 1 );
    }
} elsif ( $op eq "cud-delete_record" ) {

    my $holds     = $query->param('holds');
    my $checkouts = $query->param('checkouts');
    my $all       = $query->param('all');

    $template->param( delete_all_quested => 1 )
        if $all;

    if ( $all or $checkouts ) {

        # delete all reading records for items returned
        my $rows = eval { $patron->old_checkouts->anonymize + 0 };

        $template->param(
            (
                  $@    ? ( error_deleting_checkouts_history => 1 )
                : $rows ? ( deleted_checkouts => int($rows) )
                :         ( no_checkouts_to_delete => 1 )
            ),
            delete_checkouts_requested => 1,
        );
    }

    if ( $all or $holds ) {

        my $rows = eval { $patron->old_holds->anonymize + 0 };

        $template->param(
            (
                  $@    ? ( error_deleting_holds_history => 1 )
                : $rows ? ( deleted_holds => int($rows) )
                :         ( no_holds_to_delete => 1 )
            ),
            delete_holds_requested => 1,
        );
    }
}

$template->param(
    'Ask_data'                     => 1,
    'privacy' . $patron->privacy() => 1,
    'privacyview'                  => 1,
    'borrower'                     => $patron,
    'surname'                      => $patron->surname,
    'firstname'                    => $patron->firstname,
    'has_guarantor_flag'           => $patron->guarantor_relationships->guarantors->_resultset->count
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
