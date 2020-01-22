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
use C4::Biblio qw( GetMarcBiblio );
use C4::Circulation qw( barcodedecode );
use C4::Koha qw(
    GetNormalizedEAN
    GetNormalizedISBN
    GetNormalizedOCLCNumber
    GetNormalizedUPC
);
use C4::Items qw( GetItemsLocationInfo );
use C4::Members;
use C4::Output qw( pagination_bar output_html_with_http_headers output_and_exit_if_error );
use C4::XSLT qw( XSLTParse4Display );

use Koha::Biblios;
use Koha::Biblioitems;
use Koha::Items;
use Koha::ItemTypes;
use Koha::CsvProfiles;
use Koha::Patrons;
use Koha::Virtualshelves;

use constant ANYONE => 2;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "virtualshelves/shelves.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

my $op       = $query->param('op')      || 'list';
my $referer  = $query->param('referer') || $op;
my $public   = $query->param('public') ? 1 : 0;
my ( $shelf, $shelfnumber, @messages );

if ( $op eq 'add_form' ) {
    # Only pass default
    $shelf = { allow_change_from_owner => 1 };
} elsif ( $op eq 'edit_form' ) {
    output_and_exit_if_error($query, $cookie, $template, { check => 'csrf_token' });
    $shelfnumber = $query->param('shelfnumber');
    $shelf       = Koha::Virtualshelves->find($shelfnumber);

    if ( $shelf ) {
        $public = $shelf->public;
        my $patron = Koha::Patrons->find( $shelf->owner )->unblessed;
        $template->param( owner => $patron, );
        unless ( $shelf->can_be_managed( $loggedinuser ) ) {
            push @messages, { type => 'alert', code => 'unauthorized_on_update' };
            $op = 'list';
        }
    } else {
        push @messages, { type => 'alert', code => 'does_not_exist' };
    }
} elsif ( $op eq 'add' ) {
    output_and_exit_if_error($query, $cookie, $template, { check => 'csrf_token' });
    my $allow_changes_from = $query->param('allow_changes_from');
    eval {
        $shelf = Koha::Virtualshelf->new(
            {   shelfname          => scalar $query->param('shelfname'),
                sortfield          => scalar $query->param('sortfield'),
                public             => $public,
                allow_change_from_owner => $allow_changes_from > 0,
                allow_change_from_others => $allow_changes_from == ANYONE,
                owner              => scalar $query->param('owner'),
            }
        );
        $shelf->store;
        $shelfnumber = $shelf->shelfnumber;
    };
    if ($@) {
        push @messages, { type => 'alert', code => ref($@), msg => $@ };
    } elsif ( not $shelf ) {
        push @messages, { type => 'alert', code => 'error_on_insert' };

    } else {
        push @messages, { type => 'message', code => 'success_on_insert' };
        $op = 'view';
    }
} elsif ( $op eq 'edit' ) {
    output_and_exit_if_error($query, $cookie, $template, { check => 'csrf_token' });
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
            $shelf->public( scalar $query->param('public') );
            eval { $shelf->store };

            if ($@) {
                push @messages, { type => 'alert', code => 'error_on_update' };
                $op = 'edit_form';
            } else {
                push @messages, { type => 'message', code => 'success_on_update' };
            }
        } else {
            push @messages, { type => 'alert', code => 'unauthorized_on_update' };
        }
    } else {
        push @messages, { type => 'alert', code => 'does_not_exist' };
    }
} elsif ( $op eq 'delete' ) {
    output_and_exit_if_error($query, $cookie, $template, { check => 'csrf_token' });
    $shelfnumber = $query->param('shelfnumber');
    $shelf       = Koha::Virtualshelves->find($shelfnumber);
    if ($shelf) {
        if ( $shelf->can_be_deleted( $loggedinuser ) ) {
            eval { $shelf->delete; };
            if ($@) {
                push @messages, { type => 'alert', code => ref($@), msg => $@ };
            } else {
                push @messages, { type => 'message', code => 'success_on_delete' };
            }
        } else {
            push @messages, { type => 'alert', code => 'unauthorized_on_delete' };
        }
    } else {
        push @messages, { type => 'alert', code => 'does_not_exist' };
    }
    $op = 'list';
} elsif ( $op eq 'add_biblio' ) {
    output_and_exit_if_error($query, $cookie, $template, { check => 'csrf_token' });
    $shelfnumber = $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber);
    if ($shelf) {
        if( my $barcodes = $query->param('barcodes') ) {
            if ( $shelf->can_biblios_be_added( $loggedinuser ) ) {
                my @barcodes = split /\n/, $barcodes; # Entries are effectively passed in as a <cr> separated list
                foreach my $barcode (@barcodes){
                    $barcode = barcodedecode( $barcode ) if $barcode;
                    next if $barcode eq '';
                    my $item = Koha::Items->find({barcode => $barcode});
                    if ( $item ) {
                        my $added = eval { $shelf->add_biblio( $item->biblionumber, $loggedinuser ); };
                        if ($@) {
                            push @messages, { item_barcode => $barcode, type => 'alert', code => ref($@), msg => $@ };
                        } elsif ( $added ) {
                            push @messages, { item_barcode => $barcode, type => 'message', code => 'success_on_add_biblio' };
                        } else {
                            push @messages, { item_barcode => $barcode, type => 'message', code => 'error_on_add_biblio' };
                        }
                    } else {
                        push @messages, { item_barcode => $barcode, type => 'alert', code => 'item_does_not_exist' };
                    }
                }
            } else {
                push @messages, { type => 'alert', code => 'unauthorized_on_add_biblio' };
            }
        }
        if ( my $biblionumbers = $query->param('biblionumbers') ) {
            if ( $shelf->can_biblios_be_added( $loggedinuser ) ) {
                my @biblionumbers = split /\n/, $biblionumbers;
                foreach my $biblionumber (@biblionumbers) {
                    $biblionumber =~ s/\r$//; # strip any naughty return chars
                    next if $biblionumber eq '';
                    my $biblio = Koha::Biblios->find($biblionumber);
                    if (defined $biblio) {
                        my $added = eval { $shelf->add_biblio( $biblionumber, $loggedinuser ); };
                        if ($@) {
                            push @messages, { bibnum => $biblionumber, type => 'alert', code => ref($@), msg => $@ };
                        } elsif ( $added ) {
                            push @messages, { bibnum => $biblionumber, type => 'message', code => 'success_on_add_biblio' };
                        } else {
                            push @messages, { bibnum => $biblionumber, type => 'message', code => 'error_on_add_biblio' };
                        }
                    } else {
                        push @messages, { bibnum => $biblionumber, type => 'alert', code => 'item_does_not_exist' };
                    }
                }
            } else {
                push @messages, { type => 'alert', code => 'unauthorized_on_add_biblio' };
            }
        }
    } else {
        push @messages, { type => 'alert', code => 'does_not_exist' };
    }
    $op = $referer;
} elsif ( $op eq 'remove_biblios' ) {
    output_and_exit_if_error($query, $cookie, $template, { check => 'csrf_token' });
    $shelfnumber = $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber);
    my @biblionumbers = $query->multi_param('biblionumber');
    if ($shelf) {
        if ( $shelf->can_biblios_be_removed( $loggedinuser ) ) {
            my $number_of_biblios_removed = eval {
                $shelf->remove_biblios(
                    {
                        biblionumbers => \@biblionumbers,
                        borrowernumber => $loggedinuser,
                    }
                );
            };
            if ($@) {
                push @messages, { type => 'alert', code => ref($@), msg => $@ };
            } elsif ( $number_of_biblios_removed ) {
                push @messages, { type => 'message', code => 'success_on_remove_biblios' };
            } else {
                push @messages, { type => 'alert', code => 'no_biblio_removed' };
            }
        } else {
            push @messages, { type => 'alert', code => 'unauthorized_on_remove_biblios' };
        }
    } else {
        push @messages, { type => 'alert', code => 'does_not_exist' };
    }
    $op = $referer;
}

