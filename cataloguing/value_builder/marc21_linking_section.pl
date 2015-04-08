#!/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use CGI;
use C4::Output;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;

use C4::Biblio;
use C4::Koha;
use MARC::Record;
use C4::Branch;
use C4::ItemType;

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
                 window.open(\"/cgi-bin/koha/cataloguing/plugin_launcher.pl?plugin_name=marc21_linking_section.pl&index=\" + i + \"&result=\"+defaultvalue,\"marc21_field_7\"+i+\"\",'width=900,height=700,toolbar=false,scrollbars=yes');

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
              my $index        = $query->param('index');
             my $marcrecord;

               # open template
                ( $template, $loggedinuser, $cookie ) = get_template_and_user(
                 {
                              template_name =>
                                 "cataloguing/value_builder/marc21_linking_section.tt",
                               query           => $query,
                             type            => "intranet",
                         authnotrequired => 0,
                          flagsrequired   => { editcatalogue => '*' },
                           debug           => 1,
                  }
              );

            #get marc record
               $marcrecord = GetMarcBiblio($biblionumber);

           my $subfield_value_9 = $biblionumber;
          my $subfield_value_0 = $biblionumber;

         #my $subfield_value_0;
         #$subfield_value_0 = $marcrecord->field('001')->data
           #  if $marcrecord->field('001');
               my $subfield_value_w;
          if ( $marcrecord->field('001') ) {
                     $subfield_value_w = $marcrecord->field('001')->data;
           }
              else {
                 $subfield_value_w = $biblionumber;
             }

             my $subfield_value_a;
          my $subfield_value_c;
          my $subfield_value_d;
          my $subfield_value_e;

         my $subfield_value_h;

         my $subfield_value_i;

         my $subfield_value_p;

         my $subfield_value_t;
          if ( $marcrecord->field('245') ) {
                     $subfield_value_t = $marcrecord->title();
              }

             my $subfield_value_u;
          my $subfield_value_v;
          my $subfield_value_x;
          my $subfield_value_y;
          my $subfield_value_z;

         $subfield_value_x = $marcrecord->field('022')->subfield("a")
             if ( $marcrecord->field('022') );
            $subfield_value_z = $marcrecord->field('020')->subfield("a")
             if ( $marcrecord->field('020') );

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
                $subfield_value_w =~ s/'/\\'/g;
                $subfield_value_x =~ s/'/\\'/g;
                $subfield_value_y =~ s/'/\\'/g;
                $subfield_value_z =~ s/'/\\'/g;
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
                       subfield_value_w => "$subfield_value_w",
                       subfield_value_x => "$subfield_value_x",
                       subfield_value_y => "$subfield_value_y",
                       subfield_value_z => "$subfield_value_z",
               );
###############################################################
     }
      elsif ( $op eq "do_search" ) {
         my $search         = $query->param('search');
          my $itype          = $query->param('itype');
           my $startfrom      = $query->param('startfrom');
               my $resultsperpage = $query->param('resultsperpage') || 20;
            my $orderby;
            my $QParser;
            $QParser = C4::Context->queryparser if (C4::Context->preference('UseQueryParser'));
            my $op;
            if ($QParser) {
                $op = '&&';
            } else {
                $op = 'and';
            }
           $search = 'kw:' . $search . " $op mc-itemtype:" . $itype if $itype;
               my ( $errors, $results, $total_hits ) =
                  SimpleSearch( $search, $startfrom * $resultsperpage,
                 $resultsperpage );
             if ( defined $errors ) {
                       $results = [];
         }
              my $total = @{$results};

              #        warn " biblio count : ".$total;

              ( $template, $loggedinuser, $cookie ) = get_template_and_user(
                 {
                              template_name =>
                                 "cataloguing/value_builder/marc21_linking_section.tt",
                               query           => $query,
                             type            => 'intranet',
                         authnotrequired => 0,
                          debug           => 1,
                  }
              );

            # multi page display gestion
           my $displaynext = 0;
           my $displayprev = $startfrom;

         if ( ( $total_hits - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 )
                {
                      $displaynext = 1;
              }
              my @arrayresults;
              my @field_data = ($search);
            for ( my $i = 0 ; $i < $resultsperpage ; $i++ ) {
                  my $record = C4::Search::new_record_from_zebra( 'biblioserver', $results->[$i] );
                  my $rechash = TransformMarcToKoha( $dbh, $record );
                    my $pos;
                       my $countitems = $rechash->{itembumber} ? 1 : 0;
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
             }
              else {
                 $to = $from + $resultsperpage;
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
                                 "cataloguing/value_builder/marc21_linking_section.tt",
                               query           => $query,
                             type            => "intranet",
                         authnotrequired => 0,
                  }
              );

            my @itemtypes = C4::ItemType->all;

            $template->param(
                        itypeloop    => \@itemtypes,
                        index        => $query->param('index'),
                        Search       => 1,
            );
     }
      output_html_with_http_headers $query, $cookie, $template->output;
}

1;
