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
use C4::Barcodes::ValueBuilder;
use C4::Barcodes;
use C4::Biblio qw( GetFrameworkCode GetMarcFromKohaField GetMarcStructure IsMarcStructureInternal ModBiblio );
use C4::Circulation qw( barcodedecode LostItem );
use C4::Context;
use C4::Members;
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Search qw( enabled_staff_search_views );
use Koha::Biblios;
use Koha::Item::Templates;
use Koha::ItemTypes;
use Koha::Items;
use Koha::Items;
use Koha::Libraries;
use Koha::Patrons;
use Koha::SearchEngine::Indexer;
use Koha::UI::Form::Builder::Item;
use Koha::Result::Boolean;

use Encode qw( encode_utf8 );
use List::MoreUtils qw( any uniq );
use List::Util qw( first );
use MARC::File::XML;
use MIME::Base64 qw( decode_base64url encode_base64url );
use Storable qw( freeze thaw );
use URI::Escape qw( uri_escape_utf8 );

our $dbh = C4::Context->dbh;

sub add_item_to_item_group {
    my ( $biblionumber, $itemnumber, $item_group, $item_group_description ) = @_;

    return unless $item_group;

    my $item_group_id;
    if ( $item_group eq 'create' ) {
        my $item_group = Koha::Biblio::ItemGroup->new(
            {
                biblionumber => $biblionumber,
                description  => $item_group_description,
            }
        )->store();

        $item_group_id = $item_group->id;
    }
    else {
        $item_group_id = $item_group;
    }

    my $item_group_item = Koha::Biblio::ItemGroup::Item->new(
        {
            itemnumber => $itemnumber,
            item_group_id  => $item_group_id,
        }
    )->store();
}

