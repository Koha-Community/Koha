#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2004-2010 BibLibre
# Parts Copyright Catalyst IT 2011
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
use C4::Auth qw( get_template_and_user haspermission );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Biblio qw(
    GetFrameworkCode
    GetMarcBiblio
    GetMarcFromKohaField
    GetMarcStructure
    IsMarcStructureInternal
    ModBiblio
);
use C4::Context;
use C4::Circulation qw( LostItem );
use C4::Koha qw( GetAuthorisedValues );
use C4::ClassSource qw( GetClassSources GetClassSource );
use C4::Barcodes;
use C4::Barcodes::ValueBuilder;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::ItemTypes;
use Koha::Libraries;
use Koha::Patrons;
use Koha::SearchEngine::Indexer;
use C4::Search qw( enabled_staff_search_views );
use Storable qw( freeze thaw );
use URI::Escape qw( uri_escape_utf8 );
use C4::Members;

use MARC::File::XML;
use URI::Escape qw( uri_escape_utf8 );
use MIME::Base64 qw( decode_base64url encode_base64url );
use List::Util qw( first );
use List::MoreUtils qw( any uniq );

our $dbh = C4::Context->dbh;

sub generate_subfield_form {
        my ($tag, $subfieldtag, $value, $tagslib,$subfieldlib, $branches, $biblionumber, $temp, $subfields, $i, $restrictededition, $item) = @_;
  
        my $frameworkcode = &GetFrameworkCode($biblionumber);

        $item //= {};

        my %subfield_data;
        my $dbh = C4::Context->dbh;
        
        my $index_subfield = int(rand(1000000)); 
        if ($subfieldtag eq '@'){
            $subfield_data{id} = "tag_".$tag."_subfield_00_".$index_subfield;
        } else {
            $subfield_data{id} = "tag_".$tag."_subfield_".$subfieldtag."_".$index_subfield;
        }
        
        $subfield_data{tag}        = $tag;
        $subfield_data{subfield}   = $subfieldtag;
        $subfield_data{marc_lib}   ="<span id=\"error$i\" title=\"".$subfieldlib->{lib}."\">".$subfieldlib->{lib}."</span>";
        $subfield_data{mandatory}  = $subfieldlib->{mandatory};
        $subfield_data{important}  = $subfieldlib->{important};
        $subfield_data{repeatable} = $subfieldlib->{repeatable};
        $subfield_data{maxlength}  = $subfieldlib->{maxlength};
        $subfield_data{display_order} = $subfieldlib->{display_order};
        $subfield_data{kohafield}  = $subfieldlib->{kohafield} || 'items.more_subfields_xml';
        
        if ( ! defined( $value ) || $value eq '')  {
            $value = $subfieldlib->{defaultvalue};
            if ( $value ) {
                # get today date & replace <<YYYY>>, <<YY>>, <<MM>>, <<DD>> if provided in the default value
                my $today_dt = dt_from_string;
                my $year = $today_dt->strftime('%Y');
                my $shortyear = $today_dt->strftime('%y');
                my $month = $today_dt->strftime('%m');
                my $day = $today_dt->strftime('%d');
                $value =~ s/<<YYYY>>/$year/g;
                $value =~ s/<<YY>>/$shortyear/g;
                $value =~ s/<<MM>>/$month/g;
                $value =~ s/<<DD>>/$day/g;
                # And <<USER>> with surname (?)
                my $username=(C4::Context->userenv?C4::Context->userenv->{'surname'}:"superlibrarian");
                $value=~s/<<USER>>/$username/g;
            }
        }

        $subfield_data{visibility} = "display:none;" if (($subfieldlib->{hidden} > 4) || ($subfieldlib->{hidden} <= -4));

        my $pref_itemcallnumber = C4::Context->preference('itemcallnumber');
        if (!$value && $subfieldlib->{kohafield} eq 'items.itemcallnumber' && $pref_itemcallnumber) {
            foreach my $pref_itemcallnumber_part (split(/,/, $pref_itemcallnumber)){
                my $CNtag       = substr( $pref_itemcallnumber_part, 0, 3 ); # 3-digit tag number
                my $CNsubfields = substr( $pref_itemcallnumber_part, 3 ); # Any and all subfields
                $CNsubfields = undef if $CNsubfields eq '';
                my $temp2 = $temp->field($CNtag);

                next unless $temp2;
                $value = $temp2->as_string( $CNsubfields, ' ' );
                last if $value;
            }
        }

        my $default_location = C4::Context->preference('NewItemsDefaultLocation');
        if ( !$value && $subfieldlib->{kohafield} eq 'items.location' && $default_location ) {
            $value = $default_location;
        }

        if ($frameworkcode eq 'FA' && $subfieldlib->{kohafield} eq 'items.barcode' && !$value){
	    my $input = CGI->new;
	    $value = $input->param('barcode');
	}

        if ( $subfieldlib->{authorised_value} ) {
            my @authorised_values;
            my %authorised_lib;
            # builds list, depending on authorised value...
            if ( $subfieldlib->{authorised_value} eq "LOST" ) {
                my $ClaimReturnedLostValue = C4::Context->preference('ClaimReturnedLostValue');
                my $item_is_return_claim = $ClaimReturnedLostValue && exists $item->{itemlost} && $ClaimReturnedLostValue eq $item->{itemlost};
                $subfield_data{IS_RETURN_CLAIM} = $item_is_return_claim;

                $subfield_data{IS_LOST_AV} = 1;

                push @authorised_values, qq{};
                my $av = GetAuthorisedValues( $subfieldlib->{authorised_value} );
                for my $r ( @$av ) {
                    push @authorised_values, $r->{authorised_value};
                    $authorised_lib{$r->{authorised_value}} = $r->{lib};
                }
            }
            elsif ( $subfieldlib->{authorised_value} eq "branches" ) {
                foreach my $thisbranch (@$branches) {
                    push @authorised_values, $thisbranch->{branchcode};
                    $authorised_lib{$thisbranch->{branchcode}} = $thisbranch->{branchname};
                    $value = $thisbranch->{branchcode} if $thisbranch->{selected} && !$value;
                }
            }
            elsif ( $subfieldlib->{authorised_value} eq "itemtypes" ) {
                  push @authorised_values, "";
                  my $branch_limit = C4::Context->userenv && C4::Context->userenv->{"branch"};
                  my $itemtypes;
                  if($branch_limit) {
                      $itemtypes = Koha::ItemTypes->search_with_localization({branchcode => $branch_limit});
                  } else {
                      $itemtypes = Koha::ItemTypes->search_with_localization;
                  }
                  while ( my $itemtype = $itemtypes->next ) {
                      push @authorised_values, $itemtype->itemtype;
                      $authorised_lib{$itemtype->itemtype} = $itemtype->translated_description;
                  }

                  unless ( $value ) {
                      my $itype_sth = $dbh->prepare("SELECT itemtype FROM biblioitems WHERE biblionumber = ?");
                      $itype_sth->execute( $biblionumber );
                      ( $value ) = $itype_sth->fetchrow_array;
                  }
          
                  #---- class_sources
            }
            elsif ( $subfieldlib->{authorised_value} eq "cn_source" ) {
                  push @authorised_values, "";
                    
                  my $class_sources = GetClassSources();
                  my $default_source = C4::Context->preference("DefaultClassificationSource");
                  
                  foreach my $class_source (sort keys %$class_sources) {
                      next unless $class_sources->{$class_source}->{'used'} or
                                  ($value and $class_source eq $value)      or
                                  ($class_source eq $default_source);
                      push @authorised_values, $class_source;
                      $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
                  }
        		  $value = $default_source unless ($value);
        
                  #---- "true" authorised value
            }
            else {
                  push @authorised_values, qq{};
                  my $av = GetAuthorisedValues( $subfieldlib->{authorised_value} );
                  for my $r ( @$av ) {
                      push @authorised_values, $r->{authorised_value};
                      $authorised_lib{$r->{authorised_value}} = $r->{lib};
                  }
            }

            if ( $subfieldlib->{hidden} > 4 or $subfieldlib->{hidden} <= -4 ) {
                $subfield_data{marc_value} = {
                    type        => 'hidden',
                    id          => $subfield_data{id},
                    maxlength   => $subfield_data{maxlength},
                    value       => $value,
                    ( ( grep { $_ eq $subfieldlib->{authorised_value}} ( qw(branches itemtypes cn_source) ) ) ? () : ( category => $subfieldlib->{authorised_value}) ),
                };
            }
            else {
                $subfield_data{marc_value} = {
                    type     => 'select',
                    id       => "tag_".$tag."_subfield_".$subfieldtag."_".$index_subfield,
                    values   => \@authorised_values,
                    labels   => \%authorised_lib,
                    default  => $value,
                    ( ( grep { $_ eq $subfieldlib->{authorised_value}} ( qw(branches itemtypes cn_source) ) ) ? () : ( category => $subfieldlib->{authorised_value}) ),
                };
            }
        }
            # it's a thesaurus / authority field
        elsif ( $subfieldlib->{authtypecode} ) {
                $subfield_data{marc_value} = {
                    type         => 'text_auth',
                    id           => $subfield_data{id},
                    maxlength    => $subfield_data{maxlength},
                    value        => $value,
                    authtypecode => $subfieldlib->{authtypecode},
                };
        }
            # it's a plugin field
        elsif ( $subfieldlib->{value_builder} ) { # plugin
            require Koha::FrameworkPlugin;
            my $plugin = Koha::FrameworkPlugin->new({
                name => $subfieldlib->{'value_builder'},
                item_style => 1,
            });
            my $pars=  { dbh => $dbh, record => $temp, tagslib =>$tagslib,
                id => $subfield_data{id}, tabloop => $subfields };
            $plugin->build( $pars );
            if( !$plugin->errstr ) {
                my $class= 'buttonDot'. ( $plugin->noclick? ' disabled': '' );
                $subfield_data{marc_value} = {
                    type        => 'text_plugin',
                    id          => $subfield_data{id},
                    maxlength   => $subfield_data{maxlength},
                    value       => $value,
                    class       => $class,
                    nopopup     => $plugin->noclick,
                    javascript  => $plugin->javascript,
                };
            } else {
                warn $plugin->errstr;
                $subfield_data{marc_value} = {
                    type        => 'text',
                    id          => $subfield_data{id},
                    maxlength   => $subfield_data{maxlength},
                    value       => $value,
                }; # supply default input form
            }
        }
        elsif ( $tag eq '' ) {       # it's an hidden field
            $subfield_data{marc_value} = {
                type        => 'hidden',
                id          => $subfield_data{id},
                maxlength   => $subfield_data{maxlength},
                value       => $value,
            };
        }
        elsif ( $subfieldlib->{'hidden'} ) {   # FIXME: shouldn't input type be "hidden" ?
            $subfield_data{marc_value} = {
                type        => 'text',
                id          => $subfield_data{id},
                maxlength   => $subfield_data{maxlength},
                value       => $value,
            };
        }
        elsif (
                (
                    $value and length($value) > 100
                )
                or (
                    C4::Context->preference("marcflavour") eq "UNIMARC"
                    and 300 <= $tag && $tag < 400 && $subfieldtag eq 'a'
                )
                or (
                    C4::Context->preference("marcflavour") eq "MARC21"
                    and 500 <= $tag && $tag < 600
                )
              ) {
            # oversize field (textarea)
            $subfield_data{marc_value} = {
                type        => 'textarea',
                id          => $subfield_data{id},
                value       => $value,
            };
        } else {
            # it's a standard field
            $subfield_data{marc_value} = {
                type        => 'text',
                id          => $subfield_data{id},
                maxlength   => $subfield_data{maxlength},
                value       => $value,
            };
        }

        # Getting list of subfields to keep when restricted editing is enabled
        my $subfieldsToAllowForRestrictedEditing = C4::Context->preference('SubfieldsToAllowForRestrictedEditing');
        my $allowAllSubfields = (
            not defined $subfieldsToAllowForRestrictedEditing
              or $subfieldsToAllowForRestrictedEditing eq q||
        ) ? 1 : 0;
        my @subfieldsToAllow = split(/ /, $subfieldsToAllowForRestrictedEditing);

        # If we're on restricted editing, and our field is not in the list of subfields to allow,
        # then it is read-only
        $subfield_data{marc_value}->{readonly} = (
            not $allowAllSubfields
            and $restrictededition
            and !grep { $tag . '$' . $subfieldtag  eq $_ } @subfieldsToAllow
        ) ? 1: 0;

        return \%subfield_data;
}

