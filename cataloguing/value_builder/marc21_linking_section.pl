#!/usr/bin/perl

# Converted to new plugin style (Bug 13437)

# Copyright Biblibre 2007 - CILEA 2011
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

use CGI        qw ( -utf8 );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use C4::Search qw( new_record_from_zebra );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use C4::Biblio qw( TransformMarcToKoha );

use Koha::Biblios;
use Koha::ItemTypes;

use Koha::SearchEngine;
use Koha::SearchEngine::Search;

my $builder = sub {
    my ($params)      = @_;
    my $function_name = $params->{id};
    my $res           = "
  <script>
             function Click$function_name(event) {
                       defaultvalue=document.getElementById(event.data.id).value;
                 window.open(\"/cgi-bin/koha/cataloguing/plugin_launcher.pl?plugin_name=marc21_linking_section.pl&index=\" + event.data.id + \"&result=\"+defaultvalue, 'tag_editor', 'width=900,height=700,toolbar=false,scrollbars=yes');

             }
      </script>
      ";

    return $res;
};

my $launcher = sub {
    my ($params) = @_;
    my $query    = $params->{cgi};
    my $op       = $query->param('op') // '';

    # -- op could be equal to
    # * fillinput
    # * do_search

    my $type      = $query->param('type');
    my $startfrom = $query->param('startfrom');
    $startfrom = 0 if ( !defined $startfrom );
    my ( $template, $loggedinuser, $cookie );
    my $resultsperpage;

    if ( $op eq "fillinput" ) {
        my $biblionumber = $query->param('biblionumber');
        my $index        = $query->param('index');
        my $marcrecord;

        # open template
        ( $template, $loggedinuser, $cookie ) = get_template_and_user(
            {
                template_name => "cataloguing/value_builder/marc21_linking_section.tt",
                query         => $query,
                type          => "intranet",
                flagsrequired => { editcatalogue => '*' },
            }
        );

        #get marc record
        my $biblio = Koha::Biblios->find($biblionumber);
        $marcrecord = $biblio->metadata->record;

        #my $subfield_value_0;
        #$subfield_value_0 = $marcrecord->field('001')->data
        #  if $marcrecord->field('001');
        my $subfield_value_w = '';

        my $subfield_value_7 = '';
        my $subfield_value_9 = '';
        my $subfield_value_0 = '';
        my $subfield_value_a = '';
        my $subfield_value_b = '';
        my $subfield_value_c = '';
        my $subfield_value_d = '';
        my $subfield_value_e = '';

        my $subfield_value_h = '';

        my $subfield_value_i = '';
        my $subfield_value_k = '';

        my $subfield_value_p = '';

        my $subfield_value_t = '';

        my $subfield_value_u = '';
        my $subfield_value_v = '';
        my $subfield_value_x = '';
        my $subfield_value_y = '';
        my $subfield_value_z = '';

        my $main_entry;
        if ( $marcrecord->field('1..') ) {
            $main_entry = $marcrecord->field('1..')->clone;
            if ( $main_entry->tag eq '111' ) {
                $main_entry->delete_subfield( code => qr/[94j]/ );
            } else {
                $main_entry->delete_subfield( code => qr/[94e]/ );
            }
        }
        my $s7 = "nn" . substr( $marcrecord->leader, 6, 2 );
        if ($main_entry) {
            my $c1 = 'n';
            if ( $main_entry->tag =~ /^1[01]/ ) {
                $c1 = $main_entry->indicator('1')
                    if $main_entry->tag =~ /^1[01]/;
                $c1 = $main_entry->tag eq '100' ? 1 : 2 unless $c1 =~ /\d/;
            }
            my $c0 =
                ( $main_entry->tag eq '100' ) ? 'p'
                : (
                $main_entry->tag eq '110' ? 'c'
                : ( $main_entry->tag eq '111' ? 'm' : 'u' )
                );
            substr( $s7, 0, 2, $c0 . $c1 );
        }
        $subfield_value_7 = $s7;

        if ($main_entry) {
            my $a = $main_entry->as_string;
            $a =~ s/\.$// unless $a =~ /\b[a-z]{1,2}\.$/i;
            $subfield_value_a = $a;
        }

        my $f245c = $marcrecord->field('245')->clone;
        $f245c->delete_subfield( code => 'c' );
        my $t = $f245c->as_string;
        $t =~ s/(\s*\/\s*|\.)$//;
        $t                = ucfirst substr( $t, $f245c->indicator('2') );
        $subfield_value_t = $t;
        if ( $marcrecord->field('250') ) {
            my $b = $marcrecord->field('250')->as_string;
            $b =~ s/\.$//;
            $subfield_value_b = $b;
        }
        if ( $marcrecord->field('260') ) {
            my $d = $marcrecord->field('260')->as_string('abc');
            $d =~ s/\.$//;
            $subfield_value_d = $d;
        }
        for my $f ( $marcrecord->field('8[013][01]') ) {
            my $k = $f->as_string('abcdnjltnp');
            if ( $f->subfield('x') ) {
                $k .= ', ISSN ' . $f->subfield('x');
            }
            if ( $f->subfield('v') ) {
                $k .= ' ; ' . $f->subfield('v');
            }
            $subfield_value_k .= $subfield_value_k ? ". $k" : $k;
        }
        for my $f ( $marcrecord->field('022') ) {
            $subfield_value_x = $f->subfield('a') if $f->subfield('a');
        }
        for my $f ( $marcrecord->field('020') ) {
            $subfield_value_z = $f->subfield('a') if $f->subfield('a');
        }
        if ( $marcrecord->field('001') ) {
            my $w = $marcrecord->field('001')->data;
            if ( $marcrecord->field('003') ) {
                $w = '(' . $marcrecord->field('003')->data . ')' . $w;
            }
            $subfield_value_w = $w;
        }
        $subfield_value_w ||= $biblionumber;

        # escape the 's
        $subfield_value_7 =~ s/'/\\'/g;
        $subfield_value_9 =~ s/'/\\'/g;
        $subfield_value_0 =~ s/'/\\'/g;
        $subfield_value_a =~ s/'/\\'/g;
        $subfield_value_b =~ s/'/\\'/g;
        $subfield_value_c =~ s/'/\\'/g;
        $subfield_value_d =~ s/'/\\'/g;
        $subfield_value_e =~ s/'/\\'/g;
        $subfield_value_h =~ s/'/\\'/g;
        $subfield_value_i =~ s/'/\\'/g;
        $subfield_value_k =~ s/'/\\'/g;
        $subfield_value_p =~ s/'/\\'/g;
        $subfield_value_t =~ s/'/\\'/g;
        $subfield_value_u =~ s/'/\\'/g;
        $subfield_value_v =~ s/'/\\'/g;
        $subfield_value_w =~ s/'/\\'/g;
        $subfield_value_x =~ s/'/\\'/g;
        $subfield_value_y =~ s/'/\\'/g;
        $subfield_value_z =~ s/'/\\'/g;
        $template->param(
            fillinput        => 1,
            index            => scalar $query->param('index') . "",
            biblionumber     => $biblionumber ? $biblionumber : "",
            subfield_value_7 => "$subfield_value_7",
            subfield_value_9 => "$subfield_value_9",
            subfield_value_0 => "$subfield_value_0",
            subfield_value_a => "$subfield_value_a",
            subfield_value_b => "$subfield_value_b",
            subfield_value_c => "$subfield_value_c",
            subfield_value_d => "$subfield_value_d",
            subfield_value_e => "$subfield_value_e",
            subfield_value_h => "$subfield_value_h",
            subfield_value_i => "$subfield_value_i",
            subfield_value_k => "$subfield_value_k",
            subfield_value_p => "$subfield_value_p",
            subfield_value_t => "$subfield_value_t",
            subfield_value_u => "$subfield_value_u",
            subfield_value_v => "$subfield_value_v",
            subfield_value_w => "$subfield_value_w",
            subfield_value_x => "$subfield_value_x",
            subfield_value_y => "$subfield_value_y",
            subfield_value_z => "$subfield_value_z",
        );
###############################################################
    } elsif ( $op eq "do_search" ) {
        my $search         = $query->param('search');
        my $itype          = $query->param('itype');
        my $startfrom      = $query->param('startfrom')      || 0;
        my $resultsperpage = $query->param('resultsperpage') || 20;
        my $orderby;
        my $op = 'AND';

        my $searcher = Koha::SearchEngine::Search->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
        $search = 'kw:' . $search . " $op mc-itemtype:" . $itype if $itype;
        my ( $errors, $results, $total_hits ) = $searcher->simple_search_compat(
            $search,
            $startfrom * $resultsperpage,
            $resultsperpage
        );
        if ( defined $errors ) {
            $results = [];
        }
        my $total = @{$results};

        #        warn " biblio count : ".$total;

        ( $template, $loggedinuser, $cookie ) = get_template_and_user(
            {
                template_name => "cataloguing/value_builder/marc21_linking_section.tt",
                query         => $query,
                type          => 'intranet',
            }
        );

        # multi page display gestion
        my $displaynext = 0;
        my $displayprev = $startfrom;

        if ( ( $total_hits - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
            $displaynext = 1;
        }
        my @arrayresults;
        my @field_data = ($search);
        for ( my $i = 0 ; $i < $total && $i < $resultsperpage ; $i++ ) {
            my $record     = C4::Search::new_record_from_zebra( 'biblioserver', $results->[$i] );
            my $rechash    = TransformMarcToKoha( { record => $record } );
            my $pos        = 0;
            my $countitems = $rechash->{itembumber} ? 1 : 0;
            if ( $rechash->{itembumber} ) {
                while ( index( $rechash->{itemnumber}, '|', $pos ) > 0 ) {
                    $countitems += 1;
                    $pos = index( $rechash->{itemnumber}, '|', $pos ) + 1;
                }
            }
            $rechash->{totitem} = $countitems;
            my @holdingbranches = split /\|/, $rechash->{holdingbranch}  // '';
            my @itemcallnumbers = split /\|/, $rechash->{itemcallnumber} // '';
            my $CN              = '';
            for ( my $i = 0 ; $i < @holdingbranches ; $i++ ) {
                $CN .= $holdingbranches[$i] . " ( " . ( $itemcallnumbers[$i] ? $itemcallnumbers[$i] : '' ) . " ) |";
            }
            $CN =~ s/ \|$//;
            $rechash->{CN} = $CN;
            push @arrayresults, $rechash;
        }

        my @numbers = ();

        if ( $total_hits > $resultsperpage ) {
            for ( my $i = 1 ; $i < $total_hits / $resultsperpage + 1 ; $i++ ) {
                if ( $i < 16 ) {
                    my $highlight = 0;
                    ( $startfrom == ( $i - 1 ) ) && ( $highlight = 1 );
                    push @numbers,
                        {
                        number     => $i,
                        highlight  => $highlight,
                        searchdata => \@field_data,
                        startfrom  => ( $i - 1 )
                        };
                }
            }
        }

        my $from = $startfrom * $resultsperpage + 1;
        my $to;

        if ( $total_hits < $from + $resultsperpage ) {
            $to = $total_hits;
        } else {
            $to = $from + $resultsperpage;
        }

        $template->param(
            result         => \@arrayresults,
            index          => scalar $query->param('index') . "",
            startfrom      => $startfrom,
            displaynext    => $displaynext,
            displayprev    => $displayprev,
            resultsperpage => $resultsperpage,
            orderby        => $orderby,
            startfromnext  => $startfrom + 1,
            startfromprev  => $startfrom - 1,
            searchdata     => \@field_data,
            total          => $total_hits,
            from           => $from,
            to             => $to,
            numbers        => \@numbers,
            search         => $search,
            Search         => 0
        );

    } else {
        ( $template, $loggedinuser, $cookie ) = get_template_and_user(
            {
                template_name => "cataloguing/value_builder/marc21_linking_section.tt",
                query         => $query,
                type          => "intranet",
            }
        );

        my @itemtypes = Koha::ItemTypes->search->as_list;

        $template->param(
            itypeloop => \@itemtypes,
            index     => scalar $query->param('index'),
            Search    => 1,
        );
    }
    output_html_with_http_headers $query, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };
