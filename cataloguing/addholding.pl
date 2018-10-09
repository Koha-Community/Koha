#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
# Copyright 2004-2010 BibLibre
# Copyright 2017-2018 University of Helsinki (The National Library Of Finland)
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

# TODO: refactor to avoid duplication from addbiblio

use strict;
#use warnings; FIXME - Bug 2505
use CGI q(-utf8);
use C4::Output;
use C4::Auth;
use C4::Holdings;
use C4::Search;
use C4::Biblio;
use C4::Context;
use MARC::Record;
use C4::Log;
use C4::Koha;
use C4::ClassSource;
use C4::ImportBatch;
use C4::Charset;
use Koha::Biblios;
use Koha::BiblioFrameworks;
use Koha::DateUtils;
use C4::Matcher;

use Koha::ItemTypes;
use Koha::Libraries;

use Date::Calc qw(Today);
use MARC::File::USMARC;
use MARC::File::XML;
use URI::Escape;

if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
    MARC::File::XML->default_record_format('UNIMARC');
}

our($tagslib,$authorised_values_sth,$is_a_modif,$usedTagsLib,$mandatory_z3950);

=head1 FUNCTIONS

=head2 build_authorized_values_list

=cut

sub build_authorized_values_list {
    my ( $tag, $subfield, $value, $dbh, $authorised_values_sth,$index_tag,$index_subfield ) = @_;

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
        my $libraries = Koha::Libraries->search_filtered({}, {order_by => ['branchname']});
        while ( my $l = $libraries->next ) {
            push @authorised_values, $l->branchcode;
            $authorised_lib{$l->branchcode} = $l->branchname;
        }
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "LOC" ) {
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory}
            && ( $value || $tagslib->{$tag}->{$subfield}->{defaultvalue} ) );


        my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
        my $avs = Koha::AuthorisedValues->search(
            {
                branchcode => $branch_limit,
                category => $tagslib->{$tag}->{$subfield}->{authorised_value},
            },
            {
                order_by => [ 'category', 'lib', 'lib_opac' ],
            }
        );

        while ( my $av = $avs->next ) {
            push @authorised_values, $av->authorised_value;
            $authorised_lib{$av->authorised_value} = $av->lib;
        }
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

=head2 create_input

 builds the <input ...> entry for a subfield.

=cut

sub create_input {
    my ( $tag, $subfield, $value, $index_tag, $tabloop, $rec, $authorised_values_sth,$cgi ) = @_;

    my $index_subfield = CreateKey(); # create a specific key for each subfield

    $value =~ s/"/&quot;/g;

    # if there is no value provided but a default value in parameters, get it
    if ( $value eq '' ) {
        $value = $tagslib->{$tag}->{$subfield}->{defaultvalue};

        # get today date & replace <<YYYY>>, <<MM>>, <<DD>> if provided in the default value
        my $today_dt = dt_from_string;
        my $year = $today_dt->strftime('%Y');
        my $month = $today_dt->strftime('%m');
        my $day = $today_dt->strftime('%d');
        $value =~ s/<<YYYY>>/$year/g;
        $value =~ s/<<MM>>/$month/g;
        $value =~ s/<<DD>>/$day/g;
        # And <<USER>> with surname (?)
        my $username=(C4::Context->userenv?C4::Context->userenv->{'surname'}:"superlibrarian");
        $value=~s/<<USER>>/$username/g;

    }
    my $dbh = C4::Context->dbh;

    # map '@' as "subfield" label for fixed fields
    # to something that's allowed in a div id.
    my $id_subfield = $subfield;
    $id_subfield = "00" if $id_subfield eq "@";

    my %subfield_data = (
        tag        => $tag,
        subfield   => $id_subfield,
        marc_lib       => $tagslib->{$tag}->{$subfield}->{lib},
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
    } elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) {
        require Koha::FrameworkPlugin;
        my $plugin = Koha::FrameworkPlugin->new( {
            name => $tagslib->{$tag}->{$subfield}->{'value_builder'},
        });
        my $pars= { dbh => $dbh, record => $rec, tagslib => $tagslib,
            id => $subfield_data{id}, tabloop => $tabloop };
        $plugin->build( $pars );
        if( !$plugin->errstr ) {
            $subfield_data{marc_value} = {
                type           => 'text_complex',
                id             => $subfield_data{id},
                name           => $subfield_data{id},
                value          => $value,
                size           => 67,
                maxlength      => $subfield_data{maxlength},
                javascript     => $plugin->javascript,
                noclick        => $plugin->noclick,
            };
        } else {
            warn $plugin->errstr;
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
    } elsif ( $tag eq '' ) {
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
my $biblionumber  = $input->param('biblionumber');
my $holding_id = $input->param('holding_id'); # if holding_id exists, it's a modif, not a new holding.
my $op            = $input->param('op');
my $mode          = $input->param('mode');
my $frameworkcode = $input->param('frameworkcode');
my $redirect      = $input->param('redirect');
my $searchid      = $input->param('searchid');
my $dbh           = C4::Context->dbh;

my $userflags = 'edit_items';

my $changed_framework = $input->param('changed_framework');
$frameworkcode = &C4::Holdings::GetHoldingFrameworkCode($holding_id)
  if ( $holding_id and not( defined $frameworkcode) and $op ne 'add' );

$frameworkcode = 'HLD' if ( !$frameworkcode || $frameworkcode eq 'Default' );
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/addholding.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => $userflags },
    }
);

