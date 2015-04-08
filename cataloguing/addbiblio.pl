#!/usr/bin/perl 


# Copyright 2000-2002 Katipo Communications
# Copyright 2004-2010 BibLibre
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
#use warnings; FIXME - Bug 2505
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
use URI::Escape;

if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
    MARC::File::XML->default_record_format('UNIMARC');
}

our($tagslib,$authorised_values_sth,$is_a_modif,$usedTagsLib,$mandatory_z3950);

=head1 FUNCTIONS

=head2 MARCfindbreeding

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
            # normalize author : UNIMARC specific...
            if (    C4::Context->preference("z3950NormalizeAuthor")
                and C4::Context->preference("z3950AuthorAuthFields")
                and C4::Context->preference("marcflavour") eq 'UNIMARC' )
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

=head2 build_authorized_values_list

=cut

sub build_authorized_values_list {
    my ( $tag, $subfield, $value, $dbh, $authorised_values_sth,$index_tag,$index_subfield ) = @_;

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
        #Use GetBranches($onlymine)
        my $onlymine =
             C4::Context->preference('IndependentBranches')
          && C4::Context->userenv
          && !C4::Context->IsSuperLibrarian()
          && C4::Context->userenv->{branch};
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
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory}
            && ( $value || $tagslib->{$tag}->{$subfield}->{defaultvalue} ) );
          
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
        }
        $value = $default_source unless $value;
    }
    else {
        my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
        $authorised_values_sth->execute(
            $tagslib->{$tag}->{$subfield}->{authorised_value},
            $branch_limit ? $branch_limit : (),
        );

        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory}
            && ( $value || $tagslib->{$tag}->{$subfield}->{defaultvalue} ) );

        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
            push @authorised_values, $value;
            $authorised_lib{$value} = $lib;
        }
    }
    $authorised_values_sth->finish;
    return {
        type     => 'select',
        id       => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        name     => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        default  => $value,
        values   => \@authorised_values,
        labels   => \%authorised_lib,
    };

}

=head2 CreateKey

    Create a random value to set it into the input name

=cut

sub CreateKey {
    return int(rand(1000000));
}

=head2 GetMandatoryFieldZ3950

    This function return an hashref which containts all mandatory field
    to search with z3950 server.

=cut

sub GetMandatoryFieldZ3950 {
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

=head2 create_input

 builds the <input ...> entry for a subfield.

=cut

sub create_input {
    my ( $tag, $subfield, $value, $index_tag, $tabloop, $rec, $authorised_values_sth,$cgi ) = @_;
    
    my $index_subfield = CreateKey(); # create a specifique key for each subfield

    $value =~ s/"/&quot;/g;

    # if there is no value provided but a default value in parameters, get it
    if ( $value eq '' ) {
        $value = $tagslib->{$tag}->{$subfield}->{defaultvalue};

        # get today date & replace YYYY, MM, DD if provided in the default value
        my ( $year, $month, $day ) = Today();
        $month = sprintf( "%02d", $month );
        $day   = sprintf( "%02d", $day );
        $value =~ s/YYYY/$year/g;
        $value =~ s/MM/$month/g;
        $value =~ s/DD/$day/g;
        my $username=(C4::Context->userenv?C4::Context->userenv->{'surname'}:"superlibrarian");    
        $value=~s/user/$username/g;
    
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
        maxlength      => $tagslib->{$tag}->{$subfield}->{maxlength},
        random         => CreateKey(),
    );

    if(exists $mandatory_z3950->{$tag.$subfield}){
        $subfield_data{z3950_mandatory} = $mandatory_z3950->{$tag.$subfield};
    }
    # Subfield is hidden depending of hidden and mandatory flag, and is always
    # shown if it contains anything or if its field is mandatory.
    my $tdef = $tagslib->{$tag};
    $subfield_data{visibility} = "display:none;"
        if $tdef->{$subfield}->{hidden} % 2 == 1 &&
           $value eq '' &&
           !$tdef->{$subfield}->{mandatory} &&
           !$tdef->{mandatory};
    # expand all subfields of 773 if there is a host item provided in the input
    $subfield_data{visibility} ="" if ($tag eq 773 and $cgi->param('hostitemnumber'));


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

        $subfield_data{marc_value} = {
            type      => 'text',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            size      => 5,
            maxlength => $subfield_data{maxlength},
            readonly  => 1,
        };

    # it's a thesaurus / authority field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authtypecode} ) {
        # when authorities auto-creation is allowed, do not set readonly
        my $is_readonly = !C4::Context->preference("BiblioAddsAuthorities");

        $subfield_data{marc_value} = {
            type      => 'text',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            size      => 67,
            maxlength => $subfield_data{maxlength},
            readonly  => ($is_readonly) ? 1 : 0,
            authtype  => $tagslib->{$tag}->{$subfield}->{authtypecode},
        };

    # it's a plugin field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) {

        # opening plugin. Just check whether we are on a developer computer on a production one
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
        
            $subfield_data{marc_value} = {
                type           => 'text_complex',
                id             => $subfield_data{id},
                name           => $subfield_data{id},
                value          => $value,
                size           => 67,
                maxlength      => $subfield_data{maxlength},
                function_name  => $function_name,
                index_tag      => $index_tag,
                javascript     => $javascript,
            };

        } else {
            warn "Plugin Failed: $plugin";
            # supply default input form
            $subfield_data{marc_value} = {
                type      => 'text',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                size      => 67,
                maxlength => $subfield_data{maxlength},
                readonly  => 0,
            };

        }
        # it's an hidden field
    }
    elsif ( $tag eq '' ) {
        $subfield_data{marc_value} = {
            type      => 'hidden',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            size      => 67,
            maxlength => $subfield_data{maxlength},
        };

    }
    else {
        # it's a standard field
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
            $subfield_data{marc_value} = {
                type      => 'textarea',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
            };

        }
        else {
            $subfield_data{marc_value} = {
                type      => 'text',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                size      => 67,
                maxlength => $subfield_data{maxlength},
                readonly  => 0,
            };

        }
    }
    $subfield_data{'index_subfield'} = $index_subfield;
    return \%subfield_data;
}


