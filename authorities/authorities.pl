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
use C4::Auth;
use C4::Output;
use C4::AuthoritiesMarc;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use Date::Calc qw(Today);
use MARC::File::USMARC;
use MARC::File::XML;
use C4::Biblio;
use vars qw( $tagslib);
use vars qw( $authorised_values_sth);
use vars qw( $is_a_modif );

my $itemtype; # created here because it can be used in build_authorized_values_list sub
our($authorised_values_sth,$is_a_modif,$usedTagsLib,$mandatory_z3950);

=item build_authorized_values_list

=cut

sub build_authorized_values_list ($$$$$$$) {
    my ( $tag, $subfield, $value, $dbh, $authorised_values_sth,$index_tag,$index_subfield ) = @_;

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
        my $sth =
        $dbh->prepare(
            "select branchcode,branchname from branches order by branchname");
        $sth->execute;
        push @authorised_values, ""
        unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );

        while ( my ( $branchcode, $branchname ) = $sth->fetchrow_array ) {
            push @authorised_values, $branchcode;
            $authorised_lib{$branchcode} = $branchname;
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
    my %subfield_data = (
        tag        => $tag,
        subfield   => $subfield,
        marc_lib   => substr( $tagslib->{$tag}->{$subfield}->{lib}, 0, 22 ),
        marc_lib_plain => $tagslib->{$tag}->{$subfield}->{lib}, 
        tag_mandatory  => $tagslib->{$tag}->{mandatory},
        mandatory      => $tagslib->{$tag}->{$subfield}->{mandatory},
        repeatable     => $tagslib->{$tag}->{$subfield}->{repeatable},
        kohafield      => $tagslib->{$tag}->{$subfield}->{kohafield},
        index          => $index_tag,
        id             => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        value          => $value,
    );
    if($subfield eq '@'){
        $subfield_data{id} = "tag_".$tag."_subfield_00_".$index_tag."_".$index_subfield;
    } else {
        $subfield_data{id} = "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield;
    }

    if(exists $mandatory_z3950->{$tag.$subfield}){
        $subfield_data{z3950_mandatory} = $mandatory_z3950->{$tag.$subfield};
    }
    
    $subfield_data{visibility} = "display:none;"
        if (    ($tagslib->{$tag}->{$subfield}->{hidden} % 2 == 1) and $value ne ''
            or ($value eq '' and !$tagslib->{$tag}->{$subfield}->{mandatory})
        );
    
    # it's an authorised field
    if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
        $subfield_data{marc_value} =
        build_authorized_values_list( $tag, $subfield, $value, $dbh,
            $authorised_values_sth,$index_tag,$index_subfield );

    # it's a thesaurus / authority field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authtypecode} ) {
        $subfield_data{marc_value} =
    "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"".$subfield_data{id}."\"
    value=\"$value\"
    class=\"input_marceditor\"
    tabindex=\"1\"                     
    disabled=\"disabled\"
        readonly=\"readonly\" \/>
    <span class=\"buttonDot\"
        onclick=\"Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&index=$subfield_data{id}','$subfield_data{id}')\">...</span>
    ";
    # it's a plugin field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) {

        # opening plugin. Just check wether we are on a developper computer on a production one
        # (the cgidir differs)
        my $cgidir = C4::Context->intranetdir . "/cgi-bin/cataloguing/value_builder";
        unless (-r $cgidir and -d $cgidir) {
            $cgidir = C4::Context->intranetdir . "/cataloguing/value_builder";
        }
        my $plugin = $cgidir . "/" . $tagslib->{$tag}->{$subfield}->{'value_builder'};
        do $plugin || die "Plugin Failed: ".$plugin;
        my $extended_param = plugin_parameters( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
        my ( $function_name, $javascript ) = plugin_javascript( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
#         my ( $function_name, $javascript,$extended_param );
        
        $subfield_data{marc_value} =
            "<input tabindex=\"1\"
                    type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    size=\"67\"
                    maxlength=\"$max_length\"
                    name=\"".$subfield_data{id}."\"
                    value=\"$value\"
                    class=\"input_marceditor\"
                    onfocus=\"Focus$function_name($index_tag)\"
                    onblur=\"Blur$function_name($index_tag); \" \/>
                    <a href=\"#\" class=\"buttonDot\" onclick=\"Clic$function_name('$subfield_data{id}'); return false;\" title=\"Tag Editor\">...</a>
                    $javascript";
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
            or (    $tag >= 600
                and $tag < 700
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
                        size=\"67\"
                        maxlength=\"$max_length\"
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

=item CreateKey

    Create a random value to set it into the input name

=cut

sub CreateKey(){
    return int(rand(1000000));
}

sub build_tabs ($$$$$) {
    my ( $template, $record, $dbh, $encoding,$input ) = @_;

    # fill arrays
    my @loop_data = ();
    my $tag;

    my $authorised_values_sth = $dbh->prepare(
        "SELECT authorised_value,lib
        FROM authorised_values
        WHERE category=? ORDER BY lib"
    );
    
    # in this array, we will push all the 10 tabs
    # to avoid having 10 tabs in the template : they will all be in the same BIG_LOOP
    my @BIG_LOOP;
    my %seen;
    my @tab_data; # all tags to display
    
    foreach my $used ( keys %$tagslib ){
        push @tab_data,$used if not $seen{$used};
        $seen{$used}++;
    }
        
    my $max_num_tab=9;
    # loop through each tab 0 through 9
    for ( my $tabloop = 0 ; $tabloop <= $max_num_tab ; $tabloop++ ) {
        my @loop_data = (); #innerloop in the template.
        my $i = 0;
        foreach my $tag (sort @tab_data) {
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
                            or ( $tagslib->{$tag}->{$subfield}->{hidden} >= 5 )
                        );    #check for visibility flag
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
                            fixedfield    => ($tag < 10)?(1):(0),
                            random        => CreateKey,
                        );
                        if ($tag >= 10){ # no indicator for theses tag
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
                    next if ( ( $tagslib->{$tag}->{$subfield}->{hidden} <= -5 )
                                or ( $tagslib->{$tag}->{$subfield}->{hidden} >= 4 ) )
                            ;    #check for visibility flag
                    next if ( $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
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
                        fixedfield       => ($tag < 10)?(1):(0)
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


sub build_hidden_data () {
    # build hidden data =>
    # we store everything, even if we show only requested subfields.

    my @loop_data =();
    my $i=0;
    foreach my $tag (keys %{$tagslib}) {
        my $previous_tag = '';

        # loop through each subfield
        foreach my $subfield (keys %{$tagslib->{$tag}}) {
            next if ($subfield eq 'lib');
            next if ($subfield eq 'tab');
            next if ($subfield eq 'mandatory');
                next if ($subfield eq 'repeatable');
            next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "-1");
            my %subfield_data;
            $subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
            $subfield_data{marc_mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
            $subfield_data{marc_repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
            $subfield_data{marc_value}="<input type=\"hidden\" name=\"field_value[]\">";
            push(@loop_data, \%subfield_data);
            $i++
        }
    }
}

# ======================== 
#          MAIN 
#=========================
my $input = new CGI;
my $z3950 = $input->param('z3950');
my $error = $input->param('error');
my $authid=$input->param('authid'); # if authid exists, it's a modif, not a new authority.
my $op = $input->param('op');
my $nonav = $input->param('nonav');
my $myindex = $input->param('index');
my $linkid=$input->param('linkid');
my $authtypecode = $input->param('authtypecode');

my $dbh = C4::Context->dbh;
$authtypecode = &GetAuthTypeCode($authid) if !$authtypecode;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "authorities/authorities.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {editauthorities => 1},
                            debug => 1,
                            });
$template->param(nonav   => $nonav,index=>$myindex,authtypecode=>$authtypecode,);
$tagslib = GetTagsLabels(1,$authtypecode);
my $record=-1;
my $encoding="";
$record = GetAuthority($authid) if ($authid);
my ($oldauthnumtagfield,$oldauthnumtagsubfield);
my ($oldauthtypetagfield,$oldauthtypetagsubfield);
$is_a_modif=0;
if ($authid) {
    $is_a_modif=1;
    ($oldauthnumtagfield,$oldauthnumtagsubfield) = &GetAuthMARCFromKohaField("auth_header.authid",$authtypecode);
    ($oldauthtypetagfield,$oldauthtypetagsubfield) = &GetAuthMARCFromKohaField("auth_header.authtypecode",$authtypecode);
}

#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "add") {
#------------------------------------------------------------------------------------------------------------------------------
    # rebuild
    my @tags = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values = $input->param('field_value');
    # build indicator hash.
    my @ind_tag = $input->param('ind_tag');
    my @indicator = $input->param('indicator');
    my @params = $input->param();
    my $record = TransformHtmlToMarc(\@params,$input);
    if  (C4::Context->preference("marcflavour") eq "UNIMARC"){
        unless ($record->field('100')){
        use POSIX qw(strftime);
        my $string = strftime( "%Y%m%d", localtime(time) );
        # set 50 to position 26 is biblios, 13 if authorities
        my $pos=13;
        $string = sprintf( "%-*s", 35, $string );
        substr( $string, $pos , 2, "50" );
        $record->append_fields(MARC::Field->new('100','','',"a"=>$string));
        }    
    }

    my ($duplicateauthid,$duplicateauthvalue) = FindDuplicateAuthority($record,$authtypecode) if ($op eq "add") && (!$is_a_modif);
    my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
    # it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
    if (!$duplicateauthid or $confirm_not_duplicate) {
        if ($is_a_modif ) {	
            ModAuthority($authid,$record,$authtypecode);
        } else {
            ($authid) = AddAuthority($record,$authid,$authtypecode);
        }
        print $input->redirect("detail.pl?authid=$authid");
        exit;
    } else {
    # it may be a duplicate, warn the user and do nothing
        build_tabs($template, $record, $dbh, $encoding,$input);
        build_hidden_data;
        $template->param(authid =>$authid,
                        duplicateauthid     => $duplicateauthid,
                        duplicateauthvalue  => $duplicateauthvalue,
                        );
    }
} elsif ($op eq "delete") {
#------------------------------------------------------------------------------------------------------------------------------
        &DelAuthority($authid);
        if ($nonav){
            print $input->redirect("auth_finder.pl");
        }else{
            print $input->redirect("authorities-home.pl?authid=0");
        }
                exit;
} else {
if ($op eq "duplicate")
        {
                $authid = "";
        }
        build_tabs ($template, $record, $dbh,$encoding,$input);
        build_hidden_data;
        $template->param(oldauthtypetagfield=>$oldauthtypetagfield, oldauthtypetagsubfield=>$oldauthtypetagsubfield,
                        oldauthnumtagfield=>$oldauthnumtagfield, oldauthnumtagsubfield=>$oldauthnumtagsubfield,
                        authid                      => $authid , authtypecode=>$authtypecode,	);
}

$template->param(authid                       => $authid,
                 authtypecode => $authtypecode,
                 linkid=>$linkid,
);

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (keys %$authtypes) {
    my $selected = 1 if $thisauthtype eq $authtypecode;
    my %row =(value => $thisauthtype,
                selected => $selected,
                authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
            );
    push @authtypesloop, \%row;
}

$template->param(authtypesloop => \@authtypesloop,
                authtypetext => $authtypes->{$authtypecode}{'authtypetext'},
                hide_marc => C4::Context->preference('hide_marc'),
                );
output_html_with_http_headers $input, $cookie, $template->output;
