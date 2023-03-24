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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::AuthoritiesMarc qw( AddAuthority ModAuthority GetAuthority GetTagsLabels GetAuthMARCFromKohaField FindDuplicateAuthority );
use C4::Context;
use Date::Calc qw( Today );
use MARC::File::USMARC;
use MARC::File::XML;
use C4::Biblio qw( TransformHtmlToMarc );
use Koha::Authority::Types;
use Koha::Import::Records;
use Koha::ItemTypes;
use vars qw( $tagslib);
use vars qw( $authorised_values_sth);
use vars qw( $is_a_modif );

our($authorised_values_sth,$is_a_modif,$usedTagsLib,$mandatory_z3950);

=head1 FUNCTIONS

=over

=item build_authorized_values_list

builds list, depending on authorised value...

=cut

sub build_authorized_values_list {
    my ( $tag, $subfield, $value, $dbh, $authorised_values_sth,$index_tag,$index_subfield ) = @_;

    my @authorised_values;
    my %authorised_lib;

    my $category = $tagslib->{$tag}->{$subfield}->{'authorised_value'};
    push @authorised_values, q{} unless $tagslib->{$tag}->{$subfield}->{mandatory} && $value;

    if ( $category eq "branches" ) {
        my $sth = $dbh->prepare( "select branchcode,branchname from branches order by branchname" );
        $sth->execute;
        while ( my ( $branchcode, $branchname ) = $sth->fetchrow_array ) {
            push @authorised_values, $branchcode;
            $authorised_lib{$branchcode} = $branchname;
        }
    }
    elsif ( $category eq "itemtypes" ) {
        my $itemtypes = Koha::ItemTypes->search_with_localization;
        while ( my $itemtype = $itemtypes->next ) {
            push @authorised_values, $itemtype->itemtype;
            $authorised_lib{$itemtype->itemtype} = $itemtype->translated_description;
        }
    }
    else { # "true" authorised value
        $authorised_values_sth->execute(
            $tagslib->{$tag}->{$subfield}->{authorised_value}
        );
        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
            push @authorised_values, $value;
            $authorised_lib{$value} = $lib;
        }
    }

    return {
        type     => 'select',
        id       => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        name     => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        values   => \@authorised_values,
        labels   => \%authorised_lib,
        default  => $value,
        ( ( grep { $_ eq $category } ( qw(branches itemtypes cn_source) ) ) ? () : ( category => $category ) ),
    };
}

=item create_input

builds the <input ...> entry for a subfield.

=cut

