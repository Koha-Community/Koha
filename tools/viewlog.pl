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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Auth qw( get_template_and_user );
use CGI      qw ( -utf8 );
use JSON;
use Text::CSV::Encoded;
use C4::Context;
use C4::Output  qw( output_html_with_http_headers );
use C4::Serials qw( CountSubscriptionFromBiblionumber );
use C4::Search  qw( enabled_staff_search_views );

use Koha::ActionLogs;
use Koha::Biblios;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::Patrons;
use Koha::Recalls;

=head1 viewlog.pl

plugin that shows stats

=cut

my $input = CGI->new;

my $do_it       = $input->param('do_it');               # no op: just viewing, downloading etc
my @modules     = $input->multi_param("modules");
my $user        = $input->param("user") // '';
my @actions     = $input->multi_param("actions");
my @interfaces  = $input->multi_param("interfaces");
my $object      = $input->param("object");
my $object_type = $input->param("object_type") // '';
my $info        = $input->param("info");
my $datefrom    = $input->param("from");
my $dateto      = $input->param("to");
my $basename    = $input->param("basename");
my $output      = $input->param("output") || "screen";
my $src         = $input->param("src")    || "";      # this param allows us to be told where we were called from -fbcit

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "tools/viewlog.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'view_system_logs' },
    }
);

if ( $src eq 'circ' ) {

    my $borrowernumber = $object;
    my $patron         = Koha::Patrons->find($borrowernumber);
    my $circ_info      = 1;
    unless ($patron) {
        $circ_info = 0;
    }

    $template->param(
        patron      => $patron,
        circulation => $circ_info,
    );
}

$template->param(
    C4::Search::enabled_staff_search_views,
    subscriptionsnumber => ( $object ? CountSubscriptionFromBiblionumber($object) : 0 ),
    object              => $object,
);

if ($do_it) {
    if ( $output eq "screen" ) {

        # Cataloguing modification log opens with modules=CATALOGUING and
        # object_type=biblio: surface item-level changes alongside the
        # biblio ones by collecting the biblio's itemnumbers and asking
        # the JS to filter on either object set. Mirrors the CSV export
        # branch below. The biblio object is also exposed so that the
        # biblio-view-menu sidebar can render its links.
        my $biblio;
        my @biblio_itemnumbers;
        if ( @modules == 1 && $object_type eq 'biblio' && $object ) {
            $biblio             = Koha::Biblios->find($object);
            @biblio_itemnumbers = $biblio->items->get_column('itemnumber') if $biblio;
        }

        # Screen output: pass search params to template, DataTable loads via REST API
        $template->param(
            logview            => 1,
            do_it              => 1,
            datefrom           => $datefrom,
            dateto             => $dateto,
            user               => $user,
            info               => $info,
            src                => $src,
            modules            => \@modules,
            actions            => \@actions,
            interfaces         => \@interfaces,
            object_type        => $object_type,
            biblio             => $biblio,
            biblio_itemnumbers => \@biblio_itemnumbers,
        );

        # Used modules
        foreach my $module (@modules) {
            $template->param( $module => 1 );
        }
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {

        # CSV export: fetch and enrich data server-side
        my $dtf = Koha::Database->new->schema->storage->datetime_parser;
        my %search_params;

        if ( $datefrom and $dateto ) {
            my $dateto_endday = dt_from_string($dateto);
            $dateto_endday->set(    # We set last second of day to see all log from that day
                hour   => 23,
                minute => 59,
                second => 59
            );
            $search_params{'timestamp'} = {
                -between => [
                    $dtf->format_datetime( dt_from_string($datefrom) ),
                    $dtf->format_datetime($dateto_endday),
                ]
            };
        } elsif ($datefrom) {
            $search_params{'timestamp'} = { '>=' => $dtf->format_datetime( dt_from_string($datefrom) ) };
        } elsif ($dateto) {
            my $dateto_endday = dt_from_string($dateto);
            $dateto_endday->set(    # We set last second of day to see all log from that day
                hour   => 23,
                minute => 59,
                second => 59
            );
            $search_params{'timestamp'} = { '<=' => $dtf->format_datetime($dateto_endday) };
        }

        # Circulation uses RENEWAL, but Patrons uses RENEW, this helps to find both
        if ( grep { $_ eq 'RENEW' } @actions ) {
            push @actions, 'RENEWAL';
        }

        $search_params{user}      = $user                    if $user;
        $search_params{module}    = { -in => [@modules] }    if ( defined $modules[0] and $modules[0] ne '' );
        $search_params{action}    = { -in => [@actions] }    if ( defined $actions[0] && $actions[0] ne '' );
        $search_params{interface} = { -in => [@interfaces] } if ( defined $interfaces[0] && $interfaces[0] ne '' );

        if ( @modules == 1 && $object_type eq 'biblio' ) {

            # Handle 'Modification log' from cataloguing
            my $biblio      = Koha::Biblios->find($object);
            my @itemnumbers = $biblio->items->get_column('itemnumber');
            $search_params{'-or'} = [
                { -and => { object => $object,       info => { -like => 'biblio%' } } },
                { -and => { object => \@itemnumbers, info => { -like => 'item%' } } },
            ];
        } else {
            $search_params{info}   = { -like => '%' . $info . '%' } if $info;
            $search_params{object} = $object                        if $object;
        }

        my @logs = Koha::ActionLogs->search( \%search_params )->as_list;

        my @data;
        foreach my $log (@logs) {
            my $result = $log->unblessed;

            # Init additional columns for CSV export
            $result->{'biblionumber'}     = q{};
            $result->{'biblioitemnumber'} = q{};
            $result->{'barcode'}          = q{};

            if ( defined $log->info && substr( $log->info, 0, 4 ) eq 'item' ) {

                # get item information so we can create a working link
                my $itemnumber = $log->object;
                my $item       = Koha::Items->find($itemnumber);
                if ($item) {
                    $result->{'biblionumber'}     = $item->biblionumber;
                    $result->{'biblioitemnumber'} = $item->biblionumber;
                    $result->{'barcode'}          = $item->barcode;
                }
            }

            if ( $log->module eq "CIRCULATION" ) {
                my $info = $log->info;
                my $decoded;
                my $is_json = eval {
                    $decoded = decode_json($info);
                    1;
                };

                if ( $is_json && ref($decoded) ) {
                    my $item = Koha::Items->find( $decoded->{itemnumber} );
                    if ($item) {
                        $decoded->{biblionumber}     = $item->biblionumber;
                        $decoded->{biblioitemnumber} = $item->biblionumber;
                        $decoded->{barcode}          = $item->barcode;
                    }
                } else {
                    my $item = Koha::Items->find($info);
                    if ($item) {
                        $result->{'biblionumber'}     = $item->biblionumber;
                        $result->{'biblioitemnumber'} = $item->biblionumber;
                        $result->{'barcode'}          = $item->barcode;
                    }
                }
            }

            push @data, $result;
        }

        # Printing to a csv file
        my $content = q{};
        if (@data) {
            my $delimiter = C4::Context->csv_delimiter;
            my $csv = Text::CSV::Encoded->new( { encoding_out => 'utf8', sep_char => $delimiter, formula => 'empty' } );
            $csv or die "Text::CSV::Encoded->new FAILED: " . Text::CSV::Encoded->error_diag();

            # First line with heading
            # Exporting bd id seems useless
            my @headings = grep { $_ ne 'action_id' } sort keys %{ $data[0] };
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
} else {
    output_html_with_http_headers $input, $cookie, $template->output;
}
