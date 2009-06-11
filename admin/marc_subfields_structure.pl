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
use C4::Output;
use C4::Auth;
use CGI;
use C4::Context;


sub string_search {
    my ( $searchstring, $frameworkcode ) = @_;
    my $dbh = C4::Context->dbh;
    $searchstring =~ s/\'/\\\'/g;
    my @data  = split( ' ', $searchstring );
    my $count = @data;
    my $sth   =
      $dbh->prepare(
"Select * from marc_subfield_structure where (tagfield like ? and frameworkcode=?) order by tagfield"
      );
    $sth->execute( "$searchstring%", $frameworkcode );
    my @results;
    my $cnt = 0;
    my $u   = 1;

    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
        $cnt++;
        $u++;
    }
    $sth->finish;
    $dbh->disconnect;
    return ( $cnt, \@results );
}

sub marc_subfield_structure_exists {
    my ($tagfield, $tagsubfield, $frameworkcode) = @_;
    my $dbh  = C4::Context->dbh;
    my $sql  = "select tagfield from marc_subfield_structure where tagfield = ? and tagsubfield = ? and frameworkcode = ?";
    my $rows = $dbh->selectall_arrayref($sql, {}, $tagfield, $tagsubfield, $frameworkcode);
    return @$rows > 0;
}

my $input         = new CGI;
my $tagfield      = $input->param('tagfield');
my $tagsubfield   = $input->param('tagsubfield');
my $frameworkcode = $input->param('frameworkcode');
my $pkfield       = "tagfield";
my $offset        = $input->param('offset');
my $script_name   = "/cgi-bin/koha/admin/marc_subfields_structure.pl";

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/marc_subfields_structure.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1 },
        debug           => 1,
    }
);
my $pagesize = 30;
my $op       = $input->param('op');
$tagfield =~ s/\,//g;

