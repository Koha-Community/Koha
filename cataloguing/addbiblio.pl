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
use C4::Auth;
use C4::Biblio;
use C4::Search;
use C4::AuthoritiesMarc;
use C4::Context;
use MARC::Record;
use C4::Log;
use C4::Koha;    # XXX subfield_is_koha_internal_p
use C4::Branch;    # XXX subfield_is_koha_internal_p
use C4::ClassSource;
use C4::ImportBatch;
use C4::Charset;

use Date::Calc qw(Today);
use MARC::File::USMARC;
use MARC::File::XML;

if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
    MARC::File::XML->default_record_format('UNIMARC');
}

our($tagslib,$authorised_values_sth,$is_a_modif,$usedTagsLib,$mandatory_z3950);

=item MARCfindbreeding

    $record = MARCfindbreeding($breedingid);

Look up the import record repository for the record with
record with id $breedingid.  If found, returns the decoded
MARC::Record; otherwise, -1 is returned (FIXME).
Returns as second parameter the character encoding.

=cut

sub MARCfindbreeding {
    my ( $id ) = @_;
    my ($marc, $encoding) = GetImportRecordMarc($id);
    # remove the - in isbn, koha store isbn without any -
    if ($marc) {
        my $record = MARC::Record->new_from_usmarc($marc);
        my ($isbnfield,$isbnsubfield) = GetMarcFromKohaField('biblioitems.isbn','');
        if ( $record->field($isbnfield) ) {
            foreach my $field ( $record->field($isbnfield) ) {
                foreach my $subfield ( $field->subfield($isbnsubfield) ) {
                    my $newisbn = $field->subfield($isbnsubfield);
                    $newisbn =~ s/-//g;
                    $field->update( $isbnsubfield => $newisbn );
                }
            }
        }
        # fix the unimarc 100 coded field (with unicode information)
        if (C4::Context->preference('marcflavour') eq 'UNIMARC' && $record->subfield(100,'a')) {
            my $f100a=$record->subfield(100,'a');
            my $f100 = $record->field(100);
            my $f100temp = $f100->as_string;
            $record->delete_field($f100);
            if ( length($f100temp) > 28 ) {
                substr( $f100temp, 26, 2, "50" );
                $f100->update( 'a' => $f100temp );
                my $f100 = MARC::Field->new( '100', '', '', 'a' => $f100temp );
                $record->insert_fields_ordered($f100);
            }
        }
		
        if ( !defined(ref($record)) ) {
            return -1;
        }
        else {
            # normalize author : probably UNIMARC specific...
            if (    C4::Context->preference("z3950NormalizeAuthor")
                and C4::Context->preference("z3950AuthorAuthFields") )
            {
                my ( $tag, $subfield ) = GetMarcFromKohaField("biblio.author", '');

 #                 my $summary = C4::Context->preference("z3950authortemplate");
                my $auth_fields =
                  C4::Context->preference("z3950AuthorAuthFields");
                my @auth_fields = split /,/, $auth_fields;
                my $field;

                if ( $record->field($tag) ) {
                    foreach my $tmpfield ( $record->field($tag)->subfields ) {

       #                        foreach my $subfieldcode ($tmpfield->subfields){
                        my $subfieldcode  = shift @$tmpfield;
                        my $subfieldvalue = shift @$tmpfield;
                        if ($field) {
                            $field->add_subfields(
                                "$subfieldcode" => $subfieldvalue )
                              if ( $subfieldcode ne $subfield );
                        }
                        else {
                            $field =
                              MARC::Field->new( $tag, "", "",
                                $subfieldcode => $subfieldvalue )
                              if ( $subfieldcode ne $subfield );
                        }
                    }
                }
                $record->delete_field( $record->field($tag) );
                foreach my $fieldtag (@auth_fields) {
                    next unless ( $record->field($fieldtag) );
                    my $lastname  = $record->field($fieldtag)->subfield('a');
                    my $firstname = $record->field($fieldtag)->subfield('b');
                    my $title     = $record->field($fieldtag)->subfield('c');
                    my $number    = $record->field($fieldtag)->subfield('d');
                    if ($title) {

#                         $field->add_subfields("$subfield"=>"[ ".ucfirst($title).ucfirst($firstname)." ".$number." ]");
                        $field->add_subfields(
                                "$subfield" => ucfirst($title) . " "
                              . ucfirst($firstname) . " "
                              . $number );
                    }
                    else {

#                       $field->add_subfields("$subfield"=>"[ ".ucfirst($firstname).", ".ucfirst($lastname)." ]");
                        $field->add_subfields(
                            "$subfield" => ucfirst($firstname) . ", "
                              . ucfirst($lastname) );
                    }
                }
                $record->insert_fields_ordered($field);
            }
            return $record, $encoding;
        }
    }
    return -1;
}

