#!/usr/bin/perl

# Copyright 2015 Koha Team
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
use C4::Biblio qw( GetBiblioData GetFrameworkCode );
use C4::External::BakerTaylor qw( image_url link_url );
use C4::Koha qw(
    GetNormalizedEAN
    GetNormalizedISBN
    GetNormalizedOCLCNumber
    GetNormalizedUPC
);
use C4::Members;
use C4::Output qw( pagination_bar output_with_http_headers );
use C4::Tags qw( get_tags );
use C4::XSLT qw( XSLTParse4Display );

use Koha::Biblios;
use Koha::Biblioitems;
use Koha::CirculationRules;
use Koha::CsvProfiles;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;
use Koha::Virtualshelfshares;
use Koha::Virtualshelves;
use Koha::RecordProcessor;

use constant ANYONE => 2;
use constant STAFF => 3;
use constant PERMITTED => 4;

my $query = CGI->new;

my $template_name = $query->param('rss') ? "opac-shelves-rss.tt" : "opac-shelves.tt";

# if virtualshelves is disabled, leave immediately
if ( ! C4::Context->preference('virtualshelves') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $op = $query->param('op') || 'list';
my ( $template, $loggedinuser, $cookie );

if( $op eq 'view' || $op eq 'list' ){
    ( $template, $loggedinuser, $cookie ) = get_template_and_user({
            template_name   => $template_name,
            query           => $query,
            type            => "opac",
            authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        });
} else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user({
            template_name   => $template_name,
            query           => $query,
            type            => "opac",
            authnotrequired => 0,
        });
}

if (C4::Context->preference("BakerTaylorEnabled")) {
    $template->param(
        BakerTaylorImageURL => &image_url(),
        BakerTaylorLinkURL  => &link_url(),
    );
}

my $referer  = $query->param('referer')  || $op;
my $public = 0;
$public = 1 if $query->param('public') && $query->param('public') == 1;

my ( $shelf, $shelfnumber, @messages );

