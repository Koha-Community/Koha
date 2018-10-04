#!/usr/bin/perl

# Copyright 2010 BibLibre
# Copyright 2011 MJ Ray and software.coop
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

use C4::Auth;
use CGI qw ( -utf8 );
use Text::CSV::Encoded;
use C4::Context;
use C4::Koha;
use C4::Output;
use C4::Log;
use C4::Items;
use C4::Serials;
use C4::Debug;
use C4::Search;    # enabled_staff_search_views
use Koha::Patrons;

use vars qw($debug $cgi_debug);

=head1 viewlog.pl

plugin that shows stats

=cut

my $input = new CGI;

$debug or $debug = $cgi_debug;
my $do_it    = $input->param('do_it');
my @modules  = $input->multi_param("modules");
my $user     = $input->param("user") // '';
my @actions  = $input->multi_param("actions");
my @interfaces  = $input->multi_param("interfaces");
my $object   = $input->param("object");
my $info     = $input->param("info");
my $datefrom = $input->param("from");
my $dateto   = $input->param("to");
my $basename = $input->param("basename");
my $output   = $input->param("output") || "screen";
my $src      = $input->param("src") || ""; # this param allows us to be told where we were called from -fbcit

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/viewlog.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'view_system_logs' },
        debug           => 1,
    }
);

if ( $src eq 'circ' ) {

    # if we were called from circulation, use the circulation menu and get data to populate it -fbcit
    use C4::Members::Attributes qw(GetBorrowerAttributes);
    my $borrowernumber = $object;
    my $patron = Koha::Patrons->find( $borrowernumber );
    unless ( $patron ) {
        print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
        exit;
    }
    if ( C4::Context->preference('ExtendedPatronAttributes') ) {
        my $attributes = GetBorrowerAttributes( $borrowernumber );
        $template->param(
            ExtendedPatronAttributes => 1,
            extendedattributes       => $attributes
        );
    }

    $template->param(
        patron      => $patron,
        circulation => 1,
    );
}

$template->param(
    debug => $debug,
    C4::Search::enabled_staff_search_views,
    subscriptionsnumber => CountSubscriptionFromBiblionumber($input->param('object')),
    object => $object,
);

if ($do_it) {

    my @data;
    my ( $results, $modules, $actions, $interfaces );
    if ( defined $actions[0] && $actions[0] ne '' ) { $actions  = \@actions; }     # match All means no limit
    if ( $modules[0] ne '' ) { $modules = \@modules; }    # match All means no limit
    if ( defined $interfaces[0] && $interfaces[0] ne '' ) { $interfaces = \@interfaces; }    # match All means no limit
    $results = GetLogs( $datefrom, $dateto, $user, $modules, $actions, $object, $info, $interfaces );
    @data = @$results;
    foreach my $result (@data) {

        # Init additional columns for CSV export
        $result->{'biblionumber'}      = q{};
        $result->{'biblioitemnumber'}  = q{};
        $result->{'barcode'}           = q{};

        if ( substr( $result->{'info'}, 0, 4 ) eq 'item' || $result->{module} eq "CIRCULATION" ) {

            # get item information so we can create a working link
            my $itemnumber = $result->{'object'};
            $itemnumber = $result->{'info'} if ( $result->{module} eq "CIRCULATION" );
            my $item = GetItem($itemnumber);
            if ($item) {
                $result->{'biblionumber'}     = $item->{'biblionumber'};
                $result->{'biblioitemnumber'} = $item->{'biblionumber'};
                $result->{'barcode'}          = $item->{'barcode'};
            }
        }

        #always add firstname and surname for librarian/user
        if ( $result->{'user'} ) {
            my $patron = Koha::Patrons->find( $result->{'user'} );
            if ($patron) {
                $result->{librarian} = $patron;
            }
        }

        #add firstname and surname for borrower, when using the CIRCULATION, MEMBERS, FINES
        if ( $result->{module} eq "CIRCULATION" || $result->{module} eq "MEMBERS" || $result->{module} eq "FINES" ) {
            if ( $result->{'object'} ) {
                my $patron = Koha::Patrons->find( $result->{'object'} );
                if ($patron) {
                    $result->{patron} = $patron;
                }
            }
        }
    }

    if ( $output eq "screen" ) {

        # Printing results to screen
        $template->param(
            logview  => 1,
            total    => scalar @data,
            looprow  => \@data,
            do_it    => 1,
            datefrom => $datefrom,
            dateto   => $dateto,
            user     => $user,
            info     => $info,
            src      => $src,
            modules  => \@modules,
            actions  => \@actions,
            interfaces => \@interfaces
        );

        # Used modules
        foreach my $module (@modules) {
            $template->param( $module => 1 );
        }

        output_html_with_http_headers $input, $cookie, $template->output;
    }
    else {

        # Printing to a csv file
        my $content = q{};
        my $delimiter = C4::Context->preference('delimiter') || ',';
        if (@data) {
            my $csv = Text::CSV::Encoded->new( { encoding_out => 'utf8', sep_char => $delimiter } );
            $csv or die "Text::CSV::Encoded->new FAILED: " . Text::CSV::Encoded->error_diag();

            # First line with heading
            # Exporting bd id seems useless
            my @headings = grep { $_ ne 'action_id' } sort keys %{$data[0]};
            if ( $csv->combine(@headings) ) {
                $content .= $csv->string() . "\n";
            }

            # Lines of logs
            foreach my $line (@data) {
                my @cells = map { $line->{$_} } @headings;
                if ( $csv->combine(@cells) ) {
                    $content .= $csv->string() . "\n";
                }
            }
        }

        # Output
        print $input->header(
            -type       => 'text/csv',
            -attachment => $basename . '.csv',
        );
        print $content;
    }
    exit;
}
else {
    output_html_with_http_headers $input, $cookie, $template->output;
}
