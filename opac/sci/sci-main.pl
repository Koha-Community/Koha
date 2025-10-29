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

use C4::Auth        qw( get_template_and_user );
use C4::Circulation qw( AddReturn );
use C4::Output      qw( output_html_with_http_headers );
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::Items;

use List::MoreUtils qw( uniq );
use Try::Tiny       qw( catch try );

my $cgi = CGI->new;

# 404 if feature is disabled
unless ( C4::Context->preference('SelfCheckInModule') ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

# Let Auth know this is a SCI context
$cgi->param( -name => 'sci_user_login', -values => [1] );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "sci/sci-main.tt",
        flagsrequired => { self_check => 'self_checkin_module' },
        query         => $cgi,
        type          => "opac"
    }
);

my $op = $cgi->param('op') // '';

if ( $op eq 'cud-check_in' ) {
    ## Get the barcodes, perform some basic validation
    # Remove empty ones
    my @barcodes = grep { $_ ne '' } $cgi->multi_param('barcode');

    # Remove duplicates
    @barcodes = uniq @barcodes;

    # Read the library we are logged in from userenv
    my $library = C4::Context->userenv->{'branch'};
    my @success;
    my @errors;

    # Return items
    foreach my $barcode (@barcodes) {
        try {
            my ( $success, $messages, $checkout, $patron );
            my $item           = Koha::Items->find( { barcode => $barcode } );
            my $human_required = 0;
            if (   C4::Context->preference("CircConfirmItemParts")
                && defined($item)
                && $item->materials )
            {
                $human_required                   = 1;
                $success                          = 0;
                $messages->{additional_materials} = 1;
            }

            ( $success, $messages, $checkout, $patron ) = AddReturn( $barcode, $library ) unless $human_required;
            if ($success) {
                push @success,
                    {
                    barcode  => $barcode,
                    messages => $messages,
                    checkout => $checkout,
                    patron   => $patron
                    };

                # Rebuild holds queue on checkin
                Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
                    { biblio_ids => [ $item->biblionumber ] } )
                    if C4::Context->preference('RealTimeHoldsQueue');
            } else {
                push @errors,
                    {
                    barcode  => $barcode,
                    messages => $messages,
                    checkout => $checkout,
                    patron   => $patron
                    };
            }
        } catch {
            push @errors, { barcode => $barcode, messages => 'unknown_error' };
        };
    }
    $template->param( success => \@success, errors => \@errors, checkins => 1 );
}

# Make sure timeout has a reasonable value
my $timeout = C4::Context->preference('SelfCheckInTimeout') || 120;
$template->param( refresh_timeout => $timeout );

output_html_with_http_headers $cgi, $cookie, $template->output, undef, { force_no_caching => 1 };
