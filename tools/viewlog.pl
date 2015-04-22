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
use CGI;
use Text::CSV::Encoded;
use C4::Context;
use C4::Koha;
use C4::Dates;
use C4::Output;
use C4::Log;
use C4::Items;
use C4::Branch;
use C4::Debug;
use C4::Search;    # enabled_staff_search_views

use vars qw($debug $cgi_debug);

=head1 viewlog.pl

plugin that shows stats

=cut

my $input = new CGI;

$debug or $debug = $cgi_debug;
my $do_it    = $input->param('do_it');
my @modules  = $input->param("modules");
my $user     = $input->param("user") // '';
my @actions  = $input->param("actions");
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
    use C4::Members;
    use C4::Members::Attributes qw(GetBorrowerAttributes);
    my $borrowernumber = $object;
    my $data = GetMember( 'borrowernumber' => $borrowernumber );
    my ( $picture, $dberror ) = GetPatronImage( $data->{'borrowernumber'} );
    $template->param( picture => 1 ) if $picture;

    if ( C4::Context->preference('ExtendedPatronAttributes') ) {
        my $attributes = GetBorrowerAttributes( $data->{'borrowernumber'} );
        $template->param(
            ExtendedPatronAttributes => 1,
            extendedattributes       => $attributes
        );
    }

    # Computes full borrower address
    my $roadtype = C4::Koha::GetAuthorisedValueByCode( 'ROADTYPE', $data->{streettype} );
    my $address = $data->{'streetnumber'} . " $roadtype " . $data->{'address'};

    $template->param(
        menu           => 1,
        title          => $data->{'title'},
        initials       => $data->{'initials'},
        surname        => $data->{'surname'},
        othernames     => $data->{'othernames'},
        borrowernumber => $borrowernumber,
        firstname      => $data->{'firstname'},
        cardnumber     => $data->{'cardnumber'},
        categorycode   => $data->{'categorycode'},
        category_type  => $data->{'category_type'},
        categoryname   => $data->{'description'},
        address        => $address,
        address2       => $data->{'address2'},
        city           => $data->{'city'},
        state          => $data->{'state'},
        zipcode        => $data->{'zipcode'},
        country        => $data->{'country'},
        phone          => $data->{'phone'},
        phonepro       => $data->{'phonepro'},
        mobile         => $data->{'mobile'},
        email          => $data->{'email'},
        emailpro       => $data->{'emailpro'},
        branchcode     => $data->{'branchcode'},
        branchname     => GetBranchName( $data->{'branchcode'} ),
        RoutingSerials => C4::Context->preference('RoutingSerials'),
    );
}

$template->param(
    debug => $debug,
    C4::Search::enabled_staff_search_views,
);

if ($do_it) {

    my @data;
    my ( $results, $modules, $actions );
    if ( defined $actions[0] && $actions[0] ne '' ) { $actions  = \@actions; }     # match All means no limit
    if ( $modules[0] ne '' ) { $modules = \@modules; }    # match All means no limit
    $results = GetLogs( $datefrom, $dateto, $user, $modules, $actions, $object, $info );
    @data = @$results;
    foreach my $result (@data) {

        # Init additional columns for CSV export
        $result->{'biblionumber'}      = q{};
        $result->{'biblioitemnumber'}  = q{};
        $result->{'barcode'}           = q{};
        $result->{'userfirstname'}     = q{};
        $result->{'usersurname'}       = q{};
        $result->{'borrowerfirstname'} = q{};
        $result->{'borrowersurname'}   = q{};

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
            my $userdetails = C4::Members::GetMemberDetails( $result->{'user'} );
            if ($userdetails) {
                $result->{'userfirstname'} = $userdetails->{'firstname'};
                $result->{'usersurname'}   = $userdetails->{'surname'};
            }
        }

        #add firstname and surname for borrower, when using the CIRCULATION, MEMBERS, FINES
        if ( $result->{module} eq "CIRCULATION" || $result->{module} eq "MEMBERS" || $result->{module} eq "FINES" ) {
            if ( $result->{'object'} ) {
                my $borrowerdetails = C4::Members::GetMemberDetails( $result->{'object'} );
                if ($borrowerdetails) {
                    $result->{'borrowerfirstname'} = $borrowerdetails->{'firstname'};
                    $result->{'borrowersurname'}   = $borrowerdetails->{'surname'};
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
            object   => $object,
            action   => \@actions,
            info     => $info,
            src      => $src,
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