# PART 1: Perform a few actions
if ( $op eq 'add_form' ) {
    # Only pass default
    $shelf = { allow_change_from_owner => 1 };
} elsif ( $op eq 'edit_form' ) {
    $shelfnumber = $query->param('shelfnumber');
    $shelf       = Koha::Virtualshelves->find($shelfnumber);

    if ( $shelf ) {
        $public = $shelf->public;
        my $patron = Koha::Patrons->find( $shelf->owner );
        $template->param( owner => $patron, );
        unless ( $shelf->can_be_managed( $loggedinuser ) ) {
            push @messages, { type => 'error', code => 'unauthorized_on_update' };
            $op = 'list';
        }
    } else {
        push @messages, { type => 'error', code => 'does_not_exist' };
    }
} elsif ( $op eq 'add' ) {
    if ( $loggedinuser ) {
        my $allow_changes_from = $query->param('allow_changes_from');
        eval {
            $shelf = Koha::Virtualshelf->new(
                {   shelfname          => scalar $query->param('shelfname'),
                    sortfield          => scalar $query->param('sortfield'),
                    public             => $public,
                    allow_change_from_owner            => $allow_changes_from > 0,
                    allow_change_from_others           => $allow_changes_from == ANYONE,
                    allow_change_from_staff            => $allow_changes_from == STAFF,
                    allow_change_from_permitted_staff => $allow_changes_from == PERMITTED,
                    owner              => scalar $loggedinuser,
                }
            );
            $shelf->store;
            $shelfnumber = $shelf->shelfnumber;
        };
        if ($@) {
            push @messages, { type => 'error', code => ref($@), msg => $@ };
        } elsif ( not $shelf ) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
            $op = 'view';
        }
    } else {
        push @messages, { type => 'error', code => 'unauthorized_on_insert' };
        $op = 'list';
    }
} elsif ( $op eq 'edit' ) {
    $shelfnumber = $query->param('shelfnumber');
    $shelf       = Koha::Virtualshelves->find($shelfnumber);
    if ( $shelf ) {
        $op = $referer;
        my $sortfield = $query->param('sortfield');
        $sortfield = 'title' unless grep { $_ eq $sortfield } qw( title author copyrightdate itemcallnumber dateadded );
        if ( $shelf->can_be_managed( $loggedinuser ) ) {
            $shelf->shelfname( scalar $query->param('shelfname') );
            $shelf->sortfield( $sortfield );
            my $allow_changes_from = $query->param('allow_changes_from');
            $shelf->allow_change_from_owner( $allow_changes_from > 0 );
            $shelf->allow_change_from_others( $allow_changes_from == ANYONE );
            $shelf->allow_change_from_staff( $allow_changes_from == STAFF );
            $shelf->allow_change_from_permitted_staff( $allow_changes_from == PERMITTED );
            $shelf->public( $public );
            eval { $shelf->store };

            if ($@) {
                push @messages, { type => 'error', code => 'error_on_update' };
                $op = 'edit_form';
            } else {
                push @messages, { type => 'message', code => 'success_on_update' };
            }
        } else {
            push @messages, { type => 'error', code => 'unauthorized_on_update' };
        }
    } else {
        push @messages, { type => 'error', code => 'does_not_exist' };
    }
} elsif ( $op eq 'delete' ) {
    $shelfnumber = $query->param('shelfnumber');
    $shelf       = Koha::Virtualshelves->find($shelfnumber);
    if ($shelf) {
        if ( $shelf->can_be_deleted( $loggedinuser ) ) {
            eval { $shelf->delete; };
            if ($@) {
                push @messages, { type => 'error', code => ref($@), msg => $@ };
            } else {
                push @messages, { type => 'message', code => 'success_on_delete' };
            }
        } else {
            push @messages, { type => 'error', code => 'unauthorized_on_delete' };
        }
    } else {
        push @messages, { type => 'error', code => 'does_not_exist' };
    }
    $op = $referer;
} elsif ( $op eq 'remove_share' ) {
    $shelfnumber = $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber);
    if ($shelf) {
        my $removed = eval { $shelf->remove_share( $loggedinuser ); };
        if ($@) {
            push @messages, { type => 'error', code => ref($@), msg => $@ };
        } elsif ( $removed ) {
            push @messages, { type => 'message', code => 'success_on_remove_share' };
        } else {
            push @messages, { type => 'error', code => 'error_on_remove_share' };
        }
    } else {
        push @messages, { type => 'error', code => 'does_not_exist' };
    }
    $op = $referer;

} elsif ( $op eq 'add_biblio' ) {
    $shelfnumber = $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber);
    if ($shelf) {
        if( my $barcode = $query->param('barcode') ) {
            my $item = Koha::Items->find({ barcode => $barcode });
            if ( $item ) {
                if ( $shelf->can_biblios_be_added( $loggedinuser ) ) {
                    my $added = eval { $shelf->add_biblio( $item->biblionumber, $loggedinuser ); };
                    if ($@) {
                        push @messages, { type => 'error', code => ref($@), msg => $@ };
                    } elsif ( $added ) {
                        push @messages, { type => 'message', code => 'success_on_add_biblio' };
                    } else {
                        push @messages, { type => 'message', code => 'error_on_add_biblio' };
                    }
                } else {
                    push @messages, { type => 'error', code => 'unauthorized_on_add_biblio' };
                }
            } else {
                push @messages, { type => 'error', code => 'item_does_not_exist' };
            }
        }
    } else {
        push @messages, { type => 'error', code => 'does_not_exist' };
    }
    $op = $referer;
} elsif ( $op eq 'remove_biblios' ) {
    $shelfnumber = $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber);
    my @biblionumber = $query->multi_param('biblionumber');
    if ($shelf) {
        if ( $shelf->can_biblios_be_removed( $loggedinuser ) ) {
            my $number_of_biblios_removed = eval {
                $shelf->remove_biblios(
                    {
                        biblionumbers => \@biblionumber,
                        borrowernumber => $loggedinuser,
                    }
                );
            };
            if ($@) {
                push @messages, { type => 'error', code => ref($@), msg => $@ };
            } elsif ( $number_of_biblios_removed ) {
                push @messages, { type => 'message', code => 'success_on_remove_biblios' };
            } else {
                push @messages, { type => 'error', code => 'no_biblio_removed' };
            }
        } else {
            push @messages, { type => 'error', code => 'unauthorized_on_remove_biblios' };
        }
    } else {
        push @messages, { type => 'error', code => 'does_not_exist' };
    }
    $op = 'view';
} elsif( $op eq 'transfer' ) {
    $shelfnumber = $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber) if $shelfnumber;
    my $new_owner = $query->param('new_owner'); # borrowernumber or undef
    my $error_code = $shelf
        ? $shelf->cannot_be_transferred({ by => $loggedinuser, to => $new_owner, interface => 'opac' })
        : 'does_not_exist';

    if( !$new_owner && $error_code eq 'missing_to_parameter' ) { # show transfer form
        my $patrons = [];
        my $shares = $shelf->get_shares->search({ borrowernumber => { '!=' => undef } });
        while( my $share = $shares->next ) {
            my $email = $share->sharee->notice_email_address;
            push @$patrons, { email => $email, borrowernumber => $share->get_column('borrowernumber') } if $email;
        }
        if( @$patrons ) {
            $template->param( shared_users => $patrons );
            $op = 'transfer';
        } else {
            push @messages, { type => 'error', code => 'no_email_found' };
        }
    } elsif( $error_code ) {
        push @messages, { type => 'error', code => $error_code };
        $op = 'list';
    } else { # transfer; remove new_owner from virtualshelfshares, add loggedinuser
        $shelf->_result->result_source->schema->txn_do( sub {
            $shelf->get_shares->search({ borrowernumber => $new_owner })->delete;
            Koha::Virtualshelfshare->new({ shelfnumber => $shelfnumber, borrowernumber => $loggedinuser, sharedate => dt_from_string })->store;
            $shelf->owner($new_owner)->store;
        });
        $op = 'list';
    }
}

