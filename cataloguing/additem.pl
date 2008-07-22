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

use CGI;
use strict;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use C4::Branch; # XXX subfield_is_koha_internal_p
use C4::ClassSource;

use Date::Calc qw(Today);

use MARC::File::XML;

sub find_value {
    my ($tagfield,$insubfield,$record) = @_;
    my $result;
    my $indicator;
    foreach my $field ($record->field($tagfield)) {
        my @subfields = $field->subfields();
        foreach my $subfield (@subfields) {
            if (@$subfield[0] eq $insubfield) {
                $result .= @$subfield[1];
                $indicator = $field->indicator(1).$field->indicator(2);
            }
        }
    }
    return($indicator,$result);
}

sub get_item_from_barcode {
    my ($barcode)=@_;
    my $dbh=C4::Context->dbh;
    my $result;
    my $rq=$dbh->prepare("SELECT itemnumber from items where items.barcode=?");
    $rq->execute($barcode);
    ($result)=$rq->fetchrow;
    return($result);
}

my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error = $input->param('error');
my $biblionumber = $input->param('biblionumber');
my $itemnumber = $input->param('itemnumber');
my $op = $input->param('op');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/additem.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {editcatalogue => 1},
                 debug => 1,
                 });

# find itemtype
my $frameworkcode = &GetFrameworkCode($biblionumber);

my $tagslib = &GetMarcStructure(1,$frameworkcode);
my $record = GetMarcBiblio($biblionumber);
my $oldrecord = TransformMarcToKoha($dbh,$record);
my $itemrecord;
my $nextop="additem";
my @errors; # store errors found while checking data BEFORE saving item.
#-------------------------------------------------------------------------------
if ($op eq "additem") {
#-------------------------------------------------------------------------------
    # rebuild
    my @tags = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values = $input->param('field_value');
    # build indicator hash.
    my @ind_tag = $input->param('ind_tag');
    my @indicator = $input->param('indicator');
    my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag, 'ITEM');
        my $record=MARC::Record::new_from_xml($xml, 'UTF-8');
    # if autoBarcode is set to 'incremental', calculate barcode...
	# NOTE: This code is subject to change in 3.2 with the implemenation of ajax based autobarcode code
	# NOTE: 'incremental' is the ONLY autoBarcode option available to those not using javascript
    if (C4::Context->preference('autoBarcode') eq 'incremental') {
        my ($tagfield,$tagsubfield) = &GetMarcFromKohaField("items.barcode",$frameworkcode);
        unless ($record->field($tagfield)->subfield($tagsubfield)) {
            my $sth_barcode = $dbh->prepare("select max(abs(barcode)) from items");
            $sth_barcode->execute;
            my ($newbarcode) = $sth_barcode->fetchrow;
            $newbarcode++;
            # OK, we have the new barcode, now create the entry in MARC record
            my $fieldItem = $record->field($tagfield);
            $record->delete_field($fieldItem);
            $fieldItem->add_subfields($tagsubfield => $newbarcode);
            $record->insert_fields_ordered($fieldItem);
        }
    }
# check for item barcode # being unique
    my $addedolditem = TransformMarcToKoha($dbh,$record);
    my $exist_itemnumber = get_item_from_barcode($addedolditem->{'barcode'});
    push @errors,"barcode_not_unique" if($exist_itemnumber);
    # if barcode exists, don't create, but report The problem.
    my ($oldbiblionumber,$oldbibnum,$oldbibitemnum) = AddItemFromMarc($record,$biblionumber) unless ($exist_itemnumber);
    if ($exist_itemnumber) {
        $nextop = "additem";
        $itemrecord = $record;
    } else {
        $nextop = "additem";
    }