=item build_authorized_values_list

=cut

sub build_authorized_values_list ($$$$$$$) {
    my ( $tag, $subfield, $value, $dbh, $authorised_values_sth,$index_tag,$index_subfield ) = @_;

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
        #Use GetBranches($onlymine)
        my $onlymine=C4::Context->preference('IndependantBranches') && 
                C4::Context->userenv && 
                C4::Context->userenv->{flags}!=1 && 
                C4::Context->userenv->{branch};
        my $branches = GetBranches($onlymine);
        my @branchloop;
        foreach my $thisbranch ( sort keys %$branches ) {
            push @authorised_values, $thisbranch;
            $authorised_lib{$thisbranch} = $branches->{$thisbranch}->{'branchname'};
        }

        #----- itemtypes
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes" ) {
        my $sth =
          $dbh->prepare(
            "select itemtype,description from itemtypes order by description");
        $sth->execute;
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
          
        my $itemtype;
        
        while ( my ( $itemtype, $description ) = $sth->fetchrow_array ) {
            push @authorised_values, $itemtype;
            $authorised_lib{$itemtype} = $description;
        }
        $value = $itemtype unless ($value);

          #---- class_sources
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "cn_source" ) {
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );

        my $class_sources = GetClassSources();

        my $default_source = C4::Context->preference("DefaultClassificationSource");

        foreach my $class_source (sort keys %$class_sources) {
            next unless $class_sources->{$class_source}->{'used'} or
                        ($value and $class_source eq $value) or
                        ($class_source eq $default_source);
            push @authorised_values, $class_source;
            $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
            $value = $class_source unless ($value);
            $value = $default_source unless ($value);
        }
        #---- "true" authorised value
    }
    else {
        $authorised_values_sth->execute(
            $tagslib->{$tag}->{$subfield}->{authorised_value} );

        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );

        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
            push @authorised_values, $value;
            $authorised_lib{$value} = $lib;
        }
    }
    return CGI::scrolling_list(
        -name     => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        -values   => \@authorised_values,
        -default  => $value,
        -labels   => \%authorised_lib,
        -override => 1,
        -size     => 1,
        -multiple => 0,
        -tabindex => 1,
        -id       => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        -class    => "input_marceditor",
    );
}

=item CreateKey

    Create a random value to set it into the input name

=cut

sub CreateKey(){
    return int(rand(1000000));
}

=item GetMandatoryFieldZ3950

    This function return an hashref which containts all mandatory field
    to search with z3950 server.
    
=cut

sub GetMandatoryFieldZ3950($){
    my $frameworkcode = shift;
    my @isbn   = GetMarcFromKohaField('biblioitems.isbn',$frameworkcode);
    my @title  = GetMarcFromKohaField('biblio.title',$frameworkcode);
    my @author = GetMarcFromKohaField('biblio.author',$frameworkcode);
    my @issn   = GetMarcFromKohaField('biblioitems.issn',$frameworkcode);
    my @lccn   = GetMarcFromKohaField('biblioitems.lccn',$frameworkcode);
    
    return {
        $isbn[0].$isbn[1]     => 'isbn',
        $title[0].$title[1]   => 'title',
        $author[0].$author[1] => 'author',
        $issn[0].$issn[1]     => 'issn',
        $lccn[0].$lccn[1]     => 'lccn',
    };
}

=item create_input

 builds the <input ...> entry for a subfield.

=cut

