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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use CGI;
use strict;
#use warnings; FIXME - Bug 2505
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Circulation;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use C4::Branch; # XXX subfield_is_koha_internal_p
use C4::BackgroundJob;
use C4::ClassSource;
use C4::Dates;
use C4::Debug;
use MARC::File::XML;

my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error        = $input->param('error');
my @itemnumbers  = $input->param('itemnumber');
my $biblionumber = $input->param('biblionumber');
my $op           = $input->param('op');
my $del          = $input->param('del');
my $del_records  = $input->param('del_records');
my $completedJobID = $input->param('completedJobID');
my $runinbackground = $input->param('runinbackground');
my $src          = $input->param('src');


my $template_name;
my $template_flag;
if (!defined $op) {
    $template_name = "tools/batchMod.tmpl";
    $template_flag = { tools => '*' };
    $op = q{};
} else {
    $template_name = ($del) ? "tools/batchMod-del.tmpl" : "tools/batchMod-edit.tmpl";
    $template_flag = ($del) ? { tools => 'items_batchdel' }   : { tools => 'items_batchmod' };
}


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => $template_name,
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => $template_flag,
                 });


my $today_iso = C4::Dates->today('iso');
$template->param(today_iso => $today_iso);
$template->param(del       => $del);

my $itemrecord;
my $nextop="";
my @errors; # store errors found while checking data BEFORE saving item.
my $items_display_hashref;
my $frameworkcode="";
my $tagslib = &GetMarcStructure(1,$frameworkcode);

my $deleted_items = 0;     # Number of deleted items
my $deleted_records = 0;   # Number of deleted records ( with no items attached )
my $not_deleted_items = 0; # Number of items that could not be deleted
my @not_deleted;           # List of the itemnumbers that could not be deleted

my %cookies = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;


#--- ----------------------------------------------------------------------------
if ($op eq "action") {
#-------------------------------------------------------------------------------
    my @tags      = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values    = $input->param('field_value');
    my @disabled  = $input->param('disable_input');
    # build indicator hash.
    my @ind_tag   = $input->param('ind_tag');
    my @indicator = $input->param('indicator');

    # Is there something to modify ?
    # TODO : We shall use this var to warn the user in case no modification was done to the items
    my $values_to_modify = scalar(grep {!/^$/} @values);
    my $values_to_blank  = scalar(@disabled);
    my $marcitem;

    # Once the job is done
    if ($completedJobID) {
	# If we have a reasonable amount of items, we display them
	if (scalar(@itemnumbers) <= 1000) {
	    $items_display_hashref=BuildItemsData(@itemnumbers);
	} else {
	    # Else, we only display the barcode
	    my @simple_items_display = map {{ itemnumber => $_, barcode => (GetBarcodeFromItemnumber($_) or ""), biblionumber => (GetBiblionumberFromItemnumber($_) or "") }} @itemnumbers;
	    $template->param("simple_items_display" => \@simple_items_display);
	}

	# Setting the job as done
	my $job = C4::BackgroundJob->fetch($sessionID, $completedJobID);

	# Calling the template
        add_saved_job_results_to_template($template, $completedJobID);

    } else {
    # While the job is getting done

	# Job size is the number of items we have to process
	my $job_size = scalar(@itemnumbers);
	my $job = undef;

	# If we asked for background processing
	if ($runinbackground) {
	    $job = put_in_background($job_size);
	}

	#initializing values for updates
	my (  $itemtagfield,   $itemtagsubfield) = &GetMarcFromKohaField("items.itemnumber", "");
	if ($values_to_modify){
	    my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag, 'ITEM');
        utf8::encode($xml);
	    $marcitem = MARC::Record::new_from_xml($xml, 'UTF-8');
        }
        if ($values_to_blank){
	    foreach my $disabledsubf (@disabled){
		if ($marcitem && $marcitem->field($itemtagfield)){
		    $marcitem->field($itemtagfield)->update( $disabledsubf => "" );
		}
		else {
		    $marcitem = MARC::Record->new();
		    $marcitem->append_fields( MARC::Field->new( $itemtagfield, '', '', $disabledsubf => "" ) );
		}
	    }
        }

	# For each item
	my $i = 1; 
	foreach my $itemnumber(@itemnumbers){

		$job->progress($i) if $runinbackground;
		my $itemdata = GetItem($itemnumber);
		if ($input->param("del")){
			my $return = DelItemCheck(C4::Context->dbh, $itemdata->{'biblionumber'}, $itemdata->{'itemnumber'});
			if ($return == 1) {
			    $deleted_items++;
			} else {
			    $not_deleted_items++;
			    push @not_deleted,
				{ biblionumber => $itemdata->{'biblionumber'},
				  itemnumber => $itemdata->{'itemnumber'},
				  barcode => $itemdata->{'barcode'},
				  title => $itemdata->{'title'},
				  $return => 1
				};
			}

			# If there are no items left, delete the biblio
			if ( $del_records ) {
                            my $itemscount = GetItemsCount($itemdata->{'biblionumber'});
                            if ( $itemscount == 0 ) {
			        my $error = DelBiblio($itemdata->{'biblionumber'});
			        $deleted_records++ unless ( $error );
                            }
                        }
		} else {
		    if ($values_to_modify || $values_to_blank) {
			my $localmarcitem = Item2Marc($itemdata);
			UpdateMarcWith( $marcitem, $localmarcitem );
			eval{
                            if ( my $item = ModItemFromMarc( $localmarcitem, $itemdata->{biblionumber}, $itemnumber ) ) {
                                LostItem($itemnumber, 'MARK RETURNED', 'CHARGE FEE') if $item->{itemlost};
                            }
                        };
		    }
		}
		$i++;
	}
    }
}
#
#-------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#-------------------------------------------------------------------------------