#-------------------------------------------------------------------------------
} elsif ($op eq "edititem") {
#-------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
    $itemrecord = C4::Items::GetMarcItem($biblionumber,$itemnumber);
    $nextop="saveitem";
#-------------------------------------------------------------------------------
} elsif ($op eq "delitem") {
#-------------------------------------------------------------------------------
    # check that there is no issue on this item before deletion.
    my $sth=$dbh->prepare("select * from issues i where i.itemnumber=?");
    $sth->execute($itemnumber);
    my $onloan=$sth->fetchrow;
	$sth->finish();
    push @errors,"book_on_loan" if ($onloan); ##error book_on_loan added to template as well
    if ($onloan){
		$nextop="additem";
    } else {
		# check it doesnt have a waiting reserve
		$sth=$dbh->prepare("SELECT * FROM reserves WHERE found = 'W' AND itemnumber = ?");
		$sth->execute($itemnumber);
		my $reserve=$sth->fetchrow;
		if ($reserve){
			push @errors,"book_reserved";
			$nextop="additem";
		}
		else {
			&DelItem($dbh,$biblionumber,$itemnumber);
			print $input->redirect("additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode");
		}
    }
#-------------------------------------------------------------------------------
} elsif ($op eq "saveitem") {
#-------------------------------------------------------------------------------
    # rebuild
    my @tags = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values = $input->param('field_value');
    # build indicator hash.
    my @ind_tag = $input->param('ind_tag');
    my @indicator = $input->param('indicator');
    #    my $itemnumber = $input->param('itemnumber');
    my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag,'ITEM');
    my $itemtosave=MARC::Record::new_from_xml($xml, 'UTF-8');
    # MARC::Record builded => now, record in DB
    # warn "R: ".$record->as_formatted;
    # check that the barcode don't exist already
    my $addedolditem = TransformMarcToKoha($dbh,$itemtosave);
    my $exist_itemnumber = get_item_from_barcode($addedolditem->{'barcode'});
    if ($exist_itemnumber && $exist_itemnumber != $itemnumber) {
        push @errors,"barcode_not_unique";
    } else {
        my ($oldbiblionumber,$oldbibnum,$oldbibitemnum) = ModItemFromMarc($itemtosave,$biblionumber,$itemnumber);
    $itemnumber="";
    }
    $nextop="additem";
}

#
#-------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#-------------------------------------------------------------------------------

# now, build existiing item list
my $temp = GetMarcBiblio( $biblionumber );
my @fields = $temp->fields();
#my @fields = $record->fields();
my %witness; #---- stores the list of subfields used at least once, with the "meaning" of the code
my @big_array;
#---- finds where items.itemnumber is stored
my ($itemtagfield,$itemtagsubfield) = &GetMarcFromKohaField("items.itemnumber",$frameworkcode);
my ($branchtagfield,$branchtagsubfield) = &GetMarcFromKohaField("items.homebranch",$frameworkcode);

foreach my $field (@fields) {
    next if ($field->tag()<10);
    my @subf=$field->subfields;
    my %this_row;
# loop through each subfield
    for my $i (0..$#subf) {
        next if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab} ne 10 
                && ($field->tag() ne $itemtagfield 
                && $subf[$i][0] ne $itemtagsubfield));

        $witness{$subf[$i][0]} = $tagslib->{$field->tag()}->{$subf[$i][0]}->{lib} if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab}  eq 10);

        $this_row{$subf[$i][0]}=GetAuthorisedValueDesc( $field->tag(),
                        $subf[$i][0], $subf[$i][1], '', $tagslib) if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab}  eq 10);
        
        if (($field->tag eq $branchtagfield) && ($subf[$i][$0] eq $branchtagsubfield) && C4::Context->preference("IndependantBranches")) {
            #verifying rights
            my $userenv = C4::Context->userenv();
            unless (($userenv->{'flags'} == 1) or (($userenv->{'branch'} eq $subf[$i][1]))){
                    $this_row{'nomod'}=1;
            }
        }
        $this_row{itemnumber} = $subf[$i][1] if ($field->tag() eq $itemtagfield && $subf[$i][0] eq $itemtagsubfield);
    }
    if (%this_row) {
        push(@big_array, \%this_row);
    }
}
#fill big_row with missing data
foreach my $subfield_code  (keys(%witness)) {
    for (my $i=0;$i<=$#big_array;$i++) {
        $big_array[$i]{$subfield_code}="&nbsp;" unless ($big_array[$i]{$subfield_code});
    }
}
my ($holdingbrtagf,$holdingbrtagsubf) = &GetMarcFromKohaField("items.holdingbranch",$frameworkcode);
@big_array = sort {$a->{$holdingbrtagsubf} cmp $b->{$holdingbrtagsubf}} @big_array;