=head2 format_indicator

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

sub build_tabs {
    my ( $template, $record, $dbh, $encoding,$input ) = @_;

    # fill arrays
    my @loop_data = ();
    my $tag;

    my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
    my $query = "SELECT authorised_value, lib
                FROM authorised_values";
    $query .= qq{ LEFT JOIN authorised_values_branches ON ( id = av_id )} if $branch_limit;
    $query .= " WHERE category = ?";
    $query .= " AND ( branchcode = ? OR branchcode IS NULL )" if $branch_limit;
    $query .= " GROUP BY lib ORDER BY lib, lib_opac";
    my $authorised_values_sth = $dbh->prepare( $query );

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
                        if ($tag >= 10){ # no indicator for 00x tags
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
    $authorised_values_sth->finish;
    $template->param( BIG_LOOP => \@BIG_LOOP );
}

# ========================
#          MAIN
#=========================
my $input = new CGI;
my $error = $input->param('error');
my $biblionumber  = $input->param('biblionumber'); # if biblionumber exists, it's a modif, not a new biblio.
my $parentbiblio  = $input->param('parentbiblionumber');
my $breedingid    = $input->param('breedingid');
my $z3950         = $input->param('z3950');
my $op            = $input->param('op');
my $mode          = $input->param('mode');
my $frameworkcode = $input->param('frameworkcode');
my $redirect      = $input->param('redirect');
my $searchid      = $input->param('searchid');
my $dbh           = C4::Context->dbh;
my $hostbiblionumber = $input->param('hostbiblionumber');
my $hostitemnumber = $input->param('hostitemnumber');
# fast cataloguing datas in transit
my $fa_circborrowernumber = $input->param('circborrowernumber');
my $fa_barcode            = $input->param('barcode');
my $fa_branch             = $input->param('branch');
my $fa_stickyduedate      = $input->param('stickyduedate');
my $fa_duedatespec        = $input->param('duedatespec');

my $userflags = 'edit_catalogue';

my $changed_framework = $input->param('changed_framework');
$frameworkcode = &GetFrameworkCode($biblionumber)
  if ( $biblionumber and not($frameworkcode) and $op ne 'addbiblio' );

if ($frameworkcode eq 'FA'){
    $userflags = 'fast_cataloging';
}

$frameworkcode = '' if ( $frameworkcode eq 'Default' );
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/addbiblio.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => $userflags },
    }
);

if ($frameworkcode eq 'FA'){
    # We need to grab and set some variables in the template for use on the additems screen
    $template->param(
        'circborrowernumber' => $fa_circborrowernumber,
        'barcode'            => $fa_barcode,
        'branch'             => $fa_branch,
        'stickyduedate'      => $fa_stickyduedate,
        'duedatespec'        => $fa_duedatespec,
    );
}

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
		$row{'selected'} = 1;
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

#populate hostfield if hostbiblionumber is available
if ($hostbiblionumber) {
    my $marcflavour = C4::Context->preference("marcflavour");
    $record = MARC::Record->new();
    $record->leader('');
    my $field =
      PrepHostMarcField( $hostbiblionumber, $hostitemnumber, $marcflavour );
    $record->append_fields($field);
}

# This is  a child record
if ($parentbiblio) {
    my $marcflavour = C4::Context->preference('marcflavour');
    $record = MARC::Record->new();
    SetMarcUnicodeFlag($record, $marcflavour);
    my $hostfield = prepare_host_field($parentbiblio,$marcflavour);
    if ($hostfield) {
        $record->append_fields($hostfield);
    }
}

$is_a_modif = 0;
    