sub create_input {
    my ( $tag, $subfield, $value, $index_tag, $tabloop, $rec, $authorised_values_sth,$cgi ) = @_;
    
    my $index_subfield = CreateKey(); # create a specifique key for each subfield

    $value =~ s/"/&quot;/g;

    # determine maximum length; 9999 bytes per ISO 2709 except for leader and MARC21 008
    my $max_length = 9999;
    if ($tag eq '000') {
        $max_length = 24;
    } elsif ($tag eq '008' and C4::Context->preference('marcflavour') eq 'MARC21')  {
        $max_length = 40;
    }

    # if there is no value provided but a default value in parameters, get it
    unless ($value) {
        $value = $tagslib->{$tag}->{$subfield}->{defaultvalue};

        # get today date & replace YYYY, MM, DD if provided in the default value
        my ( $year, $month, $day ) = Today();
        $month = sprintf( "%02d", $month );
        $day   = sprintf( "%02d", $day );
        $value =~ s/YYYY/$year/g;
        $value =~ s/MM/$month/g;
        $value =~ s/DD/$day/g;
    }
    my $dbh = C4::Context->dbh;

    # map '@' as "subfield" label for fixed fields
    # to something that's allowed in a div id.
    my $id_subfield = $subfield;
    $id_subfield = "00" if $id_subfield eq "@";

    my %subfield_data = (
        tag        => $tag,
        subfield   => $id_subfield,
        marc_lib   => substr( $tagslib->{$tag}->{$subfield}->{lib}, 0, 22 ),
        marc_lib_plain => $tagslib->{$tag}->{$subfield}->{lib}, 
        tag_mandatory  => $tagslib->{$tag}->{mandatory},
        mandatory      => $tagslib->{$tag}->{$subfield}->{mandatory},
        repeatable     => $tagslib->{$tag}->{$subfield}->{repeatable},
        kohafield      => $tagslib->{$tag}->{$subfield}->{kohafield},
        index          => $index_tag,
        id             => "tag_".$tag."_subfield_".$id_subfield."_".$index_tag."_".$index_subfield,
        value          => $value,
        random         => CreateKey(),
    );

    if(exists $mandatory_z3950->{$tag.$subfield}){
        $subfield_data{z3950_mandatory} = $mandatory_z3950->{$tag.$subfield};
    }
    # decide if the subfield must be expanded (visible) by default or not
    # if it is mandatory, then expand. If it is hidden explicitly by the hidden flag, hidden anyway
    $subfield_data{visibility} = "display:none;"
        if (    ($tagslib->{$tag}->{$subfield}->{hidden} % 2 == 1) and $value ne ''
            or ($value eq '' and !$tagslib->{$tag}->{$subfield}->{mandatory})
        );
    # always expand all subfields of a mandatory field
    $subfield_data{visibility} = "" if $tagslib->{$tag}->{mandatory};
    # it's an authorised field
    if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
        $subfield_data{marc_value} =
          build_authorized_values_list( $tag, $subfield, $value, $dbh,
            $authorised_values_sth,$index_tag,$index_subfield );

    # it's a subfield $9 linking to an authority record - see bug 2206
    }
    elsif ($subfield eq "9" and
           exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
           defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
           $tagslib->{$tag}->{'a'}->{authtypecode} ne '') {

        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    value=\"$value\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"5\"
                    maxlength=\"$max_length\"
                    readonly=\"readonly\"
                    \/>";

    # it's a thesaurus / authority field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authtypecode} ) {
     if (C4::Context->preference("BiblioAddsAuthorities")) {
        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    value=\"$value\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"67\"
                    maxlength=\"$max_length\"
                    \/>
                    <a href=\"#\" class=\"buttonDot\"
                        onclick=\"Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&amp;index=$subfield_data{id}','$subfield_data{id}'); return false;\" title=\"Tag Editor\">...</a>
            ";
      } else {
        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    value=\"$value\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"67\"
                    maxlength=\"$max_length\"
                    readonly=\"readonly\"
                    \/><a href=\"#\" class=\"buttonDot\"
                        onclick=\"openAuth('".$subfield_data{id}."','".$tagslib->{$tag}->{$subfield}->{authtypecode}."'); return false;\" title=\"Tag Editor\">...</a>
            ";
      }
    # it's a plugin field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) {

        # opening plugin. Just check wether we are on a developper computer on a production one
        # (the cgidir differs)
        my $cgidir = C4::Context->intranetdir . "/cgi-bin/cataloguing/value_builder";
        unless ( opendir( DIR, "$cgidir" ) ) {
            $cgidir = C4::Context->intranetdir . "/cataloguing/value_builder";
            closedir( DIR );
        }
        my $plugin = $cgidir . "/" . $tagslib->{$tag}->{$subfield}->{'value_builder'};
        if (do $plugin) {
            my $extended_param = plugin_parameters( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
            my ( $function_name, $javascript ) = plugin_javascript( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
        
            $subfield_data{marc_value} =
                    "<input tabindex=\"1\"
                            type=\"text\"
                            id=\"".$subfield_data{id}."\"
                            name=\"".$subfield_data{id}."\"
                            value=\"$value\"
                            class=\"input_marceditor\"
                            onfocus=\"Focus$function_name($index_tag)\"
                            size=\"67\"
                            maxlength=\"$max_length\"
                            onblur=\"Blur$function_name($index_tag); \" \/>
                            <a href=\"#\" class=\"buttonDot\" onclick=\"Clic$function_name('$subfield_data{id}'); return false;\" title=\"Tag Editor\">...</a>
                    $javascript";
        } else {
            warn "Plugin Failed: $plugin";
            # supply default input form
            $subfield_data{marc_value} =
                "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"".$subfield_data{id}."\"
                        value=\"$value\"
                        tabindex=\"1\"
                        size=\"67\"
                        maxlength=\"$max_length\"
                        class=\"input_marceditor\"
                \/>
                ";
        }
        # it's an hidden field
    }
    elsif ( $tag eq '' ) {
        $subfield_data{marc_value} =
            "<input tabindex=\"1\"
                    type=\"hidden\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    size=\"67\"
                    maxlength=\"$max_length\"
                    value=\"$value\" \/>
            ";
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'hidden'} ) {
        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"".$subfield_data{id}."\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"67\"
                    maxlength=\"$max_length\"
                    value=\"$value\"
            \/>";

        # it's a standard field
    }
    else {
        if (
            length($value) > 100
            or
            ( C4::Context->preference("marcflavour") eq "UNIMARC" && $tag >= 300
                and $tag < 400 && $subfield eq 'a' )
            or (    $tag >= 500
                and $tag < 600
                && C4::Context->preference("marcflavour") eq "MARC21" )
          )
        {
            $subfield_data{marc_value} =
                "<textarea cols=\"70\"
                           rows=\"4\"
                           id=\"".$subfield_data{id}."\"
                           name=\"".$subfield_data{id}."\"
                           class=\"input_marceditor\"
                           tabindex=\"1\"
                           >$value</textarea>
                ";
        }
        else {
            $subfield_data{marc_value} =
                "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"".$subfield_data{id}."\"
                        value=\"$value\"
                        tabindex=\"1\"
                        size=\"67\"
                        maxlength=\"$max_length\"
                        class=\"input_marceditor\"
                \/>
                ";
        }
    }
    $subfield_data{'index_subfield'} = $index_subfield;
    return \%subfield_data;
}


