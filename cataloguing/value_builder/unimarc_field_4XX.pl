#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


use strict;

use CGI;
use C4::Output;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;

use C4::Biblio;
use C4::Koha;
use MARC::Record;
use C4::Branch;    # GetBranches

sub plugin_parameters {
    my ( $dbh, $record, $tagslib, $i, $tabloop ) = @_;
    return "";
}

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;
    my $function_name = $field_number;
    my $res           = "
    <script type='text/javascript'>
        function Focus$function_name(subfield_managed) {
            return 1;
        }

        function Blur$function_name(subfield_managed) {
            return 1;
        }

        function Clic$function_name(i) {
            defaultvalue=document.getElementById(\"$field_number\").value;
            window.open(\"/cgi-bin/koha/cataloguing/plugin_launcher.pl?plugin_name=unimarc_field_4XX.pl&index=\" + i + \"&result=\"+defaultvalue,\"unimarc field 4\"+i+\"\",'width=900,height=700,toolbar=false,scrollbars=yes');

        }
    </script>
    ";

    return ( $function_name, $res );
}

# sub plugin
#
# input arg : 
# -- op could be equals to
# * fillinput : 
# * do_search : 
# 

sub plugin {
    my ($input)   = @_;
    my $dbh       = C4::Context->dbh;
    my $query     = new CGI;
    my $op        = $query->param('op');
    my $type      = $query->param('type');
    my $startfrom = $query->param('startfrom');
    $startfrom = 0 if ( !defined $startfrom );
    my ( $template, $loggedinuser, $cookie );
    my $resultsperpage;
    my $searchdesc;

    if ( $op eq "fillinput" ) {
        my $biblionumber = $query->param('biblionumber');
        my $index  = $query->param('index');
        my $marcrecord;

        # open template
        ( $template, $loggedinuser, $cookie ) = get_template_and_user(
            {
                template_name =>
                  "cataloguing/value_builder/unimarc_field_4XX.tmpl",
                query           => $query,
                type            => "intranet",
                authnotrequired => 0,
                flagsrequired   => { editcatalogue => 1 },
                debug           => 1,
            }
        );

        #get marc record
        $marcrecord = GetMarcBiblio($biblionumber);

        my $subfield_value_9 = $biblionumber;
        my $subfield_value_0;
        $subfield_value_0 = $marcrecord->field('001')->data
          if $marcrecord->field('001');
        my $subfield_value_a;
        if ( $marcrecord->field('700') ) {
            $subfield_value_a = $marcrecord->field('700')->subfield("a");
            $subfield_value_a .= ", " . $marcrecord->subfield( '700', "b" )
              if $marcrecord->subfield( '700', 'b' );
            $subfield_value_a .= " " . $marcrecord->subfield( '700', "d" )
              if $marcrecord->subfield( '700', 'd' );
            $subfield_value_a .=
              " (" . $marcrecord->subfield( '700', 'c' ) . " - "
              if $marcrecord->subfield( '700',     'c' );
            $subfield_value_a .= " ("
              if ( $marcrecord->subfield( '700', 'f' )
                and not( $marcrecord->subfield( '700', 'c' ) ) );
            $subfield_value_a .= $marcrecord->subfield( '700', 'f' )
              if ( $marcrecord->subfield( '700', 'f' ) );
            $subfield_value_a .= ")"
              if ( $marcrecord->subfield( '701', 'f' )
                or $marcrecord->subfield( '701', 'c' ) );
        }
        elsif ( $marcrecord->field('702') ) {
            $subfield_value_a = $marcrecord->subfield( '702', 'a' );
            $subfield_value_a .= ", " . $marcrecord->subfield( '702', 'b' )
              if $marcrecord->subfield( '702', 'b' );
            $subfield_value_a .= " " . $marcrecord->subfield( '702', 'd' )
              if $marcrecord->subfield( '702', 'd' );
            $subfield_value_a .=
              " (" . $marcrecord->subfield( '702', 'c' ) . "; "
              if $marcrecord->subfield( '702',     'c' );
            $subfield_value_a .= " ("
              if $marcrecord->subfield( '702', 'f' )
              and not $marcrecord->subfield( '702', 'c' );
            $subfield_value_a .= $marcrecord->subfield( '702', 'f' )
              if $marcrecord->subfield( '702', 'f' );
            $subfield_value_a .= ")"
              if $marcrecord->subfield( '702', 'f' )
              or $marcrecord->subfield( '702', 'c' );
        }
        elsif ( $marcrecord->field('710') ) {
            $subfield_value_a = $marcrecord->subfield( '710', 'd' ) . " "
              if $marcrecord->subfield( '710', 'd' );
            $subfield_value_a .= $marcrecord->subfield( '710', 'a' )
              if $marcrecord->subfield( '710', 'a' );
            $subfield_value_a .= ", " . $marcrecord->subfield( '710', 'b' )
              if $marcrecord->subfield('710');
            $subfield_value_a .=
              " (" . $marcrecord->subfield( '710', 'f' ) . " - "
              if $marcrecord->subfield( '710',     'f' );
            $subfield_value_a .= " ("
              if $marcrecord->subfield( '710', 'e' )
              and not $marcrecord->subfield( '710', 'f' );
            $subfield_value_a .= $marcrecord->subfield( '710', 'e' )
              if $marcrecord->subfield( '710', 'e' );
            $subfield_value_a .= ")"
              if $marcrecord->subfield( '710', 'e' )
              or $marcrecord->subfield( '710', 'f' );
        }
        elsif ( $marcrecord->field('701') ) {
            $subfield_value_a = $marcrecord->subfield( '701', 'a' );
            $subfield_value_a .= ", " . $marcrecord->subfield( '701', 'b' )
              if $marcrecord->subfield( '701', 'b' );
            $subfield_value_a .= " " . $marcrecord->subfield( '701', 'd', )
              if $marcrecord->subfield( '701', 'd' );
            $subfield_value_a .=
              " (" . $marcrecord->subfield( '701', 'c' ) . " - "
              if $marcrecord->subfield( '701',     'c' );
            $subfield_value_a .= " ("
              if $marcrecord->subfield( '701', 'f' )
              and not( $marcrecord->subfield( '701', 'c' ) );
            $subfield_value_a .= $marcrecord->subfield( '701', 'f' )
              if $marcrecord->subfield( '701', 'f' );
            $subfield_value_a .= ")"
              if $marcrecord->subfield( '701', 'f' )
              or $marcrecord->subfield( '701', 'c' );
        }
        elsif ( $marcrecord->field('712') ) {
            $subfield_value_a = $marcrecord->subfield( '712', 'd' ) . " "
              if $marcrecord->subfield( '712', 'd' );
            $subfield_value_a .= $marcrecord->subfield( '712', 'a' )
              if $marcrecord->subfield( '712', 'a' );
            $subfield_value_a .= ", " . $marcrecord->subfield( '712', 'b' )
              if $marcrecord->subfield( '712', 'b' );
            $subfield_value_a .=
              " (" . $marcrecord->subfield( '712', 'f' ) . " - "
              if $marcrecord->subfield( '712',     'f' );
            $subfield_value_a .= " ("
              if $marcrecord->field( '712', "e" )
              and not $marcrecord->subfield( '712', 'f' );
            $subfield_value_a .= $marcrecord->subfield( '712', 'e' )
              if $marcrecord->subfield( '712', 'e' );
            $subfield_value_a .= ")"
              if $marcrecord->subfield( '712', 'e' )
              or $marcrecord->subfield( '712', 'f' );
        }
        elsif ( $marcrecord->field('200') ) {
            $subfield_value_a = $marcrecord->subfield( '200', 'f' );
        }
        my $subfield_value_c = $marcrecord->field('210')->subfield("a")
          if ( $marcrecord->field('210') );
        my $subfield_value_d = $marcrecord->field('210')->subfield("d")
          if ( $marcrecord->field('210') );

        my $subfield_value_e = $marcrecord->field('205')->subfield("a")
          if ( $marcrecord->field('205') );

        my $subfield_value_h;
        if (   ( $marcrecord->field('200') )
            && ( $marcrecord->field('200')->subfield("h") ) )
        {
            $subfield_value_h = $marcrecord->field('200')->subfield("h");
        }
        elsif (( $marcrecord->field('225') )
            && ( $marcrecord->field('225')->subfield("h") ) )
        {
            $subfield_value_h = $marcrecord->field('225')->subfield("h");
        }
        elsif (( $marcrecord->field('500') )
            && ( $marcrecord->field('500')->subfield("h") ) )
        {
            $subfield_value_h = $marcrecord->field('500')->subfield("h");
        }

        my $subfield_value_i;
        if (   ( $marcrecord->field('200') )
            && ( $marcrecord->field('200')->subfield("i") ) )
        {
            $subfield_value_i = $marcrecord->field('200')->subfield("i");
        }
        elsif (( $marcrecord->field('225') )
            && ( $marcrecord->field('225')->subfield("i") ) )
        {
            $subfield_value_i = $marcrecord->field('225')->subfield("i");
        }
        elsif (( $marcrecord->field('500') )
            && ( $marcrecord->field('500')->subfield("i") ) )
        {
            $subfield_value_i = $marcrecord->field('500')->subfield("i");
        }

        my $subfield_value_p = $marcrecord->field('215')->subfield("a")
          if ( $marcrecord->field('215') );

        my $subfield_value_t;
        if (   ( $marcrecord->field('200') )
            && ( $marcrecord->field('200')->subfield("a") ) )
        {
            $subfield_value_t = $marcrecord->field('200')->subfield("a");
        }
        elsif (( $marcrecord->field('225') )
            && ( $marcrecord->field('225')->subfield("a") ) )
        {
            $subfield_value_t = $marcrecord->field('225')->subfield("a");
        }
        elsif (( $marcrecord->field('500') )
            && ( $marcrecord->field('500')->subfield("a") ) )
        {
            $subfield_value_t = $marcrecord->field('500')->subfield("a");
        }

        my $subfield_value_u = $marcrecord->field('856')->subfield("u")
          if ( $marcrecord->field('856') );

        my $subfield_value_v;
        if (   ( $marcrecord->field('225') )
            && ( $marcrecord->field('225')->subfield("v") ) )
        {
            $subfield_value_v = $marcrecord->field('225')->subfield("v");
        }
        elsif (( $marcrecord->field('200') )
            && ( $marcrecord->field('200')->subfield("h") ) )
        {
            $subfield_value_v = $marcrecord->field('200')->subfield("h");
        }
        my $subfield_value_x = $marcrecord->field('011')->subfield("a")
          if (
            $marcrecord->field('011')
            and not( ( $marcrecord->field('011')->subfield("y") )
                or ( $marcrecord->field('011')->subfield("z") ) )
          );
        my $subfield_value_y = $marcrecord->field('013')->subfield("a")
          if ( $marcrecord->field('013') );
        if   ( $marcrecord->field('010') ) {
            $subfield_value_y = $marcrecord->field('010')->subfield("a");
        }
        # escape the 's
        $subfield_value_9 =~ s/'/\\'/g;
        $subfield_value_0 =~ s/'/\\'/g;
        $subfield_value_a =~ s/'/\\'/g;
        $subfield_value_c =~ s/'/\\'/g;
        $subfield_value_d =~ s/'/\\'/g;
        $subfield_value_e =~ s/'/\\'/g;
        $subfield_value_h =~ s/'/\\'/g;
        $subfield_value_i =~ s/'/\\'/g;
        $subfield_value_p =~ s/'/\\'/g;
        $subfield_value_t =~ s/'/\\'/g;
        $subfield_value_u =~ s/'/\\'/g;
        $subfield_value_v =~ s/'/\\'/g;
        $subfield_value_x =~ s/'/\\'/g;
        $subfield_value_y =~ s/'/\\'/g;
        $template->param(
            fillinput        => 1,
            index            => $query->param('index') . "",
            biblionumber     => $biblionumber ? $biblionumber : "",
            subfield_value_9 => "$subfield_value_9",
            subfield_value_0 => "$subfield_value_0",
            subfield_value_a => "$subfield_value_a",
            subfield_value_c => "$subfield_value_c",
            subfield_value_d => "$subfield_value_d",
            subfield_value_e => "$subfield_value_e",
            subfield_value_h => "$subfield_value_h",
            subfield_value_i => "$subfield_value_i",
            subfield_value_p => "$subfield_value_p",
            subfield_value_t => "$subfield_value_t",
            subfield_value_u => "$subfield_value_u",
            subfield_value_v => "$subfield_value_v",
            subfield_value_x => "$subfield_value_x",
            subfield_value_y => "$subfield_value_y",
        );
###############################################################
    }
    elsif ( $op eq "do_search" ) {
        my $search         = $query->param('search');
        my $startfrom      = $query->param('startfrom');
        my $resultsperpage = $query->param('resultsperpage') || 20;
        my $orderby;
        my ( $errors, $results, $total_hits ) = SimpleSearch($search, $startfrom * $resultsperpage, $resultsperpage );
        my $total = scalar(@$results);

        #        warn " biblio count : ".$total;

        ( $template, $loggedinuser, $cookie ) = get_template_and_user(
            {
                template_name =>
                  "cataloguing/value_builder/unimarc_field_4XX.tmpl",
                query           => $query,
                type            => 'intranet',
                authnotrequired => 1,
                debug           => 1,
            }
        );

        # multi page display gestion
        my $displaynext = 0;
        my $displayprev = $startfrom;

        if( ( $total_hits - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
            $displaynext = 1;
        }
        my @arrayresults;
        my @field_data = ($search);
         for (
             my $i = 0 ;
             $i < $resultsperpage ;
             $i++
           )
         {
            my $record = MARC::Record::new_from_usmarc( $results->[$i] );
            my $rechash = TransformMarcToKoha( $dbh, $record );
            my $pos;
            my $countitems = 1 if ( $rechash->{itemnumber} );
            while ( index( $rechash->{itemnumber}, '|', $pos ) > 0 ) {
                $countitems += 1;
                $pos = index( $rechash->{itemnumber}, '|', $pos ) + 1;
            }
            $rechash->{totitem} = $countitems;
            my @holdingbranches = split /\|/, $rechash->{holdingbranch};
            my @itemcallnumbers = split /\|/, $rechash->{itemcallnumber};
            my $CN;
            for ( my $i = 0 ; $i < @holdingbranches ; $i++ ) {
                $CN .=
                  $holdingbranches[$i] . " ( " . $itemcallnumbers[$i] . " ) |";
            }
            $CN =~ s/ \|$//;
            $rechash->{CN} = $CN;
            push @arrayresults, $rechash;
         }

   #         for(my $i = 0 ; $i <= $#marclist ; $i++)
   #         {
   #             push @field_data, { term => "marclist", val=>$marclist[$i] };
   #             push @field_data, { term => "and_or", val=>$and_or[$i] };
   #             push @field_data, { term => "excluding", val=>$excluding[$i] };
   #             push @field_data, { term => "operator", val=>$operator[$i] };
   #             push @field_data, { term => "value", val=>$value[$i] };
   #         }

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

        if ( $total_hits < $from + $resultsperpage ) {
            $to = $total_hits;
        }else{
            $to = $from + $resultsperpage ;
        }
        my $defaultview =
          'BiblioDefaultView' . C4::Context->preference('BiblioDefaultView');
#         my $link="/cgi-bin/koha/cataloguing/value_builder/unimarc4XX.pl?op=do_search&q=$search_desc&resultsperpage=$resultsperpage&startfrom=$startfrom&search=$search";
#           foreach my $sort (@sort_by){      
#             $link.="&sort_by=".$sort."&";
#           }        
#           $template->param(
#             pagination_bar => pagination_bar(
#                     $link,
#                     getnbpages($hits, $results_per_page),
#                     $page,
#                     'page'
#             ),
#           );     
        $template->param(
            result         => \@arrayresults,
            index          => $query->param('index') . "",
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
            $defaultview   => 1,
            Search         => 0
        );

    }
    else {
        ( $template, $loggedinuser, $cookie ) = get_template_and_user(
            {
                template_name =>
                  "cataloguing/value_builder/unimarc_field_4XX.tmpl",
                query           => $query,
                type            => "intranet",
                authnotrequired => 1,
            }
        );

        my $sth =
          $dbh->prepare(
            "Select itemtype,description from itemtypes order by description");
        $sth->execute;
        my @itemtype;
        my %itemtypes;
        push @itemtype, "";
        $itemtypes{''} = "";
        while ( my ( $value, $lib ) = $sth->fetchrow_array ) {
            push @itemtype, $value;
            $itemtypes{$value} = $lib;
        }

        my $CGIitemtype = CGI::scrolling_list(
            -name     => 'value',
            -values   => \@itemtype,
            -labels   => \%itemtypes,
            -size     => 1,
            -multiple => 0
        );
        $sth->finish;

        my @branchloop;
        my @select_branch;
        my %select_branches;
        my $branches = GetBranches;
        push @select_branch, "";
        $select_branches{''} = "";
        foreach my $thisbranch ( keys %$branches ) {
            push @select_branch, $branches->{$thisbranch}->{'branchcode'};
            $select_branches{ $branches->{$thisbranch}->{'branchcode'} } =
              $branches->{$thisbranch}->{'branchname'};
        }
        my $CGIbranch = CGI::scrolling_list(
            -name     => 'value',
            -values   => \@select_branch,
            -labels   => \%select_branches,
            -size     => 1,
            -multiple => 0
        );
        $sth->finish;

        my $req =
          $dbh->prepare(
"select distinctrow left(publishercode,45) from biblioitems order by publishercode"
          );
        $req->execute;
        my @select;
        push @select, "";
        while ( my ($value) = $req->fetchrow ) {
            push @select, $value;
        }
        my $CGIpublisher = CGI::scrolling_list(
            -name     => 'value',
            -id       => 'publisher',
            -values   => \@select,
            -size     => 1,
            -multiple => 0
        );

#         my $sth=$dbh->prepare("select description,itemtype from itemtypes order by description");
#         $sth->execute;
#         while (my ($description,$itemtype) = $sth->fetchrow) {
#             $classlist.="<option value=\"$itemtype\">$description</option>\n";
#         }
#         $sth->finish;

        $template->param(    #classlist => $classlist,
            CGIitemtype  => $CGIitemtype,
            CGIbranch    => $CGIbranch,
            CGIPublisher => $CGIpublisher,
            index        => $query->param('index'),
            Search       => 1,
        );
    }
    output_html_with_http_headers $query, $cookie, $template->output;
}

1;