if ($op) {
    $template->param(
        script_name   => $script_name,
        tagfield      => $tagfield,
        frameworkcode => $frameworkcode,
        $op           => 1
    );    # we show only the TMPL_VAR names $op
}
else {
    $template->param(
        script_name   => $script_name,
        tagfield      => $tagfield,
        frameworkcode => $frameworkcode,
        else          => 1
    );    # we show only the TMPL_VAR names $op
}

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {
    my $data;
    my $dbh            = C4::Context->dbh;
    my $more_subfields = $input->param("more_subfields") + 1;

    # builds kohafield tables
    my @kohafields;
    push @kohafields, "";
    my $sth2 = $dbh->prepare("SHOW COLUMNS from biblio");
    $sth2->execute;
    while ( ( my $field ) = $sth2->fetchrow_array ) {
        push @kohafields, "biblio." . $field;
    }
    $sth2 = $dbh->prepare("SHOW COLUMNS from biblioitems");
    $sth2->execute;
    while ( ( my $field ) = $sth2->fetchrow_array ) {
        if ( $field eq 'notes' ) { $field = 'bnotes'; }
        push @kohafields, "biblioitems." . $field;
    }
    $sth2 = $dbh->prepare("SHOW COLUMNS from items");
    $sth2->execute;
    while ( ( my $field ) = $sth2->fetchrow_array ) {
        push @kohafields, "items." . $field;
    }

    # build authorised value list
    $sth2->finish;
    $sth2 = $dbh->prepare("select distinct category from authorised_values");
    $sth2->execute;
    my @authorised_values;
    push @authorised_values, "";
    while ( ( my $category ) = $sth2->fetchrow_array ) {
        push @authorised_values, $category;
    }
    push( @authorised_values, "branches" );
    push( @authorised_values, "itemtypes" );
    push( @authorised_values, "cn_source" );

    # build thesaurus categories list
    $sth2->finish;
    $sth2 = $dbh->prepare("select authtypecode from auth_types");
    $sth2->execute;
    my @authtypes;
    push @authtypes, "";
    while ( ( my $authtypecode ) = $sth2->fetchrow_array ) {
        push @authtypes, $authtypecode;
    }

    # build value_builder list
    my @value_builder = ('');

    # read value_builder directory.
    # 2 cases here : on CVS install, $cgidir does not need a /cgi-bin
    # on a standard install, /cgi-bin need to be added.
    # test one, then the other
    my $cgidir = C4::Context->intranetdir . "/cgi-bin";
    unless ( opendir( DIR, "$cgidir/cataloguing/value_builder" ) ) {
        $cgidir = C4::Context->intranetdir;
        opendir( DIR, "$cgidir/cataloguing/value_builder" )
          || die "can't opendir $cgidir/value_builder: $!";
    }
    while ( my $line = readdir(DIR) ) {
        if ( $line =~ /\.pl$/ ) {
            push( @value_builder, $line );
        }
    }
    @value_builder= sort {$a cmp $b} @value_builder;
    closedir DIR;

    # build values list
    my $sth =
      $dbh->prepare(
"select * from marc_subfield_structure where tagfield=? and frameworkcode=?"
      );    # and tagsubfield='$tagsubfield'");
    $sth->execute( $tagfield, $frameworkcode );
    my @loop_data = ();
    my $i         = 0;
    while ( $data = $sth->fetchrow_hashref ) {
        my %row_data;    # get a fresh hash for the row data
        $row_data{defaultvalue} = $data->{defaultvalue};
        $row_data{tab} = CGI::scrolling_list(
            -name   => 'tab',
            -id     => "tab$i",
            -values =>
              [ '-1', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' ],
            -labels => {
                '-1' => 'ignore',
                '0'  => '0',
                '1'  => '1',
                '2'  => '2',
                '3'  => '3',
                '4'  => '4',
                '5'  => '5',
                '6'  => '6',
                '7'  => '7',
                '8'  => '8',
                '9'  => '9',
                '10' => 'items (10)',
            },
            -default  => $data->{'tab'},
            -size     => 1,
            -multiple => 0,
        );
        $row_data{tagsubfield} =
            $data->{'tagsubfield'}
          . "<input type=\"hidden\" name=\"tagsubfield\" value=\""
          . $data->{'tagsubfield'}
          . "\" id=\"tagsubfield\" />";
        $row_data{subfieldcode} = $data->{'tagsubfield'} eq '@'?'_':$data->{'tagsubfield'};
        $row_data{urisubfieldcode} = $row_data{subfieldcode} eq '%' ? 'pct' : $row_data{subfieldcode};
        $row_data{liblibrarian} = CGI::escapeHTML( $data->{'liblibrarian'} );
        $row_data{libopac}      = CGI::escapeHTML( $data->{'libopac'} );
        $row_data{seealso}      = CGI::escapeHTML( $data->{'seealso'} );
        $row_data{kohafield}    = CGI::scrolling_list(
            -name     => "kohafield",
            -id       => "kohafield$i",
            -values   => \@kohafields,
            -default  => "$data->{'kohafield'}",
            -size     => 1,
            -multiple => 0,
        );
        $row_data{authorised_value} = CGI::scrolling_list(
            -name     => "authorised_value",
            -id       => "authorised_value$i",
            -values   => \@authorised_values,
            -default  => $data->{'authorised_value'},
            -size     => 1,
            -multiple => 0,
        );
        $row_data{value_builder} = CGI::scrolling_list(
            -name     => "value_builder",
            -id       => "value_builder$i",
            -values   => \@value_builder,
            -default  => $data->{'value_builder'},
            -size     => 1,
            -multiple => 0,
        );
        $row_data{authtypes} = CGI::scrolling_list(
            -name     => "authtypecode",
            -id       => "authtypecode$i",
            -values   => \@authtypes,
            -default  => $data->{'authtypecode'},
            -size     => 1,
            -multiple => 0,
        );
        $row_data{repeatable} = CGI::checkbox(
            -name     => "repeatable$i",
            -checked  => $data->{'repeatable'} ? 'checked' : '',
            -value    => 1,
            -label    => '',
            -id       => "repeatable$i"
        );
        $row_data{mandatory} = CGI::checkbox(
            -name     => "mandatory$i",
            -checked  => $data->{'mandatory'} ? 'checked' : '',
            -value    => 1,
            -label    => '',
            -id       => "mandatory$i"
        );
        $row_data{hidden} = CGI::escapeHTML( $data->{hidden} );
        $row_data{isurl}  = CGI::checkbox(
            -name     => "isurl$i",
            -id       => "isurl$i",
            -checked  => $data->{'isurl'} ? 'checked' : '',
            -value    => 1,
            -label    => ''
        );
        $row_data{row}    = $i;
        $row_data{link}   = CGI::escapeHTML( $data->{'link'} ); 
        push( @loop_data, \%row_data );
        $i++;
    }

    # add more_subfields empty lines for add if needed
    for ( my $j = 1 ; $j <= 1 ; $j++ ) {
        my %row_data;    # get a fresh hash for the row data
        $row_data{'new_subfield'} = 1;
        $row_data{'subfieldcode'} = '';

        $row_data{tab} = CGI::scrolling_list(
            -name   => 'tab',
            -id     => "tab$j",
            -values =>
              [ '-1', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' ],
            -labels => {
                '-1' => 'ignore',
                '0'  => '0',
                '1'  => '1',
                '2'  => '2',
                '3'  => '3',
                '4'  => '4',
                '5'  => '5',
                '6'  => '6',
                '7'  => '7',
                '8'  => '8',
                '9'  => '9',
                '10' => 'items (10)',
            },
            -default  => "",
            -size     => 1,
            -multiple => 0,
        );
        $row_data{tagsubfield} =
            "<input type=\"text\" name=\"tagsubfield\" value=\""
          . $data->{'tagsubfield'}
          . "\" size=\"1\" id=\"tagsubfield\" maxlength=\"1\" />";
        $row_data{liblibrarian} = "";
        $row_data{libopac}      = "";
        $row_data{seealso}      = "";
        $row_data{kohafield}    = CGI::scrolling_list(
            -name     => 'kohafield',
            -id       => "kohafield$j",
            -values   => \@kohafields,
            -default  => "",
            -size     => 1,
            -multiple => 0,
        );
        $row_data{hidden}     = "";
        $row_data{repeatable} = CGI::checkbox(
            -name     => "repeatable$j",
            -id       => "repeatable$j",
            -checked  => '',
            -value    => 1,
            -label    => ''
        );
        $row_data{mandatory} = CGI::checkbox(
            -name     => "mandatory$j",
            -id       => "mandatory$j",
            -checked  => '',
            -value    => 1,
            -label    => ''
        );
        $row_data{isurl} = CGI::checkbox(
            -name     => "isurl$j",
            -id       => "isurl$j",
            -checked  => '',
            -value    => 1,
            -label    => ''
        );
        $row_data{value_builder} = CGI::scrolling_list(
            -name     => "value_builder",
            -id       => "value_builder$j",
            -values   => \@value_builder,
            -default  => $data->{'value_builder'},
            -size     => 1,
            -multiple => 0,
        );
        $row_data{authorised_value} = CGI::scrolling_list(
            -name     => "authorised_value",
            -id       => "authorised_value$j",
            -values   => \@authorised_values,
            -size     => 1,
            -multiple => 0,
        );
        $row_data{authtypes} = CGI::scrolling_list(
            -name     => "authtypecode",
            -id       => "authtypecode$j",
            -values   => \@authtypes,
            -size     => 1,
            -multiple => 0,
        );
        $row_data{link}   = CGI::escapeHTML( $data->{'link'} );
        $row_data{row}    = $j;
        push( @loop_data, \%row_data );
    }
    $template->param( 'use-heading-flags-p'      => 1 );
    $template->param( 'heading-edit-subfields-p' => 1 );
    $template->param(
        action   => "Edit subfields",
        tagfield => $tagfield,
        loop           => \@loop_data,
        more_subfields => $more_subfields,
        more_tag       => $tagfield
    );

    # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
}
elsif ( $op eq 'add_validate' ) {
    my $dbh = C4::Context->dbh;
    $template->param( tagfield => "$input->param('tagfield')" );
#     my $sth = $dbh->prepare(
# "replace marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,seealso,authorised_value,authtypecode,value_builder,hidden,isurl,frameworkcode, link,defaultvalue)
#                                     values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
#     );
    my $sth_insert = $dbh->prepare(qq{
        insert into marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,seealso,authorised_value,authtypecode,value_builder,hidden,isurl,frameworkcode, link,defaultvalue)
        values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    });
    my $sth_update = $dbh->prepare(qq{
        update marc_subfield_structure set tagfield=?, tagsubfield=?, liblibrarian=?, libopac=?, repeatable=?, mandatory=?, kohafield=?, tab=?, seealso=?, authorised_value=?, authtypecode=?, value_builder=?, hidden=?, isurl=?, frameworkcode=?,  link=?, defaultvalue=?
        where tagfield=? and tagsubfield=? and frameworkcode=?
    });
    my @tagsubfield       = $input->param('tagsubfield');
    my @liblibrarian      = $input->param('liblibrarian');
    my @libopac           = $input->param('libopac');
    my @kohafield         = $input->param('kohafield');
    my @tab               = $input->param('tab');
    my @seealso           = $input->param('seealso');
    my @hidden            = $input->param('hidden');
    my @authorised_values = $input->param('authorised_value');
    my @authtypecodes     = $input->param('authtypecode');
    my @value_builder     = $input->param('value_builder');
    my @link              = $input->param('link');
    my @defaultvalue      = $input->param('defaultvalue');
    
    for ( my $i = 0 ; $i <= $#tagsubfield ; $i++ ) {
        my $tagfield    = $input->param('tagfield');
        my $tagsubfield = $tagsubfield[$i];
        $tagsubfield = "@" unless $tagsubfield ne '';
        $tagsubfield = "@" if $tagsubfield eq '_';
        my $liblibrarian     = $liblibrarian[$i];
        my $libopac          = $libopac[$i];
        my $repeatable       = $input->param("repeatable$i") ? 1 : 0;
        my $mandatory        = $input->param("mandatory$i") ? 1 : 0;
        my $kohafield        = $kohafield[$i];
        my $tab              = $tab[$i];
        my $seealso          = $seealso[$i];
        my $authorised_value = $authorised_values[$i];
        my $authtypecode     = $authtypecodes[$i];
        my $value_builder    = $value_builder[$i];
        my $hidden = $hidden[$i];                     #input->param("hidden$i");
        my $isurl  = $input->param("isurl$i") ? 1 : 0;
        my $link   = $link[$i];
        my $defaultvalue = $defaultvalue[$i];
        
        if ($liblibrarian) {
            unless ( C4::Context->config('demo') eq 1 ) {
                if (marc_subfield_structure_exists($tagfield, $tagsubfield, $frameworkcode)) {
                    $sth_update->execute(
                        $tagfield,
                        $tagsubfield,
                        $liblibrarian,
                        $libopac,
                        $repeatable,
                        $mandatory,
                        $kohafield,
                        $tab,
                        $seealso,
                        $authorised_value,
                        $authtypecode,
                        $value_builder,
                        $hidden,
                        $isurl,
                        $frameworkcode,
                        $link,
                        $defaultvalue,
                        (
                            $tagfield,
                            $tagsubfield,
                            $frameworkcode,
                        ),
                    );
                } else {
                    $sth_insert->execute(
                        $tagfield,
                        $tagsubfield,
                        $liblibrarian,
                        $libopac,
                        $repeatable,
                        $mandatory,
                        $kohafield,
                        $tab,
                        $seealso,
                        $authorised_value,
                        $authtypecode,
                        $value_builder,
                        $hidden,
                        $isurl,
                        $frameworkcode,
                        $link,
                        $defaultvalue,
                    );
                }
            }
        }
    }
    $sth_insert->finish;
    $sth_update->finish;
    print
"Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=marc_subfields_structure.pl?tagfield=$tagfield&frameworkcode=$frameworkcode\"></html>";
    exit;

    # END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
"select * from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?"
      );

    $sth->execute( $tagfield, $tagsubfield, $frameworkcode );
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    $template->param(
        liblibrarian  => $data->{'liblibrarian'},
        tagsubfield   => $data->{'tagsubfield'},
        delete_link   => $script_name,
        tagfield      => $tagfield,
        tagsubfield   => $tagsubfield,
        frameworkcode => $frameworkcode,
    );

    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
  # called by delete_confirm, used to effectively confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirmed' ) {
    my $dbh = C4::Context->dbh;
    unless ( C4::Context->config('demo') eq 1 ) {
        my $sth =
          $dbh->prepare(
"delete from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?"
          );
        $sth->execute( $tagfield, $tagsubfield, $frameworkcode );
        $sth->finish;
    }
    print
"Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=marc_subfields_structure.pl?tagfield=$tagfield&frameworkcode=$frameworkcode\"></html>";
    exit;
    $template->param( tagfield => $tagfield );

    # END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
}
else {    # DEFAULT
    my ( $count, $results ) = string_search( $tagfield, $frameworkcode );
    my @loop_data = ();
    for (
        my $i = $offset ;
        $i < ( $offset + $pagesize < $count ? $offset + $pagesize : $count ) ;
        $i++
      )
    {
        my %row_data;    # get a fresh hash for the row data
        $row_data{tagfield}         = $results->[$i]{'tagfield'};
        $row_data{tagsubfield}      = $results->[$i]{'tagsubfield'};
        $row_data{liblibrarian}     = $results->[$i]{'liblibrarian'};
        $row_data{kohafield}        = $results->[$i]{'kohafield'};
        $row_data{repeatable}       = $results->[$i]{'repeatable'};
        $row_data{mandatory}        = $results->[$i]{'mandatory'};
        $row_data{tab}              = $results->[$i]{'tab'};
        $row_data{seealso}          = $results->[$i]{'seealso'};
        $row_data{authorised_value} = $results->[$i]{'authorised_value'};
        $row_data{authtypecode}     = $results->[$i]{'authtypecode'};
        $row_data{value_builder}    = $results->[$i]{'value_builder'};
        $row_data{hidden}           = $results->[$i]{'hidden'};
        $row_data{isurl}            = $results->[$i]{'isurl'};
        $row_data{link}             = $results->[$i]{'link'};
        $row_data{delete}           =
"$script_name?op=delete_confirm&amp;tagfield=$tagfield&amp;tagsubfield="
          . $results->[$i]{'tagsubfield'}
          . "&amp;frameworkcode=$frameworkcode";

        if ( $row_data{tab} eq -1 ) {
            $row_data{subfield_ignored} = 1;
        }

        push( @loop_data, \%row_data );
    }
    $template->param( loop => \@loop_data );
    $template->param(
        edit_tagfield      => $tagfield,
        edit_frameworkcode => $frameworkcode
    );

    if ( $offset > 0 ) {
        my $prevpage = $offset - $pagesize;
        $template->param(
            prev => "<a href=\"$script_name?offset=$prevpage\&tagfield=$tagfield\&frameworkcode=$frameworkcode \">" );
    }
    if ( $offset + $pagesize < $count ) {
        my $nextpage = $offset + $pagesize;
        $template->param(
            next => "<a href=\"$script_name?offset=$nextpage\&tagfield=$tagfield\&frameworkcode=$frameworkcode \">" );
    }
}    #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