=item format_indicator

Translate indicator value for output form - specifically, map
indicator = ' ' to ''.  This is for the convenience of a cataloger
using a mouse to select an indicator input.

=cut

sub format_indicator {
    my $ind_value = shift;
    return '' if not defined $ind_value;
    return '' if $ind_value eq ' ';
    return $ind_value;
}

sub build_tabs ($$$$$) {
    my ( $template, $record, $dbh, $encoding,$input ) = @_;

    # fill arrays
    my @loop_data = ();
    my $tag;

    my $authorised_values_sth = $dbh->prepare(
        "select authorised_value,lib
        from authorised_values
        where category=? order by lib"
    );
    
    # in this array, we will push all the 10 tabs
    # to avoid having 10 tabs in the template : they will all be in the same BIG_LOOP
    my @BIG_LOOP;
    my %seen;
    my @tab_data; # all tags to display
    
    foreach my $used ( @$usedTagsLib ){
        push @tab_data,$used->{tagfield} if not $seen{$used->{tagfield}};
        $seen{$used->{tagfield}}++;
    }
        
    my $max_num_tab=-1;
    foreach(@$usedTagsLib){
        if($_->{tab} > -1 && $_->{tab} >= $max_num_tab && $_->{tagfield} != '995'){ # FIXME : MARC21 ?
            $max_num_tab = $_->{tab}; 
        }
    }
    if($max_num_tab >= 9){
        $max_num_tab = 9;
    }
    # loop through each tab 0 through 9
    for ( my $tabloop = 0 ; $tabloop <= $max_num_tab ; $tabloop++ ) {
        my @loop_data = (); #innerloop in the template.
        my $i = 0;
        foreach my $tag (@tab_data) {
            $i++;
            next if ! $tag;
            my ($indicator1, $indicator2);
            my $index_tag = CreateKey;

            # if MARC::Record is not empty =>use it as master loop, then add missing subfields that should be in the tab.
            # if MARC::Record is empty => use tab as master loop.
            if ( $record ne -1 && ( $record->field($tag) || $tag eq '000' ) ) {
                my @fields;
		if ( $tag ne '000' ) {
                    @fields = $record->field($tag);
		}
		else {
		   push @fields, $record->leader(); # if tag == 000
		}
		# loop through each field
                foreach my $field (@fields) {
                    
                    my @subfields_data;
                    if ( $tag < 10 ) {
                        my ( $value, $subfield );
                        if ( $tag ne '000' ) {
                            $value    = $field->data();
                            $subfield = "@";
                        }
                        else {
                            $value    = $field;
                            $subfield = '@';
                        }
                        next if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                        next
                          if ( $tagslib->{$tag}->{$subfield}->{kohafield} eq
                            'biblio.biblionumber' );
                        push(
                            @subfields_data,
                            &create_input(
                                $tag, $subfield, $value, $index_tag, $tabloop, $record,
                                $authorised_values_sth,$input
                            )
                        );
                    }
                    else {
                        my @subfields = $field->subfields();
                        foreach my $subfieldcount ( 0 .. $#subfields ) {
                            my $subfield = $subfields[$subfieldcount][0];
                            my $value    = $subfields[$subfieldcount][1];
                            next if ( length $subfield != 1 );
                            next if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                            push(
                                @subfields_data,
                                &create_input(
                                    $tag, $subfield, $value, $index_tag, $tabloop,
                                    $record, $authorised_values_sth,$input
                                )
                            );
                        }
                    }

                    # now, loop again to add parameter subfield that are not in the MARC::Record
                    foreach my $subfield ( sort( keys %{ $tagslib->{$tag} } ) )
                    {
                        next if ( length $subfield != 1 );
                        next if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                        next if ( $tag < 10 );
                        next
                          if ( ( $tagslib->{$tag}->{$subfield}->{hidden} <= -4 )
                            or ( $tagslib->{$tag}->{$subfield}->{hidden} >= 5 ) )
                            and not ( $subfield eq "9" and
                                      exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                      defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                      $tagslib->{$tag}->{'a'}->{authtypecode} ne ""
                                    )
                          ;    #check for visibility flag
                               # if subfield is $9 in a field whose $a is authority-controlled,
                               # always include in the form regardless of the hidden setting - bug 2206
                        next if ( defined( $field->subfield($subfield) ) );
                        push(
                            @subfields_data,
                            &create_input(
                                $tag, $subfield, '', $index_tag, $tabloop, $record,
                                $authorised_values_sth,$input
                            )
                        );
                    }
                    if ( $#subfields_data >= 0 ) {
                        # build the tag entry.
                        # note that the random() field is mandatory. Otherwise, on repeated fields, you'll 
                        # have twice the same "name" value, and cgi->param() will return only one, making
                        # all subfields to be merged in a single field.
                        my %tag_data = (
                            tag           => $tag,
                            index         => $index_tag,
                            tag_lib       => $tagslib->{$tag}->{lib},
                            repeatable       => $tagslib->{$tag}->{repeatable},
                            mandatory       => $tagslib->{$tag}->{mandatory},
                            subfield_loop => \@subfields_data,
                            fixedfield    => $tag < 10?1:0,
                            random        => CreateKey,
                        );
                        if ($tag >= 010){ # no indicator for theses tag
                           $tag_data{indicator1} = format_indicator($field->indicator(1)),
                           $tag_data{indicator2} = format_indicator($field->indicator(2)),
                        }
                        push( @loop_data, \%tag_data );
                    }
                 } # foreach $field end

            # if breeding is empty
            }
            else {
                my @subfields_data;
                foreach my $subfield ( sort( keys %{ $tagslib->{$tag} } ) ) {
                    next if ( length $subfield != 1 );
                    next
                      if ( ( $tagslib->{$tag}->{$subfield}->{hidden} <= -5 )
                        or ( $tagslib->{$tag}->{$subfield}->{hidden} >= 4 ) )
                      and not ( $subfield eq "9" and
                                exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                $tagslib->{$tag}->{'a'}->{authtypecode} ne ""
                              )
                      ;    #check for visibility flag
                           # if subfield is $9 in a field whose $a is authority-controlled,
                           # always include in the form regardless of the hidden setting - bug 2206
                    next
                      if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                    push(
                        @subfields_data,
                        &create_input(
                            $tag, $subfield, '', $index_tag, $tabloop, $record,
                            $authorised_values_sth,$input
                        )
                    );
                }
                if ( $#subfields_data >= 0 ) {
                    my %tag_data = (
                        tag              => $tag,
                        index            => $index_tag,
                        tag_lib          => $tagslib->{$tag}->{lib},
                        repeatable       => $tagslib->{$tag}->{repeatable},
                        mandatory       => $tagslib->{$tag}->{mandatory},
                        indicator1       => $indicator1,
                        indicator2       => $indicator2,
                        subfield_loop    => \@subfields_data,
                        tagfirstsubfield => $subfields_data[0],
                        fixedfield       => $tag < 10?1:0,
                    );
                    
                    push @loop_data, \%tag_data ;
                }
            }
        }
        if ( $#loop_data >= 0 ) {
            push @BIG_LOOP, {
                number    => $tabloop,
                innerloop => \@loop_data,
            };
        }
    }
    $template->param( BIG_LOOP => \@BIG_LOOP );
}