# PART 2: After a possible action, view one list or show a number of lists
if ( $op eq 'view' ) {
    $shelfnumber ||= $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber);
    if ( $shelf ) {
        if ( $shelf->can_be_viewed( $loggedinuser ) ) {
            $public = $shelf->public;

            # Sortfield param may still include sort order with :asc or :desc, but direction overrides it
            my( $sortfield, $direction );
            if( $query->param('sortfield') ){
                ( $sortfield, $direction ) = split /:/, $query->param('sortfield');
            } else {
                $sortfield = $shelf->sortfield;
                $direction = 'asc';
            }
            $direction = $query->param('direction') if $query->param('direction');
            $direction = 'asc' if !$direction or ( $direction ne 'asc' and $direction ne 'desc' );
            $sortfield = 'title' if !$sortfield or !grep { $_ eq $sortfield } qw( title author copyrightdate itemcallnumber dateadded );

            my ( $page, $rows );
            unless ( $query->param('print') or $query->param('rss') ) {
                $rows = C4::Context->preference('OPACnumSearchResults') || 20;
                $page = ( $query->param('page') ? $query->param('page') : 1 );
            }
            my $order_by = $sortfield eq 'itemcallnumber' ? 'items.cn_sort' : $sortfield;
            my $contents = $shelf->get_contents->search(
                {},
                {
                    distinct => 'biblionumber',
                    join     => [ { 'biblionumber' => { 'biblioitems' => 'items' } } ],
                    page     => $page,
                    rows     => $rows,
                    order_by => { "-$direction" => $order_by },
                }
            );

            # get biblionumbers stored in the cart
            my @cart_list;
            if(my $cart_list = $query->cookie('bib_list')){
                @cart_list = split(/\//, $cart_list);
            }

            my $patron = Koha::Patrons->find( $loggedinuser );

            my $categorycode; # needed for may_article_request
            if( C4::Context->preference('ArticleRequests') ) {
                $categorycode = $patron ? $patron->categorycode : undef;
            }

            my $record_processor = Koha::RecordProcessor->new({ filters => 'ViewPolicy' });

            my $art_req_itypes;
            if( C4::Context->preference('ArticleRequests') ) {
                $art_req_itypes = Koha::CirculationRules->guess_article_requestable_itemtypes({ $patron ? ( categorycode => $patron->categorycode ) : () });
            }

            my @items_info;
            while ( my $content = $contents->next ) {
                my $biblionumber = $content->biblionumber;
                my $this_item    = GetBiblioData($biblionumber);
                my $biblio       = Koha::Biblios->find($biblionumber);
                my $record       = $biblio->metadata->record;
                my $framework    = GetFrameworkCode($biblionumber);
                $record_processor->options(
                    {
                    interface => 'opac',
                    frameworkcode => $framework
                });
                $record_processor->process($record);

                my $marcflavour = C4::Context->preference("marcflavour");
                my $itemtype = Koha::Biblioitems->search({ biblionumber => $content->biblionumber })->next->itemtype;
                $itemtype = Koha::ItemTypes->find( $itemtype );
                if( $itemtype ) {
                    $this_item->{imageurl}          = C4::Koha::getitemtypeimagelocation( 'opac', $itemtype->imageurl );
                    $this_item->{description}       = $itemtype->description; #FIXME Should not it be translated_description?
                    $this_item->{notforloan}        = $itemtype->notforloan;
                }
                $this_item->{'coins'}           = $biblio->get_coins;
                $this_item->{'normalized_upc'}  = GetNormalizedUPC( $record, $marcflavour );
                $this_item->{'normalized_ean'}  = GetNormalizedEAN( $record, $marcflavour );
                $this_item->{'normalized_oclc'} = GetNormalizedOCLCNumber( $record, $marcflavour );
                $this_item->{'normalized_isbn'} = GetNormalizedISBN( undef, $record, $marcflavour );
                # BZ17530: 'Intelligent' guess if result can be article requested
                $this_item->{artreqpossible} = ( $art_req_itypes->{ $this_item->{itemtype} // q{} } || $art_req_itypes->{ '*' } ) ? 1 : q{};

                unless ( defined $this_item->{size} ) {

                    #TT has problems with size
                    $this_item->{size} = q||;
                }

                if (C4::Context->preference('TagsEnabled') and C4::Context->preference('TagsShowOnList')) {
                    $this_item->{TagLoop} = get_tags({
                        biblionumber => $biblionumber, approved=>1, 'sort'=>'-weight',
                        limit => C4::Context->preference('TagsShowOnList'),
                    });
                }

                my $items = $biblio->items->filter_by_visible_in_opac({ patron => $patron });
                my $allow_onshelf_holds;
                while ( my $item = $items->next ) {

                    # This method must take a Koha::Items rs
                    $allow_onshelf_holds ||= Koha::CirculationRules->get_onshelfholds_policy(
                        { item => $item, patron => $patron } );

                }

                $this_item->{allow_onshelf_holds} = $allow_onshelf_holds;
                $this_item->{'ITEM_RESULTS'} = $items;

                my $variables = {
                    anonymous_session => ($loggedinuser) ? 0 : 1
                };
                $this_item->{XSLTBloc} = XSLTParse4Display(
                    {
                        biblionumber   => $biblionumber,
                        record         => $record,
                        xsl_syspref    => "OPACXSLTListsDisplay",
                        fix_amps       => 1,
                        xslt_variables => $variables,
                        items_rs       => $items->reset,
                    }
                );


                if ( grep {$_ eq $biblionumber} @cart_list) {
                    $this_item->{incart} = 1;
                }

                $this_item->{biblio_object} = $biblio;
                $this_item->{biblionumber}  = $biblionumber;
                $this_item->{shelves} =
                  Koha::Virtualshelves->get_shelves_containing_record(
                    {
                        biblionumber   => $biblionumber,
                        borrowernumber => $loggedinuser,
                    }
                  );
                push @items_info, $this_item;
            }

            $template->param(
                can_manage_shelf   => $shelf->can_be_managed($loggedinuser),
                can_delete_shelf   => $shelf->can_be_deleted($loggedinuser),
                can_remove_biblios => $shelf->can_biblios_be_removed($loggedinuser),
                can_add_biblios    => $shelf->can_biblios_be_added($loggedinuser),
                itemsloop          => \@items_info,
                sortfield          => $sortfield,
                direction          => $direction,
                csv_profiles => Koha::CsvProfiles->search(
                    {
                        type       => 'marc',
                        used_for   => 'export_records',
                        staff_only => 0
                    }
                  ),
            );
            if ( $page ) {
                my $pager = $contents->pager;
                $template->param(
                    pagination_bar => pagination_bar(
                        q||, $pager->last_page - $pager->first_page + 1,
                        $page, "page", { op => 'view', shelfnumber => $shelf->shelfnumber, sortfield => $sortfield, direction => $direction, }
                    ),
                );
            }
        } else {
            push @messages, { type => 'error', code => 'unauthorized_on_view' };
            undef $shelf;
        }
    } else {
        push @messages, { type => 'error', code => 'does_not_exist' };
    }
} elsif ( $op eq 'list' ) {
    my $shelves;
    my ( $page, $rows ) = ( $query->param('page') || 1, 20 );
    if ( !$public ) {
        $shelves = Koha::Virtualshelves->get_private_shelves({ page => $page, rows => $rows, borrowernumber => $loggedinuser, });
    } else {
        $shelves = Koha::Virtualshelves->get_public_shelves({ page => $page, rows => $rows, });
    }

    my $pager = $shelves->pager;
    $template->param(
        shelves => $shelves,
        pagination_bar => pagination_bar(
            q||, $pager->last_page - $pager->first_page + 1,
            $page, "page", { op => 'list', public => $public, }
        ),
    );
}

my ($staffuser, $permitteduser);
$staffuser = Koha::Patrons->find( $loggedinuser )->can_patron_change_staff_only_lists if $loggedinuser;
$permitteduser = Koha::Patrons->find( $loggedinuser )->can_patron_change_permitted_staff_lists if $loggedinuser;

$template->param(
    op            => $op,
    referer       => $referer,
    shelf         => $shelf,
    messages      => \@messages,
    public        => $public,
    print         => scalar $query->param('print') || 0,
    listsview     => 1,
    staffuser     => $staffuser,
    permitteduser => $permitteduser
);

my $content_type = $query->param('rss')? 'rss' : 'html';
output_with_http_headers $query, $cookie, $template->output, $content_type;