if ($biblionumber) {
    $is_a_modif = 1;
    my $title = C4::Context->preference('marcflavour') eq "UNIMARC" ? $record->subfield('200', 'a') : $record->title;
    $template->param( title => $title );

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
    $template->param(
        biblionumberdata => $biblionumber,
    );
    # getting html input
    my @params = $input->param();
    $record = TransformHtmlToMarc( $input );
    # check for a duplicate
    my ( $duplicatebiblionumber, $duplicatetitle );
    if ( !$is_a_modif ) {
        ( $duplicatebiblionumber, $duplicatetitle ) = FindDuplicate($record);
    }
    my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
    # it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
    if ( !$duplicatebiblionumber or $confirm_not_duplicate ) {
        my $oldbibnum;
        my $oldbibitemnum;
        if (C4::Context->preference("BiblioAddsAuthorities")){
            BiblioAutoLink( $record, $frameworkcode );
        } 
        if ( $is_a_modif ) {
            ModBiblioframework( $biblionumber, $frameworkcode ); 
            ModBiblio( $record, $biblionumber, $frameworkcode );
        }
        else {
            ( $biblionumber, $oldbibitemnum ) = AddBiblio( $record, $frameworkcode );
        }
        if ($redirect eq "items" || ($mode ne "popup" && !$is_a_modif && $redirect ne "view" && $redirect ne "just_save")){
	    if ($frameworkcode eq 'FA'){
		print $input->redirect(
            '/cgi-bin/koha/cataloguing/additem.pl?'
            .'biblionumber='.$biblionumber
            .'&frameworkcode='.$frameworkcode
            .'&circborrowernumber='.$fa_circborrowernumber
            .'&branch='.$fa_branch
            .'&barcode='.uri_escape($fa_barcode)
            .'&stickyduedate='.$fa_stickyduedate
            .'&duedatespec='.$fa_duedatespec
		);
		exit;
	    }
	    else {
		print $input->redirect(
                "/cgi-bin/koha/cataloguing/additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode&searchid=$searchid"
		);
		exit;
	    }
        }
    elsif(($is_a_modif || $redirect eq "view") && $redirect ne "just_save"){
            my $defaultview = C4::Context->preference('IntranetBiblioDefaultView');
            my $views = { C4::Search::enabled_staff_search_views };
            if ($defaultview eq 'isbd' && $views->{can_view_ISBD}) {
                print $input->redirect("/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=$biblionumber&searchid=$searchid");
            } elsif  ($defaultview eq 'marc' && $views->{can_view_MARC}) {
                print $input->redirect("/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode&searchid=$searchid");
            } elsif  ($defaultview eq 'labeled_marc' && $views->{can_view_labeledMARC}) {
                print $input->redirect("/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=$biblionumber&searchid=$searchid");
            } else {
                print $input->redirect("/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber&searchid=$searchid");
            }
            exit;

    }
    elsif ($redirect eq "just_save"){
        my $tab = $input->param('current_tab');
        print $input->redirect("/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=$biblionumber&framework=$frameworkcode&tab=$tab&searchid=$searchid");
    }
    else {
          $template->param(
            biblionumber => $biblionumber,
            done         =>1,
            popup        =>1
          );
          if ( $record ne '-1' ) {
              my $title = C4::Context->preference('marcflavour') eq "UNIMARC" ? $record->subfield('200', 'a') : $record->title;
              $template->param( title => $title );
          }
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
    $template->param(
        biblionumberdata => $biblionumber,
        op               => $op,
    );
    if ( $op eq "duplicate" ) {
        $biblionumber = "";
    }

    if($changed_framework eq "changed"){
        $record = TransformHtmlToMarc( $input );
    }
    elsif( $record ne -1 ) {
#FIXME: it's kind of silly to go from MARC::Record to MARC::File::XML and then back again just to fix the encoding
        eval {
            my $uxml = $record->as_xml;
            MARC::Record::default_record_format("UNIMARC")
            if ( C4::Context->preference("marcflavour") eq "UNIMARC" );
            my $urecord = MARC::Record::new_from_xml( $uxml, 'UTF-8' );
            $record = $urecord;
        };
    }
    build_tabs( $template, $record, $dbh, $encoding,$input );
    $template->param(
        biblionumber             => $biblionumber,
        biblionumbertagfield        => $biblionumbertagfield,
        biblionumbertagsubfield     => $biblionumbertagsubfield,
        biblioitemnumtagfield    => $biblioitemnumtagfield,
        biblioitemnumtagsubfield => $biblioitemnumtagsubfield,
        biblioitemnumber         => $biblioitemnumber,
	hostbiblionumber	=> $hostbiblionumber,
	hostitemnumber		=> $hostitemnumber
    );
}

if ( $record ne '-1' ) {
    my $title = C4::Context->preference('marcflavour') eq "UNIMARC" ? $record->subfield('200', 'a') : $record->title;
    $template->param( title => $title );
}
$template->param(
    popup => $mode,
    frameworkcode => $frameworkcode,
    itemtype => $frameworkcode,
    borrowernumber => $loggedinuser,
    tab => $input->param('tab')
);
$template->{'VARS'}->{'searchid'} = $searchid;

output_html_with_http_headers $input, $cookie, $template->output;