#
# sub that tries to find authorities linked to the biblio
# the sub :
#   - search in the authority DB for the same authid (in $9 of the biblio)
#   - search in the authority DB for the same 001 (in $3 of the biblio in UNIMARC)
#   - search in the authority DB for the same values (exactly) (in all subfields of the biblio)
# if the authority is found, the biblio is modified accordingly to be connected to the authority.
# if the authority is not found, it's added, and the biblio is then modified to be connected to the authority.
#

sub BiblioAddAuthorities{
  my ( $record, $frameworkcode ) = @_;
  my $dbh=C4::Context->dbh;
  my $query=$dbh->prepare(qq|
SELECT authtypecode,tagfield
FROM marc_subfield_structure 
WHERE frameworkcode=? 
AND (authtypecode IS NOT NULL AND authtypecode<>\"\")|);
# SELECT authtypecode,tagfield
# FROM marc_subfield_structure 
# WHERE frameworkcode=? 
# AND (authtypecode IS NOT NULL OR authtypecode<>\"\")|);
  $query->execute($frameworkcode);
  my ($countcreated,$countlinked);
  while (my $data=$query->fetchrow_hashref){
    foreach my $field ($record->field($data->{tagfield})){
      next if ($field->subfield('3')||$field->subfield('9'));
      # No authorities id in the tag.
      # Search if there is any authorities to link to.
      my $query='at='.$data->{authtypecode}.' ';
      map {$query.= ' and he,ext="'.$_->[1].'"' if ($_->[0]=~/[A-z]/)}  $field->subfields();
      my ($error, $results, $total_hits)=SimpleSearch( $query, undef, undef, [ "authorityserver" ] );
    # there is only 1 result 
	  if ( $error ) {
        warn "BIBLIOADDSAUTHORITIES: $error";
	    return (0,0) ;
	  }
      if ($results && scalar(@$results)==1) {
        my $marcrecord = MARC::File::USMARC::decode($results->[0]);
        $field->add_subfields('9'=>$marcrecord->field('001')->data);
        $countlinked++;
      } elsif (scalar(@$results)>1) {
   #More than One result 
   #This can comes out of a lack of a subfield.
#         my $marcrecord = MARC::File::USMARC::decode($results->[0]);
#         $record->field($data->{tagfield})->add_subfields('9'=>$marcrecord->field('001')->data);
  $countlinked++;
      } else {
  #There are no results, build authority record, add it to Authorities, get authid and add it to 9
  ###NOTICE : This is only valid if a subfield is linked to one and only one authtypecode     
  ###NOTICE : This can be a problem. We should also look into other types and rejected forms.
         my $authtypedata=GetAuthType($data->{authtypecode});
         next unless $authtypedata;
         my $marcrecordauth=MARC::Record->new();
         my $authfield=MARC::Field->new($authtypedata->{auth_tag_to_report},'','',"a"=>"".$field->subfield('a'));
         map { $authfield->add_subfields($_->[0]=>$_->[1]) if ($_->[0]=~/[A-z]/ && $_->[0] ne "a" )}  $field->subfields();
         $marcrecordauth->insert_fields_ordered($authfield);

         # bug 2317: ensure new authority knows it's using UTF-8; currently
         # only need to do this for MARC21, as MARC::Record->as_xml_record() handles
         # automatically for UNIMARC (by not transcoding)
         # FIXME: AddAuthority() instead should simply explicitly require that the MARC::Record
         # use UTF-8, but as of 2008-08-05, did not want to introduce that kind
         # of change to a core API just before the 3.0 release.
         if (C4::Context->preference('marcflavour') eq 'MARC21') {
            SetMarcUnicodeFlag($marcrecordauth, 'MARC21');
         }

#          warn "AUTH RECORD ADDED : ".$marcrecordauth->as_formatted;

         my $authid=AddAuthority($marcrecordauth,'',$data->{authtypecode});
         $countcreated++;
         $field->add_subfields('9'=>$authid);
      }
    }  
  }
  return ($countlinked,$countcreated);
}

# ========================
#          MAIN
#=========================
my $input = new CGI;
my $error = $input->param('error');
my $biblionumber  = $input->param('biblionumber'); # if biblionumber exists, it's a modif, not a new biblio.
my $breedingid    = $input->param('breedingid');
my $z3950         = $input->param('z3950');
my $op            = $input->param('op');
my $mode          = $input->param('mode');
my $frameworkcode = $input->param('frameworkcode');
my $dbh           = C4::Context->dbh;

$frameworkcode = &GetFrameworkCode($biblionumber)
  if ( $biblionumber and not($frameworkcode) );

$frameworkcode = '' if ( $frameworkcode eq 'Default' );
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/addbiblio.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
    }
);

