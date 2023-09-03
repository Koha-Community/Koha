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

use CGI qw ( -utf8 );
use Modern::Perl;
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user haspermission );
use C4::Output qw( output_html_with_http_headers );
use C4::Circulation qw( barcodedecode );
use C4::Context;
use MARC::File::XML;
use List::MoreUtils qw( uniq );
use Encode qw( encode_utf8 );

use Koha::Database;
use Koha::Exception;
use Koha::Biblios;
use Koha::Items;
use Koha::Patrons;
use Koha::Item::Attributes;
use Koha::BackgroundJob::BatchDeleteItem;
use Koha::BackgroundJob::BatchUpdateItem;
use Koha::UI::Form::Builder::Item;
use Koha::UI::Table::Builder::Items;

my $input = CGI->new;
my $dbh = C4::Context->dbh;
my $error        = $input->param('error');
my @itemnumbers  = $input->multi_param('itemnumber');
my $biblionumber = $input->param('biblionumber');
my $op           = $input->param('op');
my $del          = $input->param('del');
my $del_records  = $input->param('del_records');
my $src          = $input->param('src');
my $use_default_values = $input->param('use_default_values');
my $exclude_from_local_holds_priority = $input->param('exclude_from_local_holds_priority');
my $mark_items_returned = $input->param('mark_items_returned');

my $template_name;
my $template_flag;
if (!defined $op) {
    $template_name = "tools/batchMod.tt";
    $template_flag = { tools => '*' };
    $op = q{};
} else {
    $template_name = ($del) ? "tools/batchMod-del.tt" : "tools/batchMod-edit.tt";
    $template_flag = ($del) ? { tools => 'items_batchdel' }   : { tools => 'items_batchmod' };
}

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => $template_name,
                 query => $input,
                 type => "intranet",
                 flagsrequired => $template_flag,
                 });

$template->param( searchid => scalar $input->param('searchid'), );

# Does the user have a restricted item edition permission?
my $patron = Koha::Patrons->find( $loggedinuser );
my $uid = $loggedinuser ? $patron->userid : undef;
my $restrictededition = $uid ? haspermission($uid,  {'tools' => 'items_batchmod_restricted'}) : undef;
# In case user is a superlibrarian, edition is not restricted
$restrictededition = 0 if ($restrictededition != 0 && C4::Context->IsSuperLibrarian());

my $nextop="";
my $display_items;

my @messages;

if ( $op eq "action" ) {

    if ($del) {
        try {
            my $params = {
                record_ids     => \@itemnumbers,
                delete_biblios => $del_records,
            };
            my $job_id =
              Koha::BackgroundJob::BatchDeleteItem->new->enqueue($params);
            $nextop = 'enqueued';
            $template->param( job_id => $job_id, );
        }
        catch {
            warn $_;
            push @messages,
              {
                type  => 'error',
                code  => 'cannot_enqueue_job',
                error => $_,
              };
            $template->param( view => 'errors' );
        };
    }

    else {    # modification

        my @item_columns = Koha::Items->columns;

        my $new_item_data;
        my ( $columns_with_regex );
        my @subfields_to_blank = $input->multi_param('disable_input');
        my @more_subfields = $input->multi_param("items.more_subfields_xml");
        for my $item_column (@item_columns) {
            my @attributes       = ($item_column);
            my $cgi_param_prefix = 'items.';
            if ( $item_column eq 'more_subfields_xml' ) {
                @attributes       = ();
                $cgi_param_prefix = 'items.more_subfields_xml_';
                for my $subfield (@more_subfields) {
                    push @attributes, $subfield;
                }
            }

            for my $attr (@attributes) {

                my $cgi_var_name = $cgi_param_prefix
                  . encode_utf8($attr)
                  ;  # We need to deal correctly with encoding on subfield codes

                if ( grep { $cgi_var_name eq $_ } @subfields_to_blank ) {
                    # Empty this column
                    $new_item_data->{$attr} = undef;
                }
                elsif ( my $regex_search =
                    $input->param( $cgi_var_name . '_regex_search' ) )
                {
                    $columns_with_regex->{$attr} = {
                        search => $regex_search,
                        replace =>
                          $input->param( $cgi_var_name . '_regex_replace' ),
                        modifiers =>
                          $input->param( $cgi_var_name . '_regex_modifiers' )
                    };
                }
                else {
                    my @v =
                      grep { $_ ne "" } uniq $input->multi_param($cgi_var_name);

                    next unless @v;

                    $new_item_data->{$attr} = join '|', @v;
                }
            }
        }

        my $params = {
            record_ids                        => \@itemnumbers,
            regex_mod                         => $columns_with_regex,
            new_values                        => $new_item_data,
            exclude_from_local_holds_priority => (
                defined $exclude_from_local_holds_priority
                  && $exclude_from_local_holds_priority ne ""
              )
            ? $exclude_from_local_holds_priority
            : undef,
            mark_items_returned => (
                defined $mark_items_returned
                  && $mark_items_returned ne ""
                )
            ? $mark_items_returned : undef,

        };
        try {
            my $job_id =
              Koha::BackgroundJob::BatchUpdateItem->new->enqueue($params);
            $nextop = 'enqueued';
            $template->param( job_id => $job_id, );
        }
        catch {
            push @messages,
              {
                type  => 'error',
                code  => 'cannot_enqueue_job',
                error => $_,
              };
            $template->param( view => 'errors' );
        };
    }

}