if ($op eq "show"){
    my $filefh = $input->upload('uploadfile');
    my $filecontent = $input->param('filecontent');
    my @notfoundbarcodes;

    my @contentlist;
    if ($filefh){
        while (my $content=<$filefh>){
            $content =~ s/[\r\n]*$//;
            push @contentlist, $content if $content;
        }

        if ($filecontent eq 'barcode_file') {
            foreach my $barcode (@contentlist) {

                my $itemnumber = GetItemnumberFromBarcode($barcode);
                if ($itemnumber) {
                    push @itemnumbers,$itemnumber;
                } else {
                    push @notfoundbarcodes, $barcode;
                }
            }
        }
        elsif ( $filecontent eq 'itemid_file') {
            @itemnumbers = @contentlist;
        }
    } else {
        if (defined $biblionumber){
            my @all_items = GetItemsInfo( $biblionumber );
            foreach my $itm (@all_items) {
                push @itemnumbers, $itm->{itemnumber};
            }
        }
        if ( my $list=$input->param('barcodelist')){
            push my @barcodelist, split(/\s\n/, $list);

            foreach my $barcode (@barcodelist) {

                my $itemnumber = GetItemnumberFromBarcode($barcode);
                if ($itemnumber) {
                    push @itemnumbers,$itemnumber;
                } else {
                    push @notfoundbarcodes, $barcode;
                }
            }

        }
    }

    # Flag to tell the template there are valid results, hidden or not
    if(scalar(@itemnumbers) > 0){ $template->param("itemresults" => 1); }
    # Only display the items if there are no more than 1000
    if (scalar(@itemnumbers) <= 1000) {
        $items_display_hashref=BuildItemsData(@itemnumbers);
    } else {
        $template->param("too_many_items" => scalar(@itemnumbers));
        # Even if we do not display the items, we need the itemnumbers
        my @itemnumbers_hashref = map {{itemnumber => $_}} @itemnumbers;
        $template->param("itemnumbers_hashref" => \@itemnumbers_hashref);
    }
# now, build the item form for entering a new item
my @loop_data =();
my $i=0;
my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
my $query = qq{SELECT authorised_value, lib FROM authorised_values};
$query  .= qq{ LEFT JOIN authorised_values_branches ON ( id = av_id ) } if $branch_limit;
$query  .= qq{ WHERE category = ?};
$query  .= qq{ AND ( branchcode = ? OR branchcode IS NULL ) } if $branch_limit;
$query  .= qq{ GROUP BY lib ORDER BY lib, lib_opac};
my $authorised_values_sth = $dbh->prepare( $query );

my $branches = GetBranchesLoop();  # build once ahead of time, instead of multiple times later.

# Adding a default choice, in case the user does not want to modify the branch
my $nochange_branch = { branchname => '', value => '', selected => 1 };
unshift (@$branches, $nochange_branch);

my $pref_itemcallnumber = C4::Context->preference('itemcallnumber');


foreach my $tag (sort keys %{$tagslib}) {
    # loop through each subfield
    foreach my $subfield (sort keys %{$tagslib->{$tag}}) {
     	next if subfield_is_koha_internal_p($subfield);
    	next if ($tagslib->{$tag}->{$subfield}->{'tab'} ne "10");
        # barcode and stocknumber are not meant to be batch-modified
    	next if $tagslib->{$tag}->{$subfield}->{'kohafield'} eq 'items.barcode';
    	next if $tagslib->{$tag}->{$subfield}->{'kohafield'} eq 'items.stocknumber';
	my %subfield_data;
 
	my $index_subfield = int(rand(1000000)); 
	if ($subfield eq '@'){
	    $subfield_data{id} = "tag_".$tag."_subfield_00_".$index_subfield;
	} else {
	    $subfield_data{id} = "tag_".$tag."_subfield_".$subfield."_".$index_subfield;
	}
	$subfield_data{tag}        = $tag;
	$subfield_data{subfield}   = $subfield;
	$subfield_data{random}     = int(rand(1000000));    # why do we need 2 different randoms?
    #   $subfield_data{marc_lib}   = $tagslib->{$tag}->{$subfield}->{lib};
	$subfield_data{marc_lib}   ="<span id=\"error$i\" title=\"".$tagslib->{$tag}->{$subfield}->{lib}."\">".$tagslib->{$tag}->{$subfield}->{lib}."</span>";
	$subfield_data{mandatory}  = $tagslib->{$tag}->{$subfield}->{mandatory};
	$subfield_data{repeatable} = $tagslib->{$tag}->{$subfield}->{repeatable};
	my ($x,$value);
	$value =~ s/"/&quot;/g;
	unless ($value) {
	    $value = $tagslib->{$tag}->{$subfield}->{defaultvalue};
	    # get today date & replace YYYY, MM, DD if provided in the default value
	    my ( $year, $month, $day ) = split ',', $today_iso;     # FIXME: iso dates don't have commas!
	    $value =~ s/YYYY/$year/g;
	    $value =~ s/MM/$month/g;
	    $value =~ s/DD/$day/g;
	}
	$subfield_data{visibility} = "display:none;" if (($tagslib->{$tag}->{$subfield}->{hidden} > 4) || ($tagslib->{$tag}->{$subfield}->{hidden} < -4));
	# testing branch value if IndependantBranches.

	my $attributes_no_value = qq(tabindex="1" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="67" maxlength="255" );
	my $attributes          = qq($attributes_no_value value="$value" );

	if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
	my @authorised_values;
	my %authorised_lib;
	# builds list, depending on authorised value...
  
	if ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "branches" ) {
	    foreach my $thisbranch (@$branches) {
		push @authorised_values, $thisbranch->{value};
		$authorised_lib{$thisbranch->{value}} = $thisbranch->{branchname};
	    }
        $value = "";
	}
	elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes" ) {
	    push @authorised_values, "";
	    my $sth = $dbh->prepare("select itemtype,description from itemtypes order by description");
	    $sth->execute;
	    while ( my ( $itemtype, $description ) = $sth->fetchrow_array ) {
		push @authorised_values, $itemtype;
		$authorised_lib{$itemtype} = $description;
	    }
        $value = "";

          #---- class_sources
      }
      elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "cn_source" ) {
          push @authorised_values, "" unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
            
          my $class_sources = GetClassSources();
          my $default_source = C4::Context->preference("DefaultClassificationSource");
          
          foreach my $class_source (sort keys %$class_sources) {
              next unless $class_sources->{$class_source}->{'used'} or
                          ($value and $class_source eq $value)      or
                          ($class_source eq $default_source);
              push @authorised_values, $class_source;
              $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
          }
		  $value = '';

          #---- "true" authorised value
      }
      else {
          push @authorised_values, ""; # unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
          $authorised_values_sth->execute( $tagslib->{$tag}->{$subfield}->{authorised_value}, $branch_limit ? $branch_limit : () );
          while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
              push @authorised_values, $value;
              $authorised_lib{$value} = $lib;
          }
          $value="";
      }
      $subfield_data{marc_value} =CGI::scrolling_list(      # FIXME: factor out scrolling_list
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
        $subfield_data{marc_value} = "<input type=\"text\" $attributes />
            <a href=\"#\" class=\"buttonDot\"
                onclick=\"Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&index=$subfield_data{id}','$subfield_data{id}'); return false;\" title=\"Tag Editor\">...</a>
    ";
    # it's a plugin field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{value_builder} ) {
        # opening plugin
        my $plugin = C4::Context->intranetdir . "/cataloguing/value_builder/" . $tagslib->{$tag}->{$subfield}->{'value_builder'};
        if (do $plugin) {
			my $temp;
            my $extended_param = plugin_parameters( $dbh, $temp, $tagslib, $subfield_data{id}, \@loop_data );
            my ( $function_name, $javascript ) = plugin_javascript( $dbh, $temp, $tagslib, $subfield_data{id}, \@loop_data );
            $subfield_data{marc_value} = qq[<input type="text" $attributes
                onfocus="Focus$function_name($subfield_data{random}, '$subfield_data{id}');"
                 onblur=" Blur$function_name($subfield_data{random}, '$subfield_data{id}');" />
                <a href="#" class="buttonDot" onclick="Clic$function_name('$subfield_data{id}'); return false;" title="Tag Editor">...</a>
                $javascript];
        } else {
            warn "Plugin Failed: $plugin";
            $subfield_data{marc_value} = "<input type=\"text\" $attributes />"; # supply default input form
        }
    }
    elsif ( $tag eq '' ) {       # it's an hidden field
        $subfield_data{marc_value} = qq(<input type="hidden" $attributes />);
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'hidden'} ) {   # FIXME: shouldn't input type be "hidden" ?
        $subfield_data{marc_value} = qq(<input type="text" $attributes />);
    }
    elsif ( length($value) > 100
            or (C4::Context->preference("marcflavour") eq "UNIMARC" and
                  300 <= $tag && $tag < 400 && $subfield eq 'a' )
            or (C4::Context->preference("marcflavour") eq "MARC21"  and
                  500 <= $tag && $tag < 600                     )
          ) {
        # oversize field (textarea)
        $subfield_data{marc_value} = "<textarea $attributes_no_value>$value</textarea>\n";
    } else {
        # it's a standard field
         $subfield_data{marc_value} = "<input type=\"text\" $attributes />";
    }