# TODO: support in advanced editor?
#if ( $op ne "delete" && C4::Context->preference('EnableAdvancedCatalogingEditor') && $input->cookie( 'catalogue_editor_' . $loggedinuser ) eq 'advanced' ) {
#    print $input->redirect( '/cgi-bin/koha/cataloguing/editor.pl#catalog/' . $biblionumber . '/holdings/' . ( $holding_id ? $holding_id : '' ) );
#    exit;
#}

my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] });
$template->param(
    frameworks => $frameworks
);

# ++ Global
$tagslib         = &GetMarcStructure( 1, $frameworkcode );
$usedTagsLib     = &GetUsedMarcStructure( $frameworkcode );
# -- Global

my $record   = -1;
my $encoding = "";

if ($holding_id){
    $record = C4::Holdings::GetMarcHolding($holding_id);
}

$is_a_modif = 0;

if ($holding_id) {
    $is_a_modif = 1;

}
my ( $biblionumbertagfield, $biblionumbertagsubfield ) =
    &GetMarcFromKohaField( "biblio.biblionumber", $frameworkcode );

#-------------------------------------------------------------------------------------
if ( $op eq "add" ) {
#-------------------------------------------------------------------------------------
    $template->param(
        biblionumberdata => $biblionumber,
    );
    # getting html input
    my @params = $input->multi_param();
    $record = TransformHtmlToMarc( $input, 1 );
    if ( $is_a_modif ) {
        ModHolding( $record, $holding_id, $frameworkcode );
    }
    else {
        $holding_id = AddHolding( $record, $frameworkcode, $biblionumber );
    }
    if ($redirect eq "items" || ($mode ne "popup" && !$is_a_modif && $redirect ne "view" && $redirect ne "just_save")){
        print $input->redirect("/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber&searchid=$searchid");
        exit;
    }
    elsif(($is_a_modif || $redirect eq "view") && $redirect ne "just_save"){
        print $input->redirect("/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber&searchid=$searchid");
        exit;
    }
    elsif ($redirect eq "just_save"){
        my $tab = $input->param('current_tab');
        print $input->redirect("/cgi-bin/koha/cataloguing/addholding.pl?biblionumber=$biblionumber&holding_id=$holding_id&framework=$frameworkcode&tab=$tab&searchid=$searchid");
    }
    else {
          $template->param(
            biblionumber => $biblionumber,
            holding_id => $holding_id,
            done         =>1,
            popup        =>1
          );
          $template->param(
            popup => $mode,
            itemtype => $frameworkcode,
          );
          output_html_with_http_headers $input, $cookie, $template->output;
          exit;
    }
}
elsif ( $op eq "delete" ) {

    my $error = &DelHolding($holding_id);
    if ($error) {
        warn "ERROR when DELETING HOLDING $holding_id : $error";
        print "Content-Type: text/html\n\n<html><body><h1>ERROR when DELETING HOLDING $holding_id : $error</h1></body></html>";
        exit;
    }

    print $input->redirect("/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber&searchid=$searchid");
    exit;

} else {
   #----------------------------------------------------------------------------
   # If we're in a duplication case, we have to set to "" the holding_id
   # as we'll save the holding as a new one.
    $template->param(
        holding_iddata => $holding_id,
        op                => $op,
    );
    if ( $op eq "duplicate" ) {
        $holding_id = "";
    }

    if($changed_framework eq "changed") {
        $record = TransformHtmlToMarc( $input, 1 );
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
    my $biblio = Koha::Biblios->find( $biblionumber );
    build_tabs( $template, $record, $dbh, $encoding,$input );
    $template->param(
        holding_id               => $holding_id,
        biblionumber             => $biblionumber,
        biblionumbertagfield     => $biblionumbertagfield,
        biblionumbertagsubfield  => $biblionumbertagsubfield,
        title                    => $biblio->title,
        author                   => $biblio->author
    );
}

$template->param(
    popup => $mode,
    frameworkcode => $frameworkcode,
    itemtype => $frameworkcode,
    borrowernumber => $loggedinuser,
    tab => scalar $input->param('tab')
);
$template->{'VARS'}->{'searchid'} = $searchid;

output_html_with_http_headers $input, $cookie, $template->output;