sub get_item_from_template {
    my ( $template_id ) = @_;

    my $template = Koha::Item::Templates->find($template_id);

    return $template->decoded_contents if $template;
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
my $volume                = $input->param('volume');
my $volume_description    = $input->param('volume_description');

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

if ( $op eq 'edititem' || $op eq 'dupeitem' ) {
    my $item = Koha::Items->find($itemnumber);
    if ( !$item ) {
        $itemnumber = undef;
        $template->param( item_doesnt_exist => 1 );
        output_and_exit( $input, $cookie, $template, 'unknown_item' );
    }
}

# Does the user have a restricted item editing permission?
my $uid = Koha::Patrons->find( $loggedinuser )->userid;
my $restrictededition = $uid ? haspermission($uid,  {'editcatalogue' => 'edit_items_restricted'}) : undef;
# In case user is a superlibrarian, editing is not restricted
$restrictededition = 0 if ($restrictededition != 0 &&  C4::Context->IsSuperLibrarian());
# In case user has fast cataloging permission (and we're in fast cataloging), editing is not restricted
$restrictededition = 0 if ($restrictededition != 0 && $frameworkcode eq 'FA' && haspermission($uid, {'editcatalogue' => 'fast_cataloging'}));

our $tagslib = &GetMarcStructure(1,$frameworkcode);
my $record = $biblio->metadata->record;

output_and_exit_if_error( $input, $cookie, $template,
    { module => 'cataloguing', record => $record } );

my $current_item;
my $nextop="additem";
my @errors; # store errors found while checking data BEFORE saving item.

# Getting last created item cookie
my $prefillitem = C4::Context->preference('PrefillItem');

my $load_template_submit = $input->param('load_template_submit');
my $delete_template_submit = $input->param('delete_template_submit');
my $unload_template_submit = $input->param('unload_template_submit');
my $use_template_for_session = $input->param('use_template_for_session') || $input->cookie('ItemEditorSessionTemplateId');
my $template_id = $input->param('template_id') || $input->cookie('ItemEditorSessionTemplateId');
if ( $delete_template_submit ) {
    my $t = Koha::Item::Templates->find($template_id);
    $t->delete if $t && ( $t->patron_id eq $loggedinuser || haspermission( $uid, { 'editcatalogue' => 'manage_item_editor_templates' } ) );
    $template_id = undef;
    $use_template_for_session = undef;
}
if ($load_template_submit || $unload_template_submit) {
    $op = q{} if $template_id;

    $template_id = undef if !$input->param('template_id');
    $template_id = undef if $unload_template_submit;

    # Unset the cookie if either no template id as submitted, or "use for session" checkbox as unchecked
    my $cookie_value = $input->param('use_template_for_session') && $template_id ? $template_id : q{};
    $use_template_for_session = $cookie_value;

    # Update the cookie
    my $template_cookie = $input->cookie(
        -name     => 'ItemEditorSessionTemplateId',
        -value    => $cookie_value,
        -HttpOnly => 1,
        -expires  => '',
        -sameSite => 'Lax'
    );

    $cookie = [ $cookie, $template_cookie ];
}
$template->param(
    template_id    => $template_id,
    item_templates => Koha::Item::Templates->get_available($loggedinuser),
    use_template_for_session => $use_template_for_session,
);

#-------------------------------------------------------------------------------
if ($op eq "additem") {

    my $add_submit                 = $input->param('add_submit');
    my $add_duplicate_submit       = $input->param('add_duplicate_submit');
    my $add_multiple_copies_submit = $input->param('add_multiple_copies_submit');
    my $save_as_template_submit    = $input->param('save_as_template_submit');
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

            next unless @v;

            if ( $c eq 'permanent_location' ) { # See 27837
                $item->make_column_dirty('permanent_location');
            }

            $item->$c(join ' | ', @v);
        }
    }

    # if autoBarcode is set to 'incremental', calculate barcode...
    if ( ! defined $item->barcode && C4::Context->preference('autoBarcode') eq 'incremental' ) {
        my ( $barcode ) = C4::Barcodes::ValueBuilder::incremental::get_barcode;
        $item->barcode($barcode);
    }

    $item->barcode(barcodedecode($item->barcode));

    if ($save_as_template_submit) {
        my $template_name       = $input->param('template_name');
        my $template_is_shared  = $input->param('template_is_shared');
        my $replace_template_id = $input->param('replace_template_id');

        if ($replace_template_id) {
            my $template = Koha::Item::Templates->find($replace_template_id);
            $template->update(
                {
                    id             => $replace_template_id,
                    is_shared      => $template_is_shared ? 1 : 0,
                    contents       => $item->unblessed,
                }
            ) if $template && (
                $template->patron_id eq $loggedinuser
                ||
                haspermission( $uid, { 'editcatalogue' => 'manage_item_editor_templates' } )
            );
        }
        else {
            my $template = Koha::Item::Template->new(
                {
                    name      => $template_name,
                    patron_id => $loggedinuser,
                    is_shared => $template_is_shared ? 1 : 0,
                    contents  => $item->unblessed,
                }
            )->store();
        }
    }
    # If we have to add or add & duplicate, we add the item
    elsif ( $add_submit || $add_duplicate_submit || $prefillitem) {

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
            add_item_to_item_group( $item->biblionumber, $item->biblioitemnumber, $volume, $volume_description );

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
                    -expires => '',
                    -sameSite => 'Lax'
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
                    add_item_to_item_group( $item->biblionumber, $item->biblioitemnumber, $volume, $volume_description );

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
    $nextop       = "saveitem";
#-------------------------------------------------------------------------------
} elsif ($op eq "dupeitem") {
#-------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
    $current_item = Koha::Items->find($itemnumber)->unblessed;
    if ( C4::Context->preference('autoBarcode') eq 'incremental' ) {
        my ($barcode) = C4::Barcodes::ValueBuilder::incremental::get_barcode;
        $current_item->{barcode} = $barcode;
    }
    else {
        $current_item->{barcode} = undef;    # Don't save it!
    }

    $nextop = "additem";
#-------------------------------------------------------------------------------
} elsif ($op eq "delitem") {
#-------------------------------------------------------------------------------
    # check that there is no issue on this item before deletion.
    my $item = Koha::Items->find($itemnumber);
    my $deleted;
    if( $item ) {
        $deleted = $item->safe_delete;
    } else {
        $deleted = Koha::Result::Boolean->new(0)->add_message({ message => 'item_not_found' });
    }
    if ( $deleted ) {
        print $input->redirect("additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode&searchid=$searchid");
        exit;
    }
    else {
        push @errors, @{ $deleted->messages }[0]->message;
        $nextop = "additem";
    }
#-------------------------------------------------------------------------------
} elsif ($op eq "delallitems") {
#-------------------------------------------------------------------------------
    my $items = Koha::Items->search({ biblionumber => $biblionumber });
    while ( my $item = $items->next ) {
        my $deleted = $item->safe_delete({ skip_record_index => 1 });
        push @errors, @{$deleted->messages}[0]->message unless $deleted;
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
    my $new_values = $item->unblessed;
    for my $c ( @columns ) {
        if ( $c eq 'more_subfields_xml' ) {
            my @more_subfields_xml = $input->multi_param("items.more_subfields_xml");
            my @unlinked_item_subfields;
            for my $subfield ( uniq @more_subfields_xml ) {
                my @v = $input->multi_param('items.more_subfields_xml_' . encode_utf8($subfield));
                push @unlinked_item_subfields, $subfield, $_ for @v;
            }
            if ( @unlinked_item_subfields ) {
                my $marc = MARC::Record->new();
                # use of tag 999 is arbitrary, and doesn't need to match the item tag
                # used in the framework
                $marc->append_fields(MARC::Field->new('999', ' ', ' ', @unlinked_item_subfields));
                $marc->encoding("UTF-8");
                $new_values->{more_subfields_xml} = $marc->as_xml("USMARC");
                next;
            }
            $item->more_subfields_xml(undef);
        } else {
            my @v = map { ( defined $_ && $_ eq '' ) ? undef : $_ } $input->multi_param( "items." . $c );
            next unless @v;

            if ( $c eq 'permanent_location' ) { # See 27837
                $item->make_column_dirty('permanent_location');
            }

            if ( scalar(@v) == 1 && not defined $v[0] ) {
                delete $new_values->{$c};
            } else {
                $new_values->{$c} = join ' | ', @v;
            }
        }
    }
    $item = $item->set_or_blank($new_values);

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
    if ($marcflavour  eq 'MARC21'){
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

our ( $itemtagfield, $itemtagsubfield ) = GetMarcFromKohaField("items.itemnumber");

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

# Using last created item if it exists
if (
    $op ne "additem"
    && $op ne "edititem"
    && $op ne "dupeitem" )
{
    if ( $template_id ) {
        my $item_from_template = get_item_from_template($template_id);
        $current_item = $item_from_template if $item_from_template;
    }
    elsif ( $prefillitem ) {
        my $item_from_cookie = get_item_from_cookie($input);
        $current_item = $item_from_cookie if $item_from_cookie;
    }
}

if ( $current_item->{more_subfields_xml} ) {
    # FIXME Use Maybe MARC::Record::new_from_xml if encoding issues on subfield (??)
    $current_item->{marc_more_subfields_xml} = MARC::Record->new_from_xml($current_item->{more_subfields_xml}, 'UTF-8');
}

my $branchcode = $input->param('branch') || C4::Context->userenv->{branch};

# If we are not adding a new item
# OR
# If the subfield must be prefilled with last catalogued item
my @subfields_to_prefill;
if ( $nextop eq 'additem' && $op ne 'dupeitem' && $prefillitem ) {
    @subfields_to_prefill = split(' ', C4::Context->preference('SubfieldsToUseWhenPrefill'));
}

# Getting list of subfields to keep when restricted editing is enabled
my @subfields_to_allow = $restrictededition ? split ' ', C4::Context->preference('SubfieldsToAllowForRestrictedEditing') : ();

my $subfields =
  Koha::UI::Form::Builder::Item->new(
    { biblionumber => $biblionumber, item => $current_item } )->edit_form(
    {
        branchcode           => $branchcode,
        restricted_editition => $restrictededition,
        (
            @subfields_to_allow
            ? ( subfields_to_allow => \@subfields_to_allow )
            : ()
        ),
        (
            @subfields_to_prefill
            ? ( subfields_to_prefill => \@subfields_to_prefill )
            : ()
        ),
        prefill_with_default_values => 1,
        branch_limit => C4::Context->userenv->{"branch"},
        (
            $op eq 'dupeitem'
            ? ( ignore_invisible_subfields => 1 )
            : ()
        ),
    }
);

if (   $frameworkcode eq 'FA' ) {
    my ( $barcode_field ) = grep {$_->{kohafield} eq 'items.barcode'} @$subfields;
    $barcode_field->{marc_value}->{value} ||= $input->param('barcode');
}

if( my $default_location = C4::Context->preference('NewItemsDefaultLocation') ) {
    my ( $location_field ) = grep {$_->{kohafield} eq 'items.location'} @$subfields;
    $location_field->{marc_value}->{value} ||= $default_location;
}

my @ig = Koha::Biblio::ItemGroups->search({ biblio_id => $biblionumber })->as_list();
# what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
$template->param(
    biblio       => $biblio,
    items        => \@items,
    item_groups      => \@ig,
    item_header_loop => \@header_value_loop,
    subfields        => $subfields,
    itemnumber       => $itemnumber,
    barcode          => $current_item->{barcode},
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