#   $subfield_data{marc_value}="<input type=\"text\" name=\"field_value\">";
    push (@loop_data, \%subfield_data);
    $i++
  }
} # -- End foreach tag
$authorised_values_sth->finish;



    # what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
    $template->param(item => \@loop_data);
    if (@notfoundbarcodes) { 
	my @notfoundbarcodesloop = map{{barcode=>$_}}@notfoundbarcodes;
    	$template->param(notfoundbarcodes => \@notfoundbarcodesloop);
    }
    $nextop="action"
} # -- End action="show"

$template->param(%$items_display_hashref) if $items_display_hashref;
$template->param(
    op      => $nextop,
);
$template->param( $op => 1 ) if $op;

if ($op eq "action") {

    #my @not_deleted_loop = map{{itemnumber=>$_}}@not_deleted;

    $template->param(
	not_deleted_items => $not_deleted_items,
	deleted_items => $deleted_items,
	delete_records => $del_records,
	deleted_records => $deleted_records,
	not_deleted_loop => \@not_deleted 
    );
}

foreach my $error (@errors) {
    $template->param($error => 1) if $error;
}
$template->param(src => $src);
$template->param(biblionumber => $biblionumber);
output_html_with_http_headers $input, $cookie, $template->output;
exit;


# ---------------- Functions

