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

use Modern::Perl;

use CGI;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user haspermission );
use C4::Biblio qw(
    AddBiblio
    DelBiblio
    GetFrameworkCode
    GetMarcFromKohaField
    GetMarcStructure
    GetUsedMarcStructure
    ModBiblio
    prepare_host_field
    PrepHostMarcField
    TransformHtmlToMarc
    ApplyMarcOverlayRules
);
use C4::Search qw( FindDuplicate enabled_staff_search_views );
use C4::Auth qw( get_template_and_user haspermission );
use C4::Context;
use MARC::Record;
use C4::ClassSource qw( GetClassSources );
use C4::ImportBatch qw( GetImportRecordMarc );
use C4::Charset qw( SetMarcUnicodeFlag );
use Koha::BiblioFrameworks;
use Koha::DateUtils qw( dt_from_string );

use Koha::Biblios;
use Koha::ItemTypes;
use Koha::Libraries;

use Koha::BiblioFrameworks;
use Koha::Patrons;
use Koha::UI::Form::Builder::Biblio;

use MARC::File::USMARC;
use MARC::File::XML;
use URI::Escape qw( uri_escape_utf8 );

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
        if(C4::Context->preference('autoControlNumber') eq 'biblionumber'){
            my @control_num = $record->field('001');
            $record->delete_fields(@control_num);
        }
        my ($isbnfield,$isbnsubfield) = GetMarcFromKohaField( 'biblioitems.isbn' );
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
                my ( $tag, $subfield ) = GetMarcFromKohaField( "biblio.author" );

                my $auth_fields =
                  C4::Context->preference("z3950AuthorAuthFields");
                my @auth_fields = split /,/, $auth_fields;
                my $field;

                if ( $record->field($tag) ) {
                    foreach my $tmpfield ( $record->field($tag)->subfields ) {

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
                        $field->add_subfields(
                                "$subfield" => ucfirst($title) . " "
                              . ucfirst($firstname) . " "
                              . $number );
                    }
                    else {
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

=head2 CreateKey

    Create a random value to set it into the input name

=cut

sub CreateKey {
    return int(rand(1000000));
}

=head2 GetMandatoryFieldZ3950

    This function returns a hashref which contains all mandatory field
    to search with z3950 server.

=cut

sub GetMandatoryFieldZ3950 {
    my $frameworkcode = shift;
    my @isbn   = GetMarcFromKohaField( 'biblioitems.isbn' );
    my @title  = GetMarcFromKohaField( 'biblio.title' );
    my @author = GetMarcFromKohaField( 'biblio.author' );
    my @issn   = GetMarcFromKohaField( 'biblioitems.issn' );
    my @lccn   = GetMarcFromKohaField( 'biblioitems.lccn' );
    
    return {
        $isbn[0].$isbn[1]     => 'isbn',
        $title[0].$title[1]   => 'title',
        $author[0].$author[1] => 'author',
        $issn[0].$issn[1]     => 'issn',
        $lccn[0].$lccn[1]     => 'lccn',
    };
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
    $query .= " GROUP BY authorised_value,lib ORDER BY lib, lib_opac";
    my $authorised_values_sth = $dbh->prepare( $query );

    # in this array, we will push all the 10 tabs
    # to avoid having 10 tabs in the template : they will all be in the same BIG_LOOP
    my @BIG_LOOP;
    my %seen;
    my @tab_data; # all tags to display

    my $max_num_tab=-1;
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField( "items.itemnumber" );
    foreach my $used ( @$usedTagsLib ){

        push @tab_data,$used->{tagfield} if not $seen{$used->{tagfield}};
        $seen{$used->{tagfield}}++;

        if (   $used->{tab} > -1
            && $used->{tab} >= $max_num_tab
            && $used->{tagfield} ne $itemtag )
        {
            $max_num_tab = $used->{tab};
        }
    }
    if($max_num_tab >= 9){
        $max_num_tab = 9;
    }

    my $biblio_form_builder = Koha::UI::Form::Builder::Biblio->new(
        {
            biblionumber => scalar $input->param('biblionumber'),
        }
    );

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
                        next
                          if ( $tagslib->{$tag}->{$subfield}->{kohafield} eq
                            'biblio.biblionumber' );
                        push(
                            @subfields_data,
                            $biblio_form_builder->generate_subfield_form(
                                {
                                    tag => $tag,
                                    subfield => $subfield,
                                    value => $value,
                                    index_tag => $index_tag,
                                    record => $record,
                                    hostitemnumber => scalar $input->param('hostitemnumber'),
                                    op => scalar $input->param('op'),
                                    changed_framework => scalar $input->param('changed_framework'),
                                    breedingid => scalar $input->param('breedingid'),
                                    tagslib => $tagslib,
                                    mandatory_z3950 => $mandatory_z3950,
                                }
                            )
                        );
                    }
                    else {
                        my @subfields = $field->subfields();
                        foreach my $subfieldcount ( 0 .. $#subfields ) {
                            my $subfield = $subfields[$subfieldcount][0];
                            my $value    = $subfields[$subfieldcount][1];
                            next if ( length $subfield != 1 );
                            next if ( !defined $tagslib->{$tag}->{$subfield} || $tagslib->{$tag}->{$subfield}->{tab} ne $tabloop );
                            push(
                                @subfields_data,
                                $biblio_form_builder->generate_subfield_form(
                                    {
                                        tag => $tag,
                                        subfield => $subfield,
                                        value => $value,
                                        index_tag => $index_tag,
                                        record => $record,
                                        hostitemnumber => scalar $input->param('hostitemnumber'),
                                        tagslib => $tagslib,
                                        mandatory_z3950 => $mandatory_z3950,
                                    }
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
                                      $tagslib->{$tag}->{'a'}->{authtypecode} ne "" and
                                      $tagslib->{$tag}->{'a'}->{hidden} > -4 and
                                      $tagslib->{$tag}->{'a'}->{hidden} < 5
                                    )
                          ;    #check for visibility flag
                               # if subfield is $9 in a field whose $a is authority-controlled,
                               # always include in the form regardless of the hidden setting - bug 2206 and 28022
                        next if ( defined( $field->subfield($subfield) ) );
                        push(
                            @subfields_data,
                            $biblio_form_builder->generate_subfield_form(
                                {
                                    tag => $tag,
                                    subfield => $subfield,
                                    value => '',
                                    index_tag => $index_tag,
                                    record => $record,
                                    hostitemnumber => scalar $input->param('hostitemnumber'),
                                    tagslib => $tagslib,
                                    mandatory_z3950 => $mandatory_z3950,
                                }
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
                            important       => $tagslib->{$tag}->{important},
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
                foreach my $subfield (
                    sort { $a->{display_order} <=> $b->{display_order} || $a->{subfield} cmp $b->{subfield} }
                    grep { ref($_) && %$_ } # Not a subfield (values for "important", "lib", "mandatory", etc.) or empty
                    values %{ $tagslib->{$tag} } )
                {
                    next
                      if ( ( $subfield->{hidden} <= -4 )
                        or ( $subfield->{hidden} >= 5 ) )
                      and not ( $subfield->{subfield} eq "9" and
                                exists($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                defined($tagslib->{$tag}->{'a'}->{authtypecode}) and
                                $tagslib->{$tag}->{'a'}->{authtypecode} ne "" and
                                $tagslib->{$tag}->{'a'}->{hidden} > -4 and
                                $tagslib->{$tag}->{'a'}->{hidden} < 5
                              )
                      ;    #check for visibility flag
                           # if subfield is $9 in a field whose $a is authority-controlled,
                           # always include in the form regardless of the hidden setting - bug 2206 and 28022
                    next
                      if ( $subfield->{tab} ne $tabloop );
			push(
                        @subfields_data,
                        $biblio_form_builder->generate_subfield_form(
                            {
                                tag => $tag,
                                subfield => $subfield->{subfield},
                                value => '',
                                index_tag => $index_tag,
                                record => $record,
                                hostitemnumber => scalar $input->param('hostitemnumber'),
                                tagslib => $tagslib,
                                mandatory_z3950 => $mandatory_z3950,
                            }
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
                        important       => $tagslib->{$tag}->{important},
                        indicator1       => ( $indicator1 || $tagslib->{$tag}->{ind1_defaultvalue} ), #if not set, try to load the default value
                        indicator2       => ( $indicator2 || $tagslib->{$tag}->{ind2_defaultvalue} ), #use short-circuit operator for efficiency
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
my $input = CGI->new;
my $error = $input->param('error');
my $biblionumber  = $input->param('biblionumber'); # if biblionumber exists, it's a modif, not a new biblio.
my $parentbiblio  = $input->param('parentbiblionumber');
my $breedingid    = $input->param('breedingid');
my $z3950         = $input->param('z3950');
my $op            = $input->param('op') // q{};
my $mode          = $input->param('mode') // q{};
my $frameworkcode = $input->param('frameworkcode');
my $redirect      = $input->param('redirect');
my $searchid      = $input->param('searchid') // "";
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

my $changed_framework = $input->param('changed_framework') // q{};
$frameworkcode = &GetFrameworkCode($biblionumber)
  if ( $biblionumber and not( defined $frameworkcode) and $op ne 'addbiblio' );

if ($frameworkcode eq 'FA'){
    $userflags = 'fast_cataloging';
}

$frameworkcode = '' if ( $frameworkcode eq 'Default' );
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/addbiblio.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { editcatalogue => $userflags },
    }
);

my $biblio;
if ($biblionumber){
    $biblio = Koha::Biblios->find($biblionumber);
    unless ( $biblio ) {
        $biblionumber = undef;
        $template->param( bib_doesnt_exist => 1 );
    }
}

if ($frameworkcode eq 'FA'){
    # We need to grab and set some variables in the template for use on the additems screen
    $template->param(
        'circborrowernumber' => $fa_circborrowernumber,
        'barcode'            => $fa_barcode,
        'branch'             => $fa_branch,
        'stickyduedate'      => $fa_stickyduedate,
        'duedatespec'        => $fa_duedatespec,
    );
} elsif ( $op ne "delete" &&
            C4::Context->preference('EnableAdvancedCatalogingEditor') &&
            C4::Auth::haspermission(C4::Context->userenv->{id},{'editcatalogue'=>'advanced_editor'}) &&
            $input->cookie( 'catalogue_editor_' . $loggedinuser ) eq 'advanced' &&
            !$breedingid ) {
    # Only use the advanced editor for non-fast-cataloging.
    # breedingid is not handled because those would only come off a Z39.50
    # search initiated by the basic editor.
    print $input->redirect( '/cgi-bin/koha/cataloguing/editor.pl' . ( $biblionumber ? ( ($op eq 'duplicate'?'#duplicate/':'#catalog/') . $biblionumber ) : '' ) );
    exit;
}

my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] });
$template->param(
    frameworks => $frameworks,
    breedingid => $breedingid,
);

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
	$biblioitemnumber
);

if ( $biblio && !$breedingid ) {
    $record = $biblio->metadata->record;
}
if ($breedingid) {
    ( $record, $encoding ) = MARCfindbreeding( $breedingid ) ;
}
if ( $record && $op eq 'duplicate' &&
     C4::Context->preference('autoControlNumber') eq 'biblionumber' ){
    my @control_num = $record->field('001');
    $record->delete_fields(@control_num);
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
        &GetMarcFromKohaField( "biblio.biblionumber" );
    ( $biblioitemnumtagfield, $biblioitemnumtagsubfield ) =
        &GetMarcFromKohaField( "biblioitems.biblioitemnumber" );

    # search biblioitems value
    my $sth =  $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblionumber);
    ($biblioitemnumber) = $sth->fetchrow;
    if (C4::Context->preference('MARCOverlayRules')) {
        my $member = Koha::Patrons->find($loggedinuser);
        $record = ApplyMarcOverlayRules(
            {
                biblionumber    => $biblionumber,
                record          => $record,
                overlay_context =>  {
                        source       => $z3950 ? 'z3950' : 'intranet',
                        categorycode => $member->categorycode,
                        userid       => $member->userid
                }
            }
        );
    }
}

#-------------------------------------------------------------------------------------
if ( $op eq "addbiblio" ) {
#-------------------------------------------------------------------------------------
    $template->param(
        biblionumberdata => $biblionumber,
    );
    # getting html input
    my @params = $input->multi_param();
    $record = TransformHtmlToMarc( $input, 1 );
    # check for a duplicate
    my ( $duplicatebiblionumber, $duplicatetitle );
    if ( !$is_a_modif ) {
        ( $duplicatebiblionumber, $duplicatetitle ) = FindDuplicate($record);
    }
    my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
    # it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
    if ( !$duplicatebiblionumber or $confirm_not_duplicate ) {
        my $oldbibitemnum;
        if ( $is_a_modif ) {
            my $member = Koha::Patrons->find($loggedinuser);
            ModBiblio(
                $record,
                $biblionumber,
                $frameworkcode,
                {
                    overlay_context => {
                        source       => $z3950 ? 'z3950' : 'intranet',
                        categorycode => $member->categorycode,
                        userid       => $member->userid
                    }
                }
            );
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
            .'&barcode='.uri_escape_utf8($fa_barcode)
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
    
    print $input->redirect('/cgi-bin/koha/catalogue/search.pl' . ($searchid ? "?searchid=$searchid" : ""));
    exit;
    
} else {
   #----------------------------------------------------------------------------
   # If we're in a duplication case, we have to set to "" the biblionumber
   # as we'll save the biblio as a new one.
    $template->param(
        biblionumberdata => $biblionumber,
        op               => $op,
        z3950            => $z3950
    );
    if ( $op eq "duplicate" ) {
        $biblionumber = "";
    }

    if($changed_framework eq "changed"){
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
    tab => scalar $input->param('tab')
);
$template->{'VARS'}->{'searchid'} = $searchid;

output_html_with_http_headers $input, $cookie, $template->output;