sub get_item_from_cookie {
    my ( $input ) = @_;

    my $item_from_cookie;
    my $lastitemcookie = $input->cookie('LastCreatedItem');
    if ($lastitemcookie) {
        $lastitemcookie = decode_base64url($lastitemcookie);
        eval {
            if ( thaw($lastitemcookie) ) {
                $item_from_cookie = thaw($lastitemcookie);
            }
        };
        if ($@) {
            $lastitemcookie ||= 'undef';
            warn "Storable::thaw failed to thaw LastCreatedItem-cookie. Cookie value '".encode_base64url($lastitemcookie)."'. Caught error follows: '$@'";
        }
    }
    return $item_from_cookie;
}

my $input        = CGI->new;
my $error        = $input->param('error');

my $biblionumber;
my $itemnumber;
if( $input->param('itemnumber') && !$input->param('biblionumber') ){
    $itemnumber = $input->param('itemnumber');
    my $item = Koha::Items->find( $itemnumber );
    $biblionumber = $item->biblionumber;
} else {
    $biblionumber = $input->param('biblionumber');
    $itemnumber = $input->param('itemnumber');
}

my $biblio = Koha::Biblios->find($biblionumber);

my $op           = $input->param('op') || q{};
my $hostitemnumber = $input->param('hostitemnumber');
my $marcflavour  = C4::Context->preference("marcflavour");
my $searchid     = $input->param('searchid');
# fast cataloguing datas
my $fa_circborrowernumber = $input->param('circborrowernumber');
my $fa_barcode            = $input->param('barcode');
my $fa_branch             = $input->param('branch');
my $fa_stickyduedate      = $input->param('stickyduedate');
my $fa_duedatespec        = $input->param('duedatespec');