# Getting the list of all frameworks
# get framework list
my $frameworks = getframeworks;
my @frameworkcodeloop;
foreach my $thisframeworkcode ( keys %$frameworks ) {
	my %row = (
		value         => $thisframeworkcode,
		frameworktext => $frameworks->{$thisframeworkcode}->{'frameworktext'},
	);
	if ($frameworkcode eq $thisframeworkcode){
		$row{'selected'}="selected=\"selected\"";
		}
	push @frameworkcodeloop, \%row;
} 
$template->param( frameworkcodeloop => \@frameworkcodeloop,
	breedingid => $breedingid );

# ++ Global
$tagslib         = &GetMarcStructure( 1, $frameworkcode );
$usedTagsLib     = &GetUsedMarcStructure( $frameworkcode );
$mandatory_z3950 = GetMandatoryFieldZ3950($frameworkcode);
# -- Global

my $record   = -1;
my $encoding = "";
my (
	$biblionumbertagfield,
	$biblionumbertagsubfield,
	$biblioitemnumtagfield,
	$biblioitemnumtagsubfield,
	$bibitem,
	$biblioitemnumber
);

if (($biblionumber) && !($breedingid)){
	$record = GetMarcBiblio($biblionumber);
}
if ($breedingid) {
    ( $record, $encoding ) = MARCfindbreeding( $breedingid ) ;
}

