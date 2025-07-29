#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use CGI qw ( -utf8 );
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Languages;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;

use Koha::Authority::Types;
use Koha::Authorities;
use Koha::XSLT::Base;

my $query        = CGI->new;
my $op           = $query->param('op') || '';
my $authtypecode = $query->param('authtypecode') || '';
my $index        = $query->param('index') || '';
my $tagid        = $query->param('tagid') || '';
my $source       = $query->param('source') || '';
my $relationship = $query->param('relationship') || '';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => ( $op eq 'do_search' )
        ? 'authorities/searchresultlist-auth.tt'
        : 'authorities/auth_finder.tt',
        query           => $query,
        type            => 'intranet',
        flagsrequired   => { catalogue => 1 },
    }
);

my $authority_types = Koha::Authority::Types->search( {}, { order_by => ['authtypetext'] } );

# If search form posted
if ( $op eq "do_search" ) {
    my @marclist  = $query->multi_param('marclist');
    my @and_or    = $query->multi_param('and_or');
    my @excluding = $query->multi_param('excluding');
    my @operator  = $query->multi_param('operator');
    my @value     = (
        $query->param('value_mainstr') || undef,
        $query->param('value_main')    || undef,
        $query->param('value_match')   || undef,
        $query->param('value_any')     || undef,
    );
    my $orderby        = $query->param('orderby')        || '';
    my $startfrom      = $query->param('startfrom')      || 0;
    my $resultsperpage = $query->param('resultsperpage') || 20;

    if ( C4::Context->preference('ConsiderHeadingUse') ) {
        my $marcflavour = C4::Context->preference('marcflavour');
        my $biblio_tag  = substr( $index, 4, 3 );
        if ( $marcflavour eq 'MARC21' ) {
            my $heading_use_search_field =
                  $biblio_tag =~ /^[127]/ ? 'Heading-use-main-or-added-entry'
                : $biblio_tag =~ /^6/     ? 'Heading-use-subject-added-entry'
                : $biblio_tag =~ /^[48]/  ? 'Heading-use-series-added-entry'
                :                           undef;
            if ($heading_use_search_field) {
                push @marclist,  $heading_use_search_field;
                push @and_or,    'and';
                push @excluding, '';
                push @operator,  'is';
                push @value,     'a';
            }
        }
    }

    my $builder = Koha::SearchEngine::QueryBuilder->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $searcher = Koha::SearchEngine::Search->new(
        { index => $Koha::SearchEngine::AUTHORITIES_INDEX } );
    my $search_query = $builder->build_authorities_query_compat(
        \@marclist, \@and_or, \@excluding, \@operator,
        \@value, $authtypecode, $orderby
    );
    $template->param( search_query => $search_query ) if C4::Context->preference('DumpSearchQueryTemplate');
    my $offset = $startfrom * $resultsperpage;
    my ( $results, $total ) =
        $searcher->search_auth_compat( $search_query, $offset,
        $resultsperpage );

    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    if ( ( $total - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
        $displaynext = 1;
    }

    my @field_data = ();

# get marclist again, as the previous one has been modified by catalogsearch (mainentry replaced by field name)
    my @marclist_ini = $query->multi_param('marclist');
    for ( my $i = 0 ; $i <= $#marclist ; $i++ ) {
        push @field_data, { term => "marclist",  val => $marclist_ini[$i] };
        push @field_data, { term => "and_or",    val => $and_or[$i] };
        push @field_data, { term => "excluding", val => $excluding[$i] };
        push @field_data, { term => "operator",  val => $operator[$i] };
    }

    push @field_data,
      { term => "value_mainstr", val => scalar $query->param('value_mainstr') || "" };
    push @field_data,
      { term => "value_main", val => scalar $query->param('value_main') || "" };
    push @field_data,
      { term => "value_match", val => scalar $query->param('value_match') || "" };
    push @field_data,
      { term => "value_any", val => scalar $query->param('value_any') || "" };

    my @numbers = ();
    if ( $total > $resultsperpage ) {
        for ( my $i = 1 ; $i < $total / $resultsperpage + 1 ; $i++ ) {
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
    if ( $total < ( ( $startfrom + 1 ) * $resultsperpage ) ) {
        $to = $total;
    }
    else {
        $to = ( ( $startfrom + 1 ) * $resultsperpage );
    }

    my $AuthorityXSLTResultsDisplay = C4::Context->preference('AuthorityXSLTResultsDisplay');
    if ( $results && $AuthorityXSLTResultsDisplay ) {
        my $lang = C4::Languages::getlanguage();
        foreach my $result (@$results) {
            my $authority = Koha::Authorities->find( $result->{authid} );
            next unless $authority;

            my $authtypecode = $authority->authtypecode;
            my $xsl          = $AuthorityXSLTResultsDisplay;
            $xsl =~ s/\{langcode\}/$lang/g;
            $xsl =~ s/\{authtypecode\}/$authtypecode/g;

            my $xslt_engine = Koha::XSLT::Base->new;
            my $output      = $xslt_engine->transform( { xml => $authority->marcxml, file => $xsl } );
            if ( $xslt_engine->err ) {
                warn "XSL transformation failed ($xsl): " . $xslt_engine->err;
                next;
            }

            $result->{html} = $output;
        }
    }

    $template->param( result => $results ) if $results;
    $template->param(
        orderby          => $orderby,
        startfrom        => $startfrom,
        displaynext      => $displaynext,
        displayprev      => $displayprev,
        resultsperpage   => $resultsperpage,
        startfromnext    => $startfrom + 1,
        startfromprev    => $startfrom - 1,
        searchdata       => \@field_data,
        total            => $total,
        from             => $from,
        to               => $to,
        numbers          => \@numbers,
        operator_mainstr => ( @operator > 0 && $operator[0] ) ? $operator[0] : '',
        operator_main    => ( @operator > 1 && $operator[1] ) ? $operator[1] : '',
        operator_match   => ( @operator > 2 && $operator[2] ) ? $operator[2] : '',
        operator_any     => ( @operator > 3 && $operator[3] ) ? $operator[3] : '',
    );
}
else {

    # special case for UNIMARC field 210c builder
    my $resultstring = $query->param('result') || '';
    $template->param( resultstring => $resultstring, );
}

$template->param(
    op            => $op,
    value_mainstr => scalar $query->param('value_mainstr') || '',
    value_main    => scalar $query->param('value_main') || '',
    value_any     => scalar $query->param('value_any') || '',
    value_match   => scalar $query->param('value_match') || '',
    tagid         => $tagid,
    index         => $index,
    authority_types  => $authority_types,
    authtypecode  => $authtypecode,
    source        => $source,
    relationship  => $relationship,
);

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