our $frameworkcode = &GetFrameworkCode($biblionumber);

# Defining which userflag is needing according to the framework currently used
my $userflags;
if (defined $input->param('frameworkcode')) {
    $userflags = ($input->param('frameworkcode') eq 'FA') ? "fast_cataloging" : "edit_items";
}

if (not defined $userflags) {
    $userflags = ($frameworkcode eq 'FA') ? "fast_cataloging" : "edit_items";
}

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/additem.tt",
                 query => $input,
                 type => "intranet",
                 flagsrequired => {editcatalogue => $userflags},
                 });


# Does the user have a restricted item editing permission?
my $uid = Koha::Patrons->find( $loggedinuser )->userid;
my $restrictededition = $uid ? haspermission($uid,  {'editcatalogue' => 'edit_items_restricted'}) : undef;
# In case user is a superlibrarian, editing is not restricted
$restrictededition = 0 if ($restrictededition != 0 &&  C4::Context->IsSuperLibrarian());
# In case user has fast cataloging permission (and we're in fast cataloging), editing is not restricted
$restrictededition = 0 if ($restrictededition != 0 && $frameworkcode eq 'FA' && haspermission($uid, {'editcatalogue' => 'fast_cataloging'}));

our $tagslib = &GetMarcStructure(1,$frameworkcode);
my $record = GetMarcBiblio({ biblionumber => $biblionumber });