$is_a_modif = 0;
    
if ($biblionumber) {
    $is_a_modif = 1;
	$template->param( title => $record->title(), );

    # if it's a modif, retrieve bibli and biblioitem numbers for the future modification of old-DB.
    ( $biblionumbertagfield, $biblionumbertagsubfield ) =
	&GetMarcFromKohaField( "biblio.biblionumber", $frameworkcode );
    ( $biblioitemnumtagfield, $biblioitemnumtagsubfield ) =
	&GetMarcFromKohaField( "biblioitems.biblioitemnumber", $frameworkcode );
	    
    # search biblioitems value
    my $sth =  $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblionumber);
    ($biblioitemnumber) = $sth->fetchrow;
}

#-------------------------------------------------------------------------------------
if ( $op eq "addbiblio" ) {
#-------------------------------------------------------------------------------------
    # getting html input
    my @params = $input->param();
    $record = TransformHtmlToMarc( \@params , $input );
    # check for a duplicate
    my ($duplicatebiblionumber,$duplicatetitle) = FindDuplicate($record) if (!$is_a_modif);
    my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
    # it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
    if ( !$duplicatebiblionumber or $confirm_not_duplicate ) {
        my $oldbibnum;
        my $oldbibitemnum;
        if (C4::Context->preference("BiblioAddsAuthorities")){
          my ($countlinked,$countcreated)=BiblioAddAuthorities($record,$frameworkcode);
        } 
        if ( $is_a_modif ) {
            ModBiblioframework( $biblionumber, $frameworkcode ); 
            ModBiblio( $record, $biblionumber, $frameworkcode );
        }
        else {
            ( $biblionumber, $oldbibitemnum ) = AddBiblio( $record, $frameworkcode );
        }

        if ($mode ne "popup"){
            print $input->redirect(
                "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode"
            );
            exit;
        } else {
          $template->param(
            biblionumber => $biblionumber,
            done         =>1,
            popup        =>1
          );
          $template->param( title => $record->subfield('200',"a") ) if ($record ne "-1" && C4::Context->preference('marcflavour') =~/unimarc/i);
          $template->param( title => $record->title() ) if ($record ne "-1" && C4::Context->preference('marcflavour') eq "usmarc");
          $template->param(
            popup => $mode,
            itemtype => $frameworkcode,
          );
          output_html_with_http_headers $input, $cookie, $template->output;
          exit;     
        }
    } else {
    # it may be a duplicate, warn the user and do nothing
        build_tabs ($template, $record, $dbh,$encoding,$input);
        $template->param(
            biblionumber             => $biblionumber,
            biblioitemnumber         => $biblioitemnumber,
            duplicatebiblionumber    => $duplicatebiblionumber,
            duplicatebibid           => $duplicatebiblionumber,
            duplicatetitle           => $duplicatetitle,
        );
    }
}
elsif ( $op eq "delete" ) {
    
    my $error = &DelBiblio($biblionumber);
    if ($error) {
        warn "ERROR when DELETING BIBLIO $biblionumber : $error";
        print "Content-Type: text/html\n\n<html><body><h1>ERROR when DELETING BIBLIO $biblionumber : $error</h1></body></html>";
	exit;
    }
    
    print $input->redirect('/cgi-bin/koha/catalogue/search.pl');
    exit;
    
} else {
   #----------------------------------------------------------------------------
   # If we're in a duplication case, we have to set to "" the biblionumber
   # as we'll save the biblio as a new one.
    if ( $op eq "duplicate" ) {
        $biblionumber = "";
    }

#FIXME: it's kind of silly to go from MARC::Record to MARC::File::XML and then back again just to fix the encoding
    eval {
        my $uxml = $record->as_xml;
        MARC::Record::default_record_format("UNIMARC")
          if ( C4::Context->preference("marcflavour") eq "UNIMARC" );
        my $urecord = MARC::Record::new_from_xml( $uxml, 'UTF-8' );
        $record = $urecord;
    };
    build_tabs( $template, $record, $dbh, $encoding,$input );
    $template->param(
        biblionumber             => $biblionumber,
        biblionumbertagfield        => $biblionumbertagfield,
        biblionumbertagsubfield     => $biblionumbertagsubfield,
        biblioitemnumtagfield    => $biblioitemnumtagfield,
        biblioitemnumtagsubfield => $biblioitemnumtagsubfield,
        biblioitemnumber         => $biblioitemnumber,
    );
}

$template->param( title => $record->title() ) if ( $record ne "-1" );
$template->param(
    popup => $mode,
    frameworkcode => $frameworkcode,
    itemtype => $frameworkcode,
);

output_html_with_http_headers $input, $cookie, $template->output;