# now, construct template !
# First, the existing items for display
my @item_value_loop;
my @header_value_loop;
for (my $i=0;$i<=$#big_array; $i++) {
    my $items_data;
    foreach my $subfield_code (sort keys(%witness)) {
        $items_data .="<td>".$big_array[$i]{$subfield_code}."</td>";
    }
    my %row_data;
    $items_data =~ s/"/&quot;/g;
    $row_data{item_value} = $items_data;
    $row_data{itemnumber} = $big_array[$i]->{itemnumber};
    #reporting this_row values
    $row_data{'nomod'} = $big_array[$i]{'nomod'};
    push(@item_value_loop,\%row_data);
}
foreach my $subfield_code (sort keys(%witness)) {
    my %header_value;
    $header_value{header_value} = $witness{$subfield_code};
    push(@header_value_loop, \%header_value);
}

# now, build the item form for entering a new item
my @loop_data =();
my $i=0;
my $authorised_values_sth = $dbh->prepare("SELECT authorised_value,lib FROM authorised_values WHERE category=? ORDER BY lib");

foreach my $tag (sort keys %{$tagslib}) {
  my $previous_tag = '';
# loop through each subfield
  foreach my $subfield (sort keys %{$tagslib->{$tag}}) {
    next if subfield_is_koha_internal_p($subfield);
    next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "10");
    my %subfield_data;
 
    my $index_subfield= int(rand(1000000)); 
    if($subfield eq '@'){
        $subfield_data{id} = "tag_".$tag."_subfield_00_".$index_subfield;
    } else {
         $subfield_data{id} = "tag_".$tag."_subfield_".$subfield."_".$index_subfield;
    }
    $subfield_data{tag}=$tag;
    $subfield_data{subfield}=$subfield;
    $subfield_data{random}=int(rand(1000000)); 
#        $subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
    $subfield_data{marc_lib}="<span id=\"error$i\" title=\"".$tagslib->{$tag}->{$subfield}->{lib}."\">".$tagslib->{$tag}->{$subfield}->{lib}."</span>";
    $subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
    $subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
    my ($x,$value);
    ($x,$value) = find_value($tag,$subfield,$itemrecord) if ($itemrecord);
    $value =~ s/"/&quot;/g;
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
    $subfield_data{visibility} = "display:none;" if (($tagslib->{$tag}->{$subfield}->{hidden} > 4) || ($tagslib->{$tag}->{$subfield}->{hidden} < -4));
    #testing branch value if IndependantBranches.
    my $test = (C4::Context->preference("IndependantBranches")) &&
              ($tag eq $branchtagfield) && ($subfield eq $branchtagsubfield) &&
              (C4::Context->userenv->{flags} != 1) && ($value) && ($value ne C4::Context->userenv->{branch}) ;
#         print $input->redirect(".pl?biblionumber=$biblionumber") if ($test);
        # search for itemcallnumber if applicable
    if (!$value && $tagslib->{$tag}->{$subfield}->{kohafield} eq 'items.itemcallnumber' && C4::Context->preference('itemcallnumber')) {
        my $CNtag = substr(C4::Context->preference('itemcallnumber'),0,3);
        my $CNsubfield = substr(C4::Context->preference('itemcallnumber'),3,1);
        my $CNsubfield2 = substr(C4::Context->preference('itemcallnumber'),4,1);
        my $temp2 = $temp->field($CNtag);
        if ($temp2) {
                $value = ($temp2->subfield($CNsubfield)).' '.($temp2->subfield($CNsubfield2));
#remove any trailing space incase one subfield is used
        $value=~s/^\s+|\s+$//g;
      }
    }
    if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
      my @authorised_values;
      my %authorised_lib;
      my $dbh=C4::Context->dbh;   
  
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
      $subfield_data{marc_value} =CGI::scrolling_list(
          -name     => "field_value",
          -values   => \@authorised_values,
          -default  => $value,
          -labels   => \%authorised_lib,
          -override => 1,
          -size     => 1,
          -multiple => 0,
          -tabindex => 1,
          -id       => "tag_".$tag."_subfield_".$subfield."_".$index_subfield,
          -class    => "input_marceditor",
      );
    # it's a thesaurus / authority field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authtypecode} ) {
        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"field_value\"
                    value=\"$value\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"67\"
                    maxlength=\"255\" 
                    \/>
                    <a href=\"#\" class=\"buttonDot\"
                        onclick=\"Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&index=$subfield_data{id}','$subfield_data{id}'); return false;\" title=\"Tag Editor\">...</a>
    ";
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
            my $extended_param = plugin_parameters( $dbh, $temp, $tagslib, $subfield_data{id}, \@loop_data );
            my ( $function_name, $javascript ) = plugin_javascript( $dbh, $temp, $tagslib, $subfield_data{id}, \@loop_data );
        
            $subfield_data{marc_value} =
                    "<input tabindex=\"1\"
                            type=\"text\"
                            id=\"".$subfield_data{id}."\"
                            name=\"field_value\"
                            value=\"$value\"
                            class=\"input_marceditor\"
                            onfocus=\"Focus$function_name(".$subfield_data{random}.")\"
                            size=\"67\"
                            maxlength=\"255\" 
                            onblur=\"Blur$function_name(".$subfield_data{random}."); \" \/>
                            <a href=\"#\" class=\"buttonDot\" onclick=\"Clic$function_name('$subfield_data{id}'); return false;\" title=\"Tag Editor\">...</a>
                    $javascript";
        } else {
            warn "Plugin Failed: $plugin";
            # supply default input form
            $subfield_data{marc_value} =
                "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"field_value\"
                        value=\"$value\"
                        tabindex=\"1\"
                        size=\"67\"
                        maxlength=\"255\" 
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
                    name=\"field_value\"
                    size=\"67\"
                    maxlength=\"255\" 
                    value=\"$value\" \/>
            ";
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'hidden'} ) {
        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=\"".$subfield_data{id}."\"
                    name=\"field_value\"
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    size=\"67\"
                    maxlength=\"255\" 
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
                           name=\"field_value\"
                           class=\"input_marceditor\"
                           tabindex=\"1\"
                            size=\"67\"
                            maxlength=\"255\" 
                           >$value</textarea>
                ";
        }
        else {
            $subfield_data{marc_value} =
                "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"field_value\"
                        value=\"$value\"
                        tabindex=\"1\"
                        size=\"67\"
                        maxlength=\"255\" 
                        class=\"input_marceditor\"
                \/>
                ";
        }
    }
#        $subfield_data{marc_value}="<input type=\"text\" name=\"field_value\">";
        push(@loop_data, \%subfield_data);
        $i++
    }
}

# what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
$template->param( title => $record->title() ) if ($record ne "-1");
$template->param(item_loop => \@item_value_loop,
                        item_header_loop => \@header_value_loop,
                        biblionumber => $biblionumber,
                        title => $oldrecord->{title},
                        author => $oldrecord->{author},
                        item => \@loop_data,
                        itemnumber => $itemnumber,
                        itemtagfield => $itemtagfield,
                        itemtagsubfield =>$itemtagsubfield,
                        op => $nextop,
                        opisadd => ($nextop eq "saveitem")?0:1);
foreach my $error (@errors) {
    $template->param($error => 1);
}
output_html_with_http_headers $input, $cookie, $template->output;