$template->param(
    messages => \@messages,
);
#
#-------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#-------------------------------------------------------------------------------

if ($op eq "show"){
    my $filefh = $input->upload('uploadfile');
    my $filecontent = $input->param('filecontent');
    my ( @notfoundbarcodes, @notfounditemnumbers);

    my $split_chars = C4::Context->preference('BarcodeSeparators');
    if ($filefh){
        binmode $filefh, ':encoding(UTF-8)';
        my @contentlist;
        while (my $content=<$filefh>){
            $content =~ s/[\r\n]*$//;
            push @contentlist, $content if $content;
        }

        if ($filecontent eq 'barcode_file') {
            @contentlist = grep /\S/, ( map { split /[$split_chars]/ } @contentlist );
            @contentlist = uniq @contentlist;
            # Note: adding lc for case insensitivity
            my %itemdata = map { lc($_->{barcode}) => $_->{itemnumber} } @{ Koha::Items->search({ barcode => { -in => \@contentlist } }, { columns => [ 'itemnumber', 'barcode' ] } )->unblessed };
            @itemnumbers = map { exists $itemdata{lc $_} ? $itemdata{lc $_} : () } @contentlist;
            @notfoundbarcodes = grep { !exists $itemdata{lc $_} } @contentlist;
        }
        elsif ( $filecontent eq 'itemid_file') {
            @contentlist = uniq @contentlist;
            my %itemdata = map { $_->{itemnumber} => 1 } @{ Koha::Items->search({ itemnumber => { -in => \@contentlist } }, { columns => [ 'itemnumber' ] } )->unblessed };
            @itemnumbers = grep { exists $itemdata{$_} } @contentlist;
            @notfounditemnumbers = grep { !exists $itemdata{$_} } @contentlist;
        }
    } else {
        if (defined $biblionumber && !@itemnumbers){
            my $biblio = Koha::Biblios->find($biblionumber);
            @itemnumbers = $biblio ? $biblio->items->get_column('itemnumber') : ();
        }
        if ( my $list = $input->param('barcodelist') ) {
            my @barcodelist = grep /\S/, ( split /[$split_chars]/, $list );
            @barcodelist = uniq @barcodelist;

            @barcodelist = map { barcodedecode( $_ ) } @barcodelist;

            # Note: adding lc for case insensitivity
            my %itemdata = map { lc($_->{barcode}) => $_->{itemnumber} } @{ Koha::Items->search({ barcode => { -in => \@barcodelist } }, { columns => [ 'itemnumber', 'barcode' ] } )->unblessed };
            @itemnumbers = map { exists $itemdata{lc $_} ? $itemdata{lc $_} : () } @barcodelist;
            @notfoundbarcodes = grep { !exists $itemdata{lc $_} } @barcodelist;
        }
    }

    # Flag to tell the template there are valid results, hidden or not
    if(scalar(@itemnumbers) > 0){ $template->param("itemresults" => 1); }
    # Only display the items if there are no more than pref MaxItemsToProcessForBatchMod or MaxItemsToDisplayForBatchDel
    my $max_display_items = $del
        ? C4::Context->preference("MaxItemsToDisplayForBatchDel")
        : C4::Context->preference("MaxItemsToDisplayForBatchMod");
    $template->param("too_many_items_process" => scalar(@itemnumbers)) if !$del && scalar(@itemnumbers) > C4::Context->preference("MaxItemsToProcessForBatchMod");
    if (scalar(@itemnumbers) <= ( $max_display_items // 1000 ) ) {
        $display_items = 1;
    } else {
        $template->param("too_many_items_display" => scalar(@itemnumbers));
        # Even if we do not display the items, we need the itemnumbers
        $template->param(itemnumbers_array => \@itemnumbers);
    }

    # now, build the item form for entering a new item

    # Getting list of subfields to keep when restricted batchmod edit is enabled
    my @subfields_to_allow = $restrictededition ? split ' ', C4::Context->preference('SubfieldsToAllowForRestrictedBatchmod') : ();

    my $subfields = Koha::UI::Form::Builder::Item->new->edit_form( # NOTE: We are not passing a biblionumber intentionally !
        {
            restricted_editition => $restrictededition,
            (
                @subfields_to_allow
                ? ( subfields_to_allow => \@subfields_to_allow )
                : ()
            ),
            ignore_not_allowed_subfields => 1,
            kohafields_to_ignore         => ['items.barcode'],
            prefill_with_default_values  => $use_default_values,
            branch_limit                 => C4::Context->userenv->{"branch"},
            default_branches_empty       => 1,
        }
    );

    # what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
    $template->param(
        subfields           => $subfields,
        notfoundbarcodes    => \@notfoundbarcodes,
        notfounditemnumbers => \@notfounditemnumbers
    );
    $nextop="action"
} # -- End action="show"

if ( $display_items ) {
    my $items_table =
      Koha::UI::Table::Builder::Items->new( { itemnumbers => \@itemnumbers } )
      ->build_table( { patron => $patron } );;
    $template->param(
        items        => $items_table->{items},
        item_header_loop => $items_table->{headers},
    );
}

$template->param(
    op  => $nextop,
    del => $del,
    ( $op ? ( $op => 1 ) : () ),
    src          => $src,
    biblionumber => $biblionumber,
);

output_html_with_http_headers $input, $cookie, $template->output;