output_and_exit_if_error( $input, $cookie, $template,
    { module => 'cataloguing', record => $record } );

my $current_item;
my $nextop="additem";
my @errors; # store errors found while checking data BEFORE saving item.

# Getting last created item cookie
my $prefillitem = C4::Context->preference('PrefillItem');

#-------------------------------------------------------------------------------
if ($op eq "additem") {

    my $add_submit                 = $input->param('add_submit');
    my $add_duplicate_submit       = $input->param('add_duplicate_submit');
    my $add_multiple_copies_submit = $input->param('add_multiple_copies_submit');
    my $number_of_copies           = $input->param('number_of_copies');

    my @columns = Koha::Items->columns;
    my $item = Koha::Item->new;
    $item->biblionumber($biblio->biblionumber);
    for my $c ( @columns ) {
        if ( $c eq 'more_subfields_xml' ) {
            my @more_subfields_xml = $input->multi_param("items.more_subfields_xml");
            my @unlinked_item_subfields;
            for my $subfield ( @more_subfields_xml ) {
                my $v = $input->param('items.more_subfields_xml_' . $subfield);
                push @unlinked_item_subfields, $subfield, $v;
            }
            if ( @unlinked_item_subfields ) {
                my $marc = MARC::Record->new();
                # use of tag 999 is arbitrary, and doesn't need to match the item tag
                # used in the framework
                $marc->append_fields(MARC::Field->new('999', ' ', ' ', @unlinked_item_subfields));
                $marc->encoding("UTF-8");
                $item->more_subfields_xml($marc->as_xml("USMARC"));
                next;
            }
            $item->more_subfields_xml(undef);
        } else {
            my @v = grep { $_ ne "" }
                uniq $input->multi_param( "items." . $c );

            next if !@v
                && $c ne 'permanent_location'; # See 27837

            $item->$c(join ' | ', @v);
        }
    }

    # if autoBarcode is set to 'incremental', calculate barcode...
    if ( ! defined $item->barcode && C4::Context->preference('autoBarcode') eq 'incremental' ) {
        my ( $barcode ) = C4::Barcodes::ValueBuilder::incremental::get_barcode;
        $item->barcode($barcode);
    }

    # If we have to add or add & duplicate, we add the item
    if ( $add_submit || $prefillitem) {

        # check for item barcode # being unique
        if ( defined $item->barcode
            && Koha::Items->search( { barcode => $item->barcode } )->count )
        {
            # if barcode exists, don't create, but report The problem.
            push @errors, "barcode_not_unique";

            $current_item = $item->unblessed; # Restore edit form for the same item
        }
        else {
            $item->store->discard_changes;

            # This is a bit tricky : if there is a cookie for the last created item and
            # we just added an item, the cookie value is not correct yet (it will be updated
            # next page). To prevent the form from being filled with outdated values, we
            # force the use of "add and duplicate" feature, so the form will be filled with
            # correct values.

            # Pushing the last created item cookie back
            if ( $prefillitem ) {
                my $last_created_item_cookie = $input->cookie(
                    -name => 'LastCreatedItem',
                    # We encode_base64url the whole freezed structure so we're sure we won't have any encoding problems
                    -value   => encode_base64url( freeze( { %{$item->unblessed}, itemnumber => undef } ) ),
                    -HttpOnly => 1,
                    -expires => ''
                );

                $cookie = [ $cookie, $last_created_item_cookie ];
            }

        }
        $nextop = "additem";

    }

    # If we have to add & duplicate
    if ($prefillitem || $add_duplicate_submit) {

        $current_item = $item->unblessed;

        if (C4::Context->preference('autoBarcode') eq 'incremental') {
            my ( $barcode ) = C4::Barcodes::ValueBuilder::incremental::get_barcode;
            $current_item->{barcode} = $barcode;
        }
        else {
            # we have to clear the barcode field in the duplicate item record to make way for the new one generated by the javascript plugin
            $current_item->{barcode} = undef; # FIXME or delete?
        }

        # Don't use the "prefill" feature if we want to generate the form with all the info from this item
        # It will remove subfields that are not in SubfieldsToUseWhenPrefill.
        $prefillitem = 0 if $add_duplicate_submit;
    }

    # If we have to add multiple copies
    if ($add_multiple_copies_submit) {

        $current_item = $item->unblessed;

        my $copynumber = $current_item->{copynumber};
        my $oldbarcode = $current_item->{barcode};

        # If there is a barcode and we can't find their new values, we can't add multiple copies
        my $testbarcode;
        my $barcodeobj = C4::Barcodes->new;
        $testbarcode = $barcodeobj->next_value($oldbarcode) if $barcodeobj;
        if ( $oldbarcode && !$testbarcode ) {

            push @errors, "no_next_barcode";

        }
        else {
            # We add each item

            # For the first iteration
            my $barcodevalue = $oldbarcode;
            my $exist_itemnumber;

            for ( my $i = 0 ; $i < $number_of_copies ; ) {

                # If there is a barcode
                if ($barcodevalue) {

# Getting a new barcode (if it is not the first iteration or the barcode we tried already exists)
                    $barcodevalue = $barcodeobj->next_value($oldbarcode)
                      if ( $i > 0 || $exist_itemnumber );

                    # Putting it into the record
                    if ($barcodevalue) {
                        if ( C4::Context->preference("autoBarcode") eq
                            'hbyymmincr' && $i > 0 )
                        { # The first copy already contains the homebranch prefix
                             # This is terribly hacky but the easiest way to fix the way hbyymmincr is working
                             # Contrary to what one might think, the barcode plugin does not prefix the returned string with the homebranch
                             # For a single item, it is handled with some JS code (see cataloguing/value_builder/barcode.pl)
                             # But when adding multiple copies we need to prefix it here,
                             # so we retrieve the homebranch from the item and prefix the barcode with it.
                            my $homebranch = $current_item->{homebranch};
                            $barcodevalue = $homebranch . $barcodevalue;
                        }
                        $current_item->{barcode} = $barcodevalue;
                    }

                    # Checking if the barcode already exists
                    $exist_itemnumber = Koha::Items->search({ barcode => $barcodevalue })->count;
                }

                # Updating record with the new copynumber
                if ($copynumber) {
                    $current_item->{copynumber} = $copynumber;
                }

                # Adding the item
                if ( !$exist_itemnumber ) {
                    delete $current_item->{itemnumber};
                    $current_item = Koha::Item->new($current_item)->store(
                        { skip_record_index => 1 } );
                    $current_item->discard_changes; # Cannot chain discard_changes
                    $current_item = $current_item->unblessed;

# We count the item only if it was really added
# That way, all items are added, even if there was some already existing barcodes
# FIXME : Please note that there is a risk of infinite loop here if we never find a suitable barcode
                    $i++;

                    # Only increment copynumber if item was really added
                    $copynumber++ if ( $copynumber && $copynumber =~ m/^\d+$/ );
                }

                # Preparing the next iteration
                $oldbarcode = $barcodevalue;
            }

            my $indexer = Koha::SearchEngine::Indexer->new(
                { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
            $indexer->index_records( $biblionumber, "specialUpdate",
                "biblioserver" );

            undef($current_item);
        }
    }
    if ($frameworkcode eq 'FA' && $fa_circborrowernumber){
        print $input->redirect(
           '/cgi-bin/koha/circ/circulation.pl?'
           .'borrowernumber='.$fa_circborrowernumber
           .'&barcode='.uri_escape_utf8($fa_barcode)
           .'&duedatespec='.$fa_duedatespec
           .'&stickyduedate='.$fa_stickyduedate
        );
        exit;
    }


#-------------------------------------------------------------------------------
} elsif ($op eq "edititem") {
#-------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
    $current_item = Koha::Items->find($itemnumber)->unblessed;
    # FIXME Handle non existent item
    $nextop = "saveitem";
#-------------------------------------------------------------------------------
} elsif ($op eq "dupeitem") {
#-------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
    my $item = Koha::Items->find($itemnumber);
    # FIXME Handle non existent item
    if (C4::Context->preference('autoBarcode') eq 'incremental') {
        my ( $barcode ) = C4::Barcodes::ValueBuilder::incremental::get_barcode;
        $item->barcode($barcode);
    }
    else {
        $item->barcode(undef); # Don't save it!
    }

    $nextop = "additem";
#-------------------------------------------------------------------------------
} elsif ($op eq "delitem") {
#-------------------------------------------------------------------------------
    # check that there is no issue on this item before deletion.
    my $item = Koha::Items->find($itemnumber);
    $error = $item->safe_delete;
    if(ref($error) eq 'Koha::Item'){
        print $input->redirect("additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode&searchid=$searchid");
    }else{
        push @errors,$error;
        $nextop="additem";
    }
#-------------------------------------------------------------------------------
} elsif ($op eq "delallitems") {
#-------------------------------------------------------------------------------
    my $items = Koha::Items->search({ biblionumber => $biblionumber });
    while ( my $item = $items->next ) {
        $error = $item->safe_delete({ skip_record_index => 1 });
        next if ref $error eq 'Koha::Item'; # Deleted item is returned if deletion successful
        push @errors,$error;
    }
    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    $indexer->index_records( $biblionumber, "specialUpdate", "biblioserver" );
    if ( @errors ) {
        $nextop="additem";
    } else {
        my $defaultview = C4::Context->preference('IntranetBiblioDefaultView');
        my $views = { C4::Search::enabled_staff_search_views };
        if ($defaultview eq 'isbd' && $views->{can_view_ISBD}) {
            print $input->redirect("/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=$biblionumber&searchid=$searchid");
        } elsif  ($defaultview eq 'marc' && $views->{can_view_MARC}) {
            print $input->redirect("/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=$biblionumber&searchid=$searchid");
        } elsif  ($defaultview eq 'labeled_marc' && $views->{can_view_labeledMARC}) {
            print $input->redirect("/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=$biblionumber&searchid=$searchid");
        } else {
            print $input->redirect("/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber&searchid=$searchid");
        }
        exit;
    }
#-------------------------------------------------------------------------------
} elsif ($op eq "saveitem") {
#-------------------------------------------------------------------------------

    my $itemnumber = $input->param('itemnumber');
    my $item = Koha::Items->find($itemnumber);
    # FIXME Handle non existent item
    my $olditemlost = $item->itemlost;
    my @columns = Koha::Items->columns;
    for my $c ( @columns ) {
        if ( $c eq 'more_subfields_xml' ) {
            my @more_subfields_xml = $input->multi_param("items.more_subfields_xml");
            my @unlinked_item_subfields;
            for my $subfield ( uniq @more_subfields_xml ) {
                my @v = $input->multi_param('items.more_subfields_xml_' . $subfield);
                push @unlinked_item_subfields, $subfield, $_ for @v;
            }
            if ( @unlinked_item_subfields ) {
                my $marc = MARC::Record->new();
                # use of tag 999 is arbitrary, and doesn't need to match the item tag
                # used in the framework
                $marc->append_fields(MARC::Field->new('999', ' ', ' ', @unlinked_item_subfields));
                $marc->encoding("UTF-8");
                $item->more_subfields_xml($marc->as_xml("USMARC"));
                next;
            }
            $item->more_subfields_xml(undef);
        } else {
            my @v = $input->multi_param("items.".$c);
            next unless @v;
            $item->$c(join ' | ', uniq @v);
        }
    }

    # check that the barcode don't exist already
    if (
        defined $item->barcode
        && Koha::Items->search(
            {
                barcode    => $item->barcode,
                itemnumber => { '!=' => $item->itemnumber }
            }
        )->count
      )
    {
        # FIXME We shouldn't need that, ->store would explode as there is a unique constraint on items.barcode
        push @errors,"barcode_not_unique";
        $current_item = $item->unblessed; # Restore edit form for the same item
    } else {
        my $newitemlost = $item->itemlost;
        if ( $newitemlost && $newitemlost ge '1' && !$olditemlost ) {
            LostItem( $item->itemnumber, 'additem' );
        }
        $item->store;
    }

    $nextop="additem";
} elsif ($op eq "delinkitem"){

    my $analyticfield = '773';
	if ($marcflavour  eq 'MARC21' || $marcflavour eq 'NORMARC'){
        $analyticfield = '773';
    } elsif ($marcflavour eq 'UNIMARC') {
        $analyticfield = '461';
    }
    foreach my $field ($record->field($analyticfield)){
        if ($field->subfield('9') eq $hostitemnumber){
            $record->delete_field($field);
            last;
        }
    }
	my $modbibresult = ModBiblio($record, $biblionumber,'');
}

# update OAI-PMH sets
if ($op) {
    if (C4::Context->preference("OAI-PMH:AutoUpdateSets")) {
        C4::OAI::Sets::UpdateOAISetsBiblio($biblionumber, $record);
    }
}

#
#-------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#-------------------------------------------------------------------------------

# now, build existiing item list

my @items;
for my $item ( $biblio->items->as_list, $biblio->host_items->as_list ) {
    push @items, $item->columns_to_str;
}

my @witness_attributes = uniq map {
    my $item = $_;
    map { defined $item->{$_} && $item->{$_} ne "" ? $_ : () } keys %$item
} @items;

our ( $itemtagfield, $itemtagsubfield ) = &GetMarcFromKohaField("items.itemnumber");

my $subfieldcode_attribute_mappings;
for my $subfield_code ( keys %{ $tagslib->{$itemtagfield} } ) {

    my $subfield = $tagslib->{$itemtagfield}->{$subfield_code};

    next if IsMarcStructureInternal( $subfield );
    next unless $subfield->{tab} eq 10; # Is this really needed?

    my $attribute;
    if ( $subfield->{kohafield} ) {
        ( $attribute = $subfield->{kohafield} ) =~ s|^items\.||;
    } else {
        $attribute = $subfield_code; # It's in more_subfields_xml
    }
    next unless grep { $attribute eq $_ } @witness_attributes;
    $subfieldcode_attribute_mappings->{$subfield_code} = $attribute;
}

my @header_value_loop = map {
    {
        header_value  => $tagslib->{$itemtagfield}->{$_}->{lib},
        attribute     => $subfieldcode_attribute_mappings->{$_},
        subfield_code => $_,
    }
} sort keys %$subfieldcode_attribute_mappings;

# now, build the item form for entering a new item
my $branch = $input->param('branch') || C4::Context->userenv->{branch};
my $libraries = Koha::Libraries->search({}, { order_by => ['branchname'] })->unblessed;# build once ahead of time, instead of multiple times later.
for my $library ( @$libraries ) {
    $library->{selected} = 1 if $library->{branchcode} eq $branch
}


# Using last created item if it exists
if (   $prefillitem
    && $op ne "additem"
    && $op ne "edititem" )
{
    my $item_from_cookie = get_item_from_cookie($input);
    $current_item = $item_from_cookie if $item_from_cookie;
}

my @subfields_to_prefill = split ' ', C4::Context->preference('SubfieldsToUseWhenPrefill');

if ( $current_item->{more_subfields_xml} ) {
    $current_item->{marc_more_subfields_xml} = MARC::Record->new_from_xml($current_item->{more_subfields_xml}, 'UTF-8');
}

# We generate form, and fill with values if defined
my $temp = GetMarcBiblio({ biblionumber => $biblionumber });
my $i = 0;
my @subfields;
foreach my $tag ( keys %{$tagslib} ) {
    foreach my $subtag ( keys %{ $tagslib->{$tag} } ) {

        my $subfield = $tagslib->{$tag}{$subtag};

        next if IsMarcStructureInternal( $subfield );
        next if ( $subfield->{tab} ne "10" );

        my @values = ();

        my $subfield_data;

        # If we are not adding a new item
        # OR
        # If the subfield must be prefilled with last catalogued item
        if (
            $nextop ne 'additem'
            || (
                !$prefillitem
                || ( $prefillitem && grep { $_ eq $subtag }
                    @subfields_to_prefill )
            )
          )
        {
            my $kohafield = $subfield->{kohafield};
            if ($kohafield) {

                # This is a mapped field
                ( my $attribute = $kohafield ) =~ s|^items\.||;
                push @values, $subfield->{repeatable}
                    ? split '\s\|\s', $current_item->{$attribute}
                    : $current_item->{$attribute}
                  if defined $current_item->{$attribute};
            } else {
                # Not mapped, picked the values from more_subfields_xml's MARC
                my $marc_more = $current_item->{marc_more_subfields_xml};
                if ( $marc_more ) {
                    for my $f ( $marc_more->fields($tag) ) {
                        push @values, $f->subfield($subtag);
                    }
                }
            }
        }

        @values = ('') unless @values;

        for my $value (@values) {
            my $subfield_data = generate_subfield_form(
                $tag,                        $subtag,
                $value,                      $tagslib,
                $subfield,                   $libraries,
                $biblionumber,               $temp,
                \@subfields,                 $i,
                $restrictededition,          $current_item,
            );
            push @subfields, $subfield_data;
            $i++;
        }
    }
}
@subfields = sort { $a->{display_order} <=> $b->{display_order} || $a->{subfield} cmp $b->{subfield} } @subfields;

# what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
$template->param(
    biblio       => $biblio,
    items        => \@items,
    item_header_loop => \@header_value_loop,
    subfields    => \@subfields,
    itemnumber       => $itemnumber,
    barcode          => $current_item->{barcode},
    itemtagfield     => $itemtagfield,
    itemtagsubfield  => $itemtagsubfield,
    op      => $nextop,
    popup => scalar $input->param('popup') ? 1: 0,
    C4::Search::enabled_staff_search_views,
);
$template->{'VARS'}->{'searchid'} = $searchid;

if ($frameworkcode eq 'FA'){
    # fast cataloguing datas
    $template->param(
        'circborrowernumber' => $fa_circborrowernumber,
        'barcode'            => $fa_barcode,
        'branch'             => $fa_branch,
        'stickyduedate'      => $fa_stickyduedate,
        'duedatespec'        => $fa_duedatespec,
    );
}

foreach my $error (@errors) {
    $template->param($error => 1);
}
output_html_with_http_headers $input, $cookie, $template->output;