if ( $op eq 'view' ) {
    $shelfnumber ||= $query->param('shelfnumber');
    $shelf = Koha::Virtualshelves->find($shelfnumber);
    if ( $shelf ) {
        if ( $shelf->can_be_viewed( $loggedinuser ) ) {
            my $sortfield = $query->param('sortfield') || $shelf->sortfield || 'title';    # Passed in sorting overrides default sorting
            $sortfield = 'title' unless grep { $_ eq $sortfield } qw( title author copyrightdate itemcallnumber dateadded );
            my $direction = $query->param('direction') || 'asc';
            $direction = 'asc' if $direction ne 'asc' and $direction ne 'desc';
            my ( $rows, $page );
            unless ( $query->param('print') ) {
                $rows = C4::Context->preference('numSearchResults') || 20;
                $page = ( $query->param('page') ? $query->param('page') : 1 );
            }

            my $order_by = $sortfield eq 'itemcallnumber' ? 'items.cn_sort' : $sortfield;
            my $contents = $shelf->get_contents->search(
                {},
                {
                    prefetch => [ { 'biblionumber' => { 'biblioitems' => 'items' } } ],
                    page     => $page,
                    rows     => $rows,
                    order_by => { "-$direction" => $order_by },
                }
            );

            my @items;
            while ( my $content = $contents->next ) {
                my $this_item;
                my $biblionumber = $content->biblionumber;
                my $record       = GetMarcBiblio({ biblionumber => $biblionumber });

                $this_item->{XSLTBloc} = XSLTParse4Display(
                    {
                        biblionumber => $biblionumber,
                        record       => $record,
                        xsl_syspref  => 'XSLTListsDisplay',
                        fix_amps     => 1,
                    }
                );

                my $marcflavour = C4::Context->preference("marcflavour");
                my $itemtype = Koha::Biblioitems->search({ biblionumber => $content->biblionumber })->next->itemtype;
                $itemtype = Koha::ItemTypes->find( $itemtype );
                my $biblio = Koha::Biblios->find( $content->biblionumber );
                $this_item->{title}             = $biblio->title;
                $this_item->{subtitle}          = $biblio->subtitle;
                $this_item->{medium}            = $biblio->medium;
                $this_item->{part_number}       = $biblio->part_number;
                $this_item->{part_name}         = $biblio->part_name;
                $this_item->{author}            = $biblio->author;
                $this_item->{dateadded}         = $content->dateadded;
                $this_item->{imageurl}          = $itemtype ? C4::Koha::getitemtypeimagelocation( 'intranet', $itemtype->imageurl ) : q{};
                $this_item->{description}       = $itemtype ? $itemtype->description : q{}; #FIXME Should this be translated_description ?
                $this_item->{notforloan}        = $itemtype->notforloan if $itemtype;
                $this_item->{'coins'}           = $biblio->get_coins;
                $this_item->{'normalized_upc'}  = GetNormalizedUPC( $record, $marcflavour );
                $this_item->{'normalized_ean'}  = GetNormalizedEAN( $record, $marcflavour );
                $this_item->{'normalized_oclc'} = GetNormalizedOCLCNumber( $record, $marcflavour );
                $this_item->{'normalized_isbn'} = GetNormalizedISBN( undef, $record, $marcflavour );

                unless ( defined $this_item->{size} ) {

                    #TT has problems with size
                    $this_item->{size} = q||;
                }

                # Getting items infos for location display
                my @items_infos = &GetItemsLocationInfo( $biblionumber );
                $this_item->{'ITEM_RESULTS'} = \@items_infos;
                $this_item->{biblionumber} = $biblionumber;
                push @items, $this_item;
            }

            my $some_private_shelves = Koha::Virtualshelves->get_some_shelves(
                {
                    borrowernumber => $loggedinuser,
                    add_allowed    => 1,
                    public         => 0,
                }
            );
            my $some_public_shelves = Koha::Virtualshelves->get_some_shelves(
                {
                    borrowernumber => $loggedinuser,
                    add_allowed    => 1,
                    public         => 1,
                }
            );

            $template->param(
                add_to_some_private_shelves => $some_private_shelves,
                add_to_some_public_shelves  => $some_public_shelves,
                can_manage_shelf   => $shelf->can_be_managed($loggedinuser),
                can_remove_shelf   => $shelf->can_be_deleted($loggedinuser),
                can_remove_biblios => $shelf->can_biblios_be_removed($loggedinuser),
                can_add_biblios    => $shelf->can_biblios_be_added($loggedinuser),
                sortfield          => $sortfield,
                itemsloop          => \@items,
                sortfield          => $sortfield,
                direction          => $direction,
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
        push @messages, { type => 'alert', code => 'does_not_exist' };
    }
}

$template->param(
    op       => $op,
    referer  => $referer,
    shelf    => $shelf,
    messages => \@messages,
    public   => $public,
    print    => scalar $query->param('print') || 0,
    csv_profiles => [ Koha::CsvProfiles->search({ type => 'marc', used_for => 'export_records' }) ],
);

output_html_with_http_headers $query, $cookie, $template->output;