sub BuildItemsData{
	my @itemnumbers=@_;
		# now, build existiing item list
		my %witness; #---- stores the list of subfields used at least once, with the "meaning" of the code
		my @big_array;
		#---- finds where items.itemnumber is stored
		my (  $itemtagfield,   $itemtagsubfield) = &GetMarcFromKohaField("items.itemnumber", "");
		my ($branchtagfield, $branchtagsubfield) = &GetMarcFromKohaField("items.homebranch", "");
		foreach my $itemnumber (@itemnumbers){
			my $itemdata=GetItem($itemnumber);
			my $itemmarc=Item2Marc($itemdata);
			my %this_row;
			foreach my $field (grep {$_->tag() eq $itemtagfield} $itemmarc->fields()) {
				# loop through each subfield
				my $itembranchcode=$field->subfield($branchtagsubfield);
				if ($itembranchcode && C4::Context->preference("IndependantBranches")) {
						#verifying rights
						my $userenv = C4::Context->userenv();
						unless (($userenv->{'flags'} == 1) or (($userenv->{'branch'} eq $itembranchcode))){
								$this_row{'nomod'}=1;
						}
				}
				my $tag=$field->tag();
				foreach my $subfield ($field->subfields) {
					my ($subfcode,$subfvalue)=@$subfield;
					next if ($tagslib->{$tag}->{$subfcode}->{tab} ne 10 
							&& $tag        ne $itemtagfield 
							&& $subfcode   ne $itemtagsubfield);

					$witness{$subfcode} = $tagslib->{$tag}->{$subfcode}->{lib} if ($tagslib->{$tag}->{$subfcode}->{tab}  eq 10);
					if ($tagslib->{$tag}->{$subfcode}->{tab}  eq 10) {
						$this_row{$subfcode}=GetAuthorisedValueDesc( $tag,
									$subfcode, $subfvalue, '', $tagslib) 
									|| $subfvalue;
					}

					$this_row{itemnumber} = $subfvalue if ($tag eq $itemtagfield && $subfcode eq $itemtagsubfield);
				}
			}

            # grab title, author, and ISBN to identify bib that the item
            # belongs to in the display
			 my $biblio=GetBiblioData($$itemdata{biblionumber});
            $this_row{title} = $biblio->{title};
            $this_row{author} = $biblio->{author};
            $this_row{isbn} = $biblio->{isbn};
            $this_row{biblionumber} = $biblio->{biblionumber};

			if (%this_row) {
				push(@big_array, \%this_row);
			}
		}
		@big_array = sort {$a->{0} cmp $b->{0}} @big_array;

		# now, construct template !
		# First, the existing items for display
		my @item_value_loop;
		my @witnesscodessorted=sort keys %witness;
		for my $row ( @big_array ) {
			my %row_data;
			my @item_fields = map +{ field => $_ || '' }, @$row{ @witnesscodessorted };
			$row_data{item_value} = [ @item_fields ];
			$row_data{itemnumber} = $row->{itemnumber};
			#reporting this_row values
			$row_data{'nomod'} = $row->{'nomod'};
      $row_data{bibinfo} = $row->{bibinfo};
      $row_data{author} = $row->{author};
      $row_data{title} = $row->{title};
      $row_data{isbn} = $row->{isbn};
      $row_data{biblionumber} = $row->{biblionumber};
			push(@item_value_loop,\%row_data);
		}
		my @header_loop=map { { header_value=> $witness{$_}} } @witnesscodessorted;

	return { item_loop        => \@item_value_loop, item_header_loop => \@header_loop };
}