sub create_input {
    my ( $tag, $subfield, $value, $index_tag, $rec, $authorised_values_sth, $cgi ) = @_;

    my $index_subfield = CreateKey(); # create a specifique key for each subfield

    # determine maximum length; 9999 bytes per ISO 2709 except for leader and MARC21 008
    my $max_length = 9999;
    if ($tag eq '000') {
        $max_length = 24;
    } elsif ($tag eq '008' and C4::Context->preference('marcflavour') eq 'MARC21')  {
        $max_length = 40;
    }

    # Apply optional framework default value when it is a new record,
    # or when editing as new (duplicating a record),
    # based on the ApplyFrameworkDefaults setting.
    # Substitute date parts, user name
    my $applydefaults = C4::Context->preference('ApplyFrameworkDefaults');
    if ( $value eq '' && (
        ( $applydefaults =~ /new/ && !$cgi->param('authid') ) ||
        ( $applydefaults =~ /duplicate/ && $cgi->param('op') eq 'duplicate' ) ||
        ( $applydefaults =~ /imported/ && $cgi->param('breedingid') )
    ) ) {
        $value = $tagslib->{$tag}->{$subfield}->{defaultvalue};
        if (!defined $value) {
            $value = q{};
        }

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
        marc_lib       => $tagslib->{$tag}->{$subfield}->{lib},
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
    
    $subfield_data{visibility} = "display:none;"
        if( $tagslib->{$tag}->{$subfield}->{hidden} and $value ne ''
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
        $subfield_data{marc_value} = {
            type         => 'text1',
            id           => $subfield_data{id},
            name         => $subfield_data{id},
            value        => $value,
            authtypecode => $tagslib->{$tag}->{$subfield}->{authtypecode},
        };
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) { # plugin
        require Koha::FrameworkPlugin;
        my $plugin = Koha::FrameworkPlugin->new({
            name => $tagslib->{$tag}->{$subfield}->{'value_builder'},
        });
        my $pars=  { dbh => $dbh, record => $rec, tagslib =>$tagslib,
            id => $subfield_data{id} };
        $plugin->build( $pars );
        if( !$plugin->errstr ) {
            $subfield_data{marc_value} = {
                type       => 'text2',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                maxlength => $max_length,
                javascript => $plugin->javascript,
                noclick    => $plugin->noclick,
            };
        } else { # warn and supply default field
            warn $plugin->errstr;
            $subfield_data{marc_value} = {
                type      => 'text',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                maxlength => $max_length,
            };
        }
    }
    # it's an hidden field
    elsif ( $tag eq '' ) {
        $subfield_data{marc_value} = {
            type      => 'hidden',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            maxlength => $max_length,
        }
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'hidden'} ) {
        $subfield_data{marc_value} = {
            type => 'text',
            id        => $subfield_data{id},
            name      => $subfield_data{id},
            value     => $value,
            maxlength => $max_length,
        };

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
            $subfield_data{marc_value} = {
                type => 'textarea',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                maxlength => $max_length,
            };

        }
        else {
            $subfield_data{marc_value} = {
                type => 'text',
                id        => $subfield_data{id},
                name      => $subfield_data{id},
                value     => $value,
                maxlength => $max_length,
            };

        }
    }
    if ($cgi->param('tagreport') && $subfield_data{tag} == $cgi->param('tagreport')) {
        $subfield_data{marc_value}{value} = $cgi->param('tag'. $cgi->param('tagbiblio') . 'subfield' . $subfield_data{subfield});
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

sub CreateKey {
    return int(rand(1000000));
}

=item GetMandatoryFieldZ3950

    This function returns a hashref which contains all mandatory field
    to search with z3950 server.

=cut

sub GetMandatoryFieldZ3950 {
    my $authtypecode = shift;
    if ( C4::Context->preference('marcflavour') eq 'MARC21' ){
        return {
            '100a' => 'authorpersonal',
            '110a' => 'authorcorp',
            '111a' => 'authormeetingcon',
            '130a' => 'uniformtitle',
            '150a' => 'subject',
        };
    }else{
        return {
            '200a' => 'authorpersonal',
            '210a' => 'authorcorp', #210 in UNIMARC is used for both corporation and meeting
            '230a' => 'uniformtitle',
        };
    }
}

sub build_tabs {
    my ( $template, $record, $dbh, $input ) = @_;

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
            if ( $record && ( $record->field($tag) || $tag eq '000' ) ) {
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
                        next if $tagslib->{$tag}->{$subfield}->{hidden} && $subfield ne '9';
                        push(
                            @subfields_data,
                            &create_input(
                                $tag, $subfield, $value, $index_tag, $record,
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
                            next if $tagslib->{$tag}->{$subfield}->{hidden} && $subfield ne '9';
                            push(
                                @subfields_data,
                                &create_input(
                                    $tag, $subfield, $value, $index_tag,
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
                        next if $tagslib->{$tag}->{$subfield}->{hidden} && $subfield ne '9';
                        next if ( defined( $field->subfield($subfield) ) );
                        push(
                            @subfields_data,
                            &create_input(
                                $tag, $subfield, '', $index_tag, $record,
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
                foreach my $subfield (
                    sort { $a->{display_order} <=> $b->{display_order} || $a->{subfield} cmp $b->{subfield} }
                    grep { ref($_) && %$_ } # Not a subfield (values for "important", "lib", "mandatory", etc.) or empty
                    values %{ $tagslib->{$tag} } )
                {
                    next if $subfield->{hidden} && $subfield->{subfield} ne '9';
                    next if ( $subfield->{tab} ne $tabloop );
                    push(
                        @subfields_data,
                        &create_input(
                            $tag, $subfield->{subfield}, '', $index_tag, $record,
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


sub build_hidden_data {
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
            $subfield_data{marc_value} = {
                type => 'hidden_simple',
                name => 'field_value[]',
            };
            push(@loop_data, \%subfield_data);
            $i++
        }
    }
}

=back

=cut


# ======================== 
#          MAIN 
#=========================
my $input = CGI->new;
my $z3950 = $input->param('z3950');
my $error = $input->param('error');
my $authid=$input->param('authid'); # if authid exists, it's a modif, not a new authority.
my $op = $input->param('op');
my $nonav = $input->param('nonav');
my $myindex = $input->param('index');
my $linkid=$input->param('linkid');
my $authtypecode = $input->param('authtypecode');
my $breedingid    = $input->param('breedingid');
my $changed_authtype = $input->param('changed_authtype') // q{};


my $dbh = C4::Context->dbh;
if(!$authtypecode) {
    $authtypecode = $authid ? Koha::Authorities->find($authid)->authtypecode : '';
}

my $authobj = Koha::Authorities->find($authid);
my $count = $authobj ? $authobj->get_usage_count : 0;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "authorities/authorities.tt",
                            query => $input,
                            type => "intranet",
                            flagsrequired => {editauthorities => 1},
                            });
$template->param(nonav   => $nonav,index=>$myindex,authtypecode=>$authtypecode,breedingid=>$breedingid, count=>$count);

$tagslib = GetTagsLabels(1,$authtypecode);
$mandatory_z3950 = GetMandatoryFieldZ3950($authtypecode);

my $record;
if ($breedingid) {
    my $import_record = Koha::Import::Records->find($breedingid);
    if ($import_record) {
        $record = $import_record->get_marc_record();
    }
} elsif ($authid) {
    $record = GetAuthority($authid);
}

my ($oldauthnumtagfield,$oldauthnumtagsubfield);
my ($oldauthtypetagfield,$oldauthtypetagsubfield);
$is_a_modif=0;
if ($authid) {
    $is_a_modif=1;
    ($oldauthnumtagfield,$oldauthnumtagsubfield) = GetAuthMARCFromKohaField("auth_header.authid",$authtypecode);
    ($oldauthtypetagfield,$oldauthtypetagsubfield) = GetAuthMARCFromKohaField("auth_header.authtypecode",$authtypecode);
}
$op ||= q{};
#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "add") {
#------------------------------------------------------------------------------------------------------------------------------
    # rebuild
    my @tags = $input->multi_param('tag');
    my @subfields = $input->multi_param('subfield');
    my @values = $input->multi_param('field_value');
    # build indicator hash.
    my @ind_tag = $input->multi_param('ind_tag');
    my @indicator = $input->multi_param('indicator');
    my $record = TransformHtmlToMarc($input, 0);

    my ($duplicateauthid,$duplicateauthvalue);
     ($duplicateauthid,$duplicateauthvalue) = FindDuplicateAuthority($record,$authtypecode) if ($op eq "add") && (!$is_a_modif);
    my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
    # it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
    if (!$duplicateauthid or $confirm_not_duplicate) {
        if ($is_a_modif ) {	
            ModAuthority($authid,$record,$authtypecode);
        } else {
            ($authid) = AddAuthority($record,$authid,$authtypecode);
        }
        if ($myindex) {
            print $input->redirect("blinddetail-biblio-search.pl?authid=$authid&index=$myindex");
        } else {
            print $input->redirect("detail.pl?authid=$authid");
        }
        exit;
    } else {
    # it may be a duplicate, warn the user and do nothing
        build_tabs($template, $record, $dbh, $input);
        build_hidden_data;
        $template->param(authid =>$authid,
                        duplicateauthid     => $duplicateauthid,
                        duplicateauthvalue  => $duplicateauthvalue->{'authorized'}->[0]->{'heading'},
                        );
    }
} elsif ($op eq "delete") {
#------------------------------------------------------------------------------------------------------------------------------
        DelAuthority({ authid => $authid });
        if ($nonav){
            print $input->redirect("auth_finder.pl");
        }else{
            print $input->redirect("authorities-home.pl?authid=0");
        }
                exit;
} else {
    if ( $op eq "duplicate" ) {
        $authid = "";
    }

    if ( $changed_authtype eq "changed" ) {
        $record = TransformHtmlToMarc( $input, 0 );
    }

    build_tabs( $template, $record, $dbh, $input );
    build_hidden_data;
    $template->param(
        oldauthtypetagfield    => $oldauthtypetagfield,
        oldauthtypetagsubfield => $oldauthtypetagsubfield,
        oldauthnumtagfield     => $oldauthnumtagfield,
        oldauthnumtagsubfield  => $oldauthnumtagsubfield,
        authid                 => $authid,
        authtypecode           => $authtypecode,
    );
}

my $authority_types = Koha::Authority::Types->search( {}, { order_by => ['authtypetext'] } );

my $type = $authority_types->find($authtypecode);
$template->param(
    authority_types => $authority_types,
    authtypecode    => $authtypecode,
    authid          => $authid,
    linkid          => $linkid,
    authtypetext    => $type ? $type->authtypetext : "",
    hide_marc       => C4::Context->preference('hide_marc'),
);
output_html_with_http_headers $input, $cookie, $template->output;