#BE WARN : it is not the general case 
# This function can be OK in the item marc record special case
# Where subfield is not repeated
# And where we are sure that field should correspond
# And $tag>10
sub UpdateMarcWith {
  my ($marcfrom,$marcto)=@_;
  #warn "FROM :",$marcfrom->as_formatted;
	my (  $itemtag,   $itemtagsubfield) = &GetMarcFromKohaField("items.itemnumber", "");
	my $fieldfrom=$marcfrom->field($itemtag);
	my @fields_to=$marcto->field($itemtag);
    foreach my $subfield ($fieldfrom->subfields()){
		foreach my $field_to_update (@fields_to){
		    if ($subfield->[1]){
			$field_to_update->update($subfield->[0]=>$subfield->[1]);
		    }
		    else {
			$field_to_update->delete_subfield(code=> $subfield->[0]);
		    }
		}
    }
  #warn "TO edited:",$marcto->as_formatted;
}

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

# ----------------------------
# Background functions


sub add_results_to_template {
    my $template = shift;
    my $results = shift;
    $template->param(map { $_ => $results->{$_} } keys %{ $results });
}

sub add_saved_job_results_to_template {
    my $template = shift;
    my $completedJobID = shift;
    my $job = C4::BackgroundJob->fetch($sessionID, $completedJobID);
    my $results = $job->results();
    add_results_to_template($template, $results);
}

sub put_in_background {
    my $job_size = shift;

    my $job = C4::BackgroundJob->new($sessionID, "test", $ENV{'SCRIPT_NAME'}, $job_size);
    my $jobID = $job->id();

    # fork off
    if (my $pid = fork) {
        # parent
        # return job ID as JSON

        # prevent parent exiting from
        # destroying the kid's database handle
        # FIXME: according to DBI doc, this may not work for Oracle
        $dbh->{InactiveDestroy}  = 1;

        my $reply = CGI->new("");
        print $reply->header(-type => 'text/html');
        print '{"jobID":"' . $jobID . '"}';
        exit 0;
    } elsif (defined $pid) {
        # child
        # close STDOUT to signal to Apache that
        # we're now running in the background
        close STDOUT;
        close STDERR;
    } else {
        # fork failed, so exit immediately
        warn "fork failed while attempting to run $ENV{'SCRIPT_NAME'} as a background job";
        exit 0;
    }
    return $job;
}



