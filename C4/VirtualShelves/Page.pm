package C4::VirtualShelves::Page;

#
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

# perldoc at the end of the file, per convention.

use strict;
use warnings;

use CGI;
use Exporter;
use Data::Dumper;

use C4::VirtualShelves qw/:DEFAULT ShelvesMax/;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Auth qw/get_session/;
use C4::Members;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Tags qw(get_tags);
use C4::Csv;
use C4::XSLT;

use constant VIRTUALSHELVES_COUNT => 20;

use vars qw($debug @EXPORT @ISA $VERSION);

BEGIN {
    $VERSION = 3.07.00.049;
    @ISA     = qw(Exporter);
    @EXPORT  = qw(&shelfpage);
    $debug   = $ENV{DEBUG} || 0;
}

our %pages = (
    intranet => { redirect => '/cgi-bin/koha/virtualshelves/shelves.pl', },
    opac     => { redirect => '/cgi-bin/koha/opac-shelves.pl', },
);

sub shelfpage {
    my ( $type, $query, $template, $loggedinuser, $cookie ) = @_;
    ( $pages{$type} ) or $type = 'opac';
    $query            or die "No query";
    $template         or die "No template";
    $template->param(
    loggedinuser => $loggedinuser,
    OpacAllowPublicListCreation => C4::Context->preference('OpacAllowPublicListCreation'),
    );
    my $edit;
    my $shelves;
    my @paramsloop;
    my $totitems;
    my $shelfoff    = ( $query->param('shelfoff') ? $query->param('shelfoff') : 1 );
    $template->{VARS}->{'shelfoff'} = $shelfoff;
    my $itemoff     = ( $query->param('itemoff')  ? $query->param('itemoff')  : 1 );
    my $displaymode = ( $query->param('display')  ? $query->param('display')  : 'publicshelves' );
    my ( $shelflimit, $shelfoffset, $shelveslimit, $shelvesoffset );
    my $marcflavour = C4::Context->preference("marcflavour");

    # get biblionumbers stored in the cart
    my @cart_list;
    my $cart_cookie = ( $type eq 'opac' ? "bib_list" : "intranet_bib_list" );
    if($query->cookie($cart_cookie)){
        my $cart_list = $query->cookie($cart_cookie);
        @cart_list = split(/\//, $cart_list);
    }

    $shelflimit = ( $type eq 'opac' ? C4::Context->preference('OPACnumSearchResults') : C4::Context->preference('numSearchResults') );
    $shelflimit = $shelflimit || ShelvesMax('MGRPAGE');
    $shelfoffset   = ( $itemoff - 1 ) * $shelflimit;     # Sets the offset to begin retrieving items at
    $shelveslimit  = $shelflimit;                        # Limits number of shelves returned for a given query (row_count)
    $shelvesoffset = ( $shelfoff - 1 ) * $shelflimit;    # Sets the offset to begin retrieving shelves at (offset)
                                                # getting the Shelves list
    my $category = ( ( $displaymode eq 'privateshelves' ) ? 1 : 2 );
    my ( $shelflist, $totshelves ) = GetShelves( $category, $shelveslimit, $shelvesoffset, $loggedinuser );

    #Get a list of private shelves for possible deletion. Only do this when we've defaulted to public shelves
    my ( $privshelflist, $privtotshelves );
    if ( $category == 2 ) {
        ( $privshelflist, $privtotshelves ) = GetShelves( 1, $shelveslimit, $shelvesoffset, $loggedinuser );
    }
    my $op = $query->param('op');

    # the format of this is unindented for ease of diff comparison to the old script
    # Note: do not mistake the assignment statements below for comparisons!
    if ( $query->param('modifyshelfcontents') ) {
        my ( $shelfnumber, $barcode, $item, $biblio );
        if ( $shelfnumber = $query->param('viewshelf') ) {
            #add to shelf
            if($barcode = $query->param('addbarcode') ) {
                if(ShelfPossibleAction( $loggedinuser, $shelfnumber, 'add')) {
                    $item = GetItem( 0, $barcode);
                    if (defined $item && $item->{'itemnumber'}) {
                        $biblio = GetBiblioFromItemNumber( $item->{'itemnumber'} );
                        AddToShelf( $biblio->{'biblionumber'}, $shelfnumber, $loggedinuser)
                          or push @paramsloop, { duplicatebiblio => $barcode };
                    }
                    else {
                        push @paramsloop, { failgetitem => $barcode };
                    }
                }
                else {
                    push @paramsloop, { nopermission => $shelfnumber };
                }
            }
            elsif(grep { /REM-(\d+)/ } $query->param) {
            #remove item(s) from shelf
                if(ShelfPossibleAction($loggedinuser, $shelfnumber, 'delete')) {
                #This is just a general okay; DelFromShelf checks further
                    my @bib;
                    foreach($query->param) {
                        /REM-(\d+)/ or next;
                        push @bib, $1; #$1 is biblionumber
                    }
                    my $t= DelFromShelf(\@bib, $shelfnumber, $loggedinuser);
                    if($t==0) {
                        push @paramsloop, {nothingdeleted => $shelfnumber};
                    }
                    elsif($t<@bib) {
                        push @paramsloop, {somedeleted => $shelfnumber};
                    }
                }
                else {
                    push @paramsloop, { nopermission => $shelfnumber };
                }
            }
        }
        else {
            push @paramsloop, { noshelfnumber => 1 };
        }
    }

    my $showadd = 1;

    # set the default tab, etc. (for OPAC)
    my $shelf_type = ( $query->param('display') ? $query->param('display') : 'publicshelves' );
    if ( defined $shelf_type ) {
        if ( $shelf_type eq 'privateshelves' ) {
            $template->param( showprivateshelves => 1 );
        } elsif ( $shelf_type eq 'publicshelves' ) {
            $template->param( showpublicshelves => 1 );
            $showadd = 0;
        } else {
            $debug and warn "Invalid 'display' param ($shelf_type)";
        }
    } elsif ( $loggedinuser == -1 ) {
        $template->param( showpublicshelves => 1 );
    } else {
        $template->param( showprivateshelves => 1 );
    }

    my ( $okmanage, $okview );
    my $shelfnumber = $query->param('shelfnumber') || $query->param('viewshelf');
    if ($shelfnumber) {
        $okmanage = ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' );
        $okview   = ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' );
    }

    my $delflag = 0;

  SWITCH: {
        if ($op) {
        #Saving modified shelf
            if ( $op eq 'modifsave' ) {
                unless ($okmanage) {
                        push @paramsloop, { nopermission => $shelfnumber };
                        last SWITCH;
                }
                my $shelf = {
                    shelfname          => $query->param('shelfname'),
                    sortfield          => $query->param('sortfield'),
                    allow_add          => $query->param('allow_add'),
                    allow_delete_own   => $query->param('allow_delete_own'),
                    allow_delete_other => $query->param('allow_delete_other'),
                };
                if($query->param('category')) { #optional
                    $shelf->{category}= $query->param('category');
                }
                unless(ModShelf($shelfnumber, $shelf )) {
                  push @paramsloop, {modifyfailure => $shelf->{shelfname}};
                  last SWITCH;
                }

                if($displaymode eq "viewshelf"){
                    print $query->redirect( $pages{$type}->{redirect} . "?viewshelf=$shelfnumber" );
                } elsif($displaymode eq "publicshelves"){
                    print $query->redirect( $pages{$type}->{redirect} );
                } else {
                    print $query->redirect( $pages{$type}->{redirect} . "?display=privateshelves" );
                }
                exit;
            }
        #Editing a shelf
        elsif ( $op eq 'modif' ) {
                my ( $shelfnumber2, $shelfname, $owner, $category, $sortfield, $allow_add, $allow_delete_own, $allow_delete_other) = GetShelf($shelfnumber);
                my $member = GetMember( 'borrowernumber' => $owner );
                my $ownername = defined($member) ? $member->{firstname} . " " . $member->{surname} : '';
                $edit = 1;
                $template->param(
                    edit                => 1,
                    display             => $displaymode,
                    shelfnumber         => $shelfnumber2,
                    shelfname           => $shelfname,
                    owner               => $owner,
                    ownername           => $ownername,
                    "category$category" => 1,
                    category            => $category,
                    sortfield           => $sortfield,
                    allow_add           => $allow_add,
                    allow_delete_own    => $allow_delete_own,
                    allow_delete_other  => $allow_delete_other,
                );
            }
            last SWITCH;
        }

        #View a shelf
        if ( $shelfnumber = $query->param('viewshelf') ) {
            # explicitly fetch this shelf
            my ($shelfnumber2,$shelfname,$owner,$category,$sorton) = GetShelf($shelfnumber);

            $template->param(
                'AllowOnShelfHolds'     => C4::Context->preference('AllowOnShelfHolds'),
                'DisplayMultiPlaceHold' => C4::Context->preference('DisplayMultiPlaceHold'),
            );
            if (C4::Context->preference('TagsEnabled')) {
                $template->param(TagsEnabled => 1);
                    foreach (qw(TagsShowOnList TagsInputOnList)) {
                    C4::Context->preference($_) and $template->param($_ => 1);
                }
            }
            #check that the user can view the shelf
            if ( ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' ) ) {
                my $items;
                my $tag_quantity;
                my $sortfield = ( $sorton ? $sorton : 'title' );
                $sortfield = $query->param('sort') || $sortfield; ## Passed in sorting overrides default sorting
                my $direction = $query->param('direction') || 'asc';
                $template->param(
                    sort      => $sortfield,
                    direction => $direction,
                );
                ( $items, $totitems ) = GetShelfContents( $shelfnumber, $shelflimit, $shelfoffset, $sortfield, $direction );
                for my $this_item (@$items) {
                    my $biblionumber = $this_item->{'biblionumber'};
                    my $record = GetMarcBiblio($biblionumber);
                    if (C4::Context->preference("OPACXSLTResultsDisplay") && $type eq 'opac') {
                        $this_item->{XSLTBloc} = XSLTParse4Display($biblionumber, $record, "OPACXSLTResultsDisplay");
                    } elsif (C4::Context->preference("XSLTResultsDisplay") && $type eq 'intranet') {
                        $this_item->{XSLTBloc} = XSLTParse4Display($biblionumber, $record, "XSLTResultsDisplay");
                    }

                    # the virtualshelfcontents table does not store these columns nor are they retrieved from the items
                    # and itemtypes tables, so I'm commenting them out for now to quiet the log -crn
                    #$this_item->{imageurl} = $imgdir."/".$itemtypes->{ $this_item->{itemtype}  }->{'imageurl'};
                    #$this_item->{'description'} = $itemtypes->{ $this_item->{itemtype} }->{'description'};
                    $this_item->{'dateadded'} = format_date( $this_item->{'dateadded'} );
                    $this_item->{'imageurl'}  = getitemtypeinfo( $this_item->{'itemtype'}, $type )->{'imageurl'};
                    $this_item->{'coins'}     = GetCOinSBiblio( $record );
                    $this_item->{'subtitle'} = GetRecordValue('subtitle', $record, GetFrameworkCode($this_item->{'biblionumber'}));
                    $this_item->{'normalized_upc'}  = GetNormalizedUPC(       $record,$marcflavour);
                    $this_item->{'normalized_ean'}  = GetNormalizedEAN(       $record,$marcflavour);
                    $this_item->{'normalized_oclc'} = GetNormalizedOCLCNumber($record,$marcflavour);
                    $this_item->{'normalized_isbn'} = GetNormalizedISBN(undef,$record,$marcflavour);
                    if(!defined($this_item->{'size'})) { $this_item->{'size'} = "" }; #TT has problems with size
                    # Getting items infos for location display
                    my @items_infos = &GetItemsLocationInfo( $this_item->{'biblionumber'});
                    $this_item->{'itemsissued'} = CountItemsIssued( $this_item->{'biblionumber'} );
                    $this_item->{'ITEM_RESULTS'} = \@items_infos;
                    if ( grep {$_ eq $biblionumber} @cart_list) {
                        $this_item->{'incart'} = 1;
                    }

                    if (C4::Context->preference('TagsEnabled') and $tag_quantity = C4::Context->preference('TagsShowOnList')) {
                        $this_item->{'TagLoop'} = get_tags({
                            biblionumber=>$this_item->{'biblionumber'}, approved=>1, 'sort'=>'-weight',
                            limit=>$tag_quantity
                            });
                    }

                }
                if($type eq 'intranet'){
                    # Build drop-down list for 'Add To:' menu...
                    my ($totalref, $pubshelves, $barshelves)=
                    C4::VirtualShelves::GetSomeShelfNames($loggedinuser,'COMBO',1);
                    $template->param(
                        addbarshelves     => $totalref->{bartotal},
                        addbarshelvesloop => $barshelves,
                        addpubshelves     => $totalref->{pubtotal},
                        addpubshelvesloop => $pubshelves,
                    );
                }
                push @paramsloop, { display => 'privateshelves' } if $category == 1;
                $showadd = 1;
                my $i = 0;
                my $manageshelf = ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' );
                $template->param(
                    shelfname           => $shelfname,
                    shelfnumber         => $shelfnumber,
                    viewshelf           => $shelfnumber,
                    sortfield           => $sortfield,
                    manageshelf         => $manageshelf,
                    allowremovingitems  => ShelfPossibleAction( $loggedinuser, $shelfnumber, 'delete'),
                    allowaddingitem     => ShelfPossibleAction( $loggedinuser, $shelfnumber, 'add'),
                    "category$category" => 1,
                    category            => $category,
                    itemsloop           => $items,
                    showprivateshelves  => $category==1,
                );
            } else {
                push @paramsloop, { nopermission => $shelfnumber };
            }
            last SWITCH;
        }

        if ( $query->param('shelves') ) {
            my $stay = 1;

        #Add a shelf
            if ( my $newshelf = $query->param('addshelf') ) {

                # note: a user can always add a new shelf (except database administrator account)
                my $shelfnumber = AddShelf( {
                    shelfname => $newshelf,
                    sortfield => $query->param('sortfield'),
                    category => $query->param('category'),
                    allow_add => $query->param('allow_add'),
                    allow_delete_own => $query->param('allow_delete_own'),
                    allow_delete_other => $query->param('allow_delete_other'),
                    },
                    $query->param('owner') );
                $stay = 1;
                if( !$shelfnumber ) {
                    push @paramsloop, { addshelf_failed => 1 };
                } elsif ( $shelfnumber == -1 ) {    #shelf already exists.
                    $showadd = 1;
                    push @paramsloop, { already => $newshelf };
                    $template->param( shelfnumber => $shelfnumber );
                } else {
                    print $query->redirect( $pages{$type}->{redirect} . "?viewshelf=$shelfnumber" );
                    exit;
                }
            }

        #Deleting a shelf (asking for confirmation if it has entries)
            foreach ( $query->param() ) {
                /(DEL|REMSHR)-(\d+)/ or next;
                $delflag = 1;
                my $number = $2;
                unless ( defined $shelflist->{$number} || defined $privshelflist->{$number} ) {
                    push( @paramsloop, { unrecognized => $number } );
                    last;
                }
                #remove a share
                if(/REMSHR/) {
                    RemoveShare($loggedinuser, $number);
                    delete $shelflist->{$number} if exists $shelflist->{$number};
                    delete $privshelflist->{$number} if exists $privshelflist->{$number};
                    $stay=0;
                    next;
                }
                #
                unless ( ShelfPossibleAction( $loggedinuser, $number, 'manage' ) ) {
                    push( @paramsloop, { nopermission => $shelfnumber } );
                    last;
                }
                my $contents;
                ( $contents, $totshelves ) = GetShelfContents( $number, $shelveslimit, $shelvesoffset );
                if ( $totshelves > 0 ) {
                    unless ( scalar grep { /^CONFIRM-$number$/ } $query->param() ) {
                        if ( defined $shelflist->{$number} ) {
                            push( @paramsloop, { need_confirm => $shelflist->{$number}->{shelfname}, count => $totshelves, single => ($totshelves eq 1 ? 1:0) } );
                            $shelflist->{$number}->{confirm} = $number;
                        } else {
                            push( @paramsloop, { need_confirm => $privshelflist->{$number}->{shelfname}, count => $totshelves } );
                            $privshelflist->{$number}->{confirm} = $number;
                        }
                        $stay = 0;
                        next;
                    }
                }
                my $name;
                if ( defined $shelflist->{$number} ) {
                    $name = $shelflist->{$number}->{'shelfname'};
                    delete $shelflist->{$number};
                } else {
                    $name = $privshelflist->{$number}->{'shelfname'};
                    delete $privshelflist->{$number};
                }
                unless ( DelShelf($number) ) {
                    push( @paramsloop, { delete_fail => $name } );
                    last;
                }
                push( @paramsloop, { delete_ok => $name } );

                $stay = 0;
            }
            $showadd = 1;
            if ($stay){
                $template->param( shelves => 1 );
                $shelves = 1;
            }
            last SWITCH;
        }
    } # end of SWITCH block

    (@paramsloop) and $template->param( paramsloop => \@paramsloop );
    $showadd      and $template->param( showadd    => 1 );
    my @shelvesloop;
    my @shelveslooppriv;
    my $numberCanManage = 0;

    # rebuild shelflist in case a shelf has been added
    ( $shelflist, $totshelves ) = GetShelves( $category, $shelveslimit, $shelvesoffset, $loggedinuser ) unless $delflag;
    foreach my $element ( sort { lc( $shelflist->{$a}->{'shelfname'} ) cmp lc( $shelflist->{$b}->{'shelfname'} ) } keys %$shelflist ) {
        my %line;
        $shelflist->{$element}->{shelf} = $element;
        my $category  = $shelflist->{$element}->{'category'};
        my $owner     = $shelflist->{$element}->{'owner'}||0;
        my $canmanage = ShelfPossibleAction( $loggedinuser, $element, 'manage' );
        $shelflist->{$element}->{"viewcategory$category"} = 1;
        $shelflist->{$element}->{manageshelf} = $canmanage;
        if($canmanage || ($loggedinuser && $owner==$loggedinuser)) {
            $shelflist->{$element}->{'mine'} = 1;
        }
        my $member = GetMember( 'borrowernumber' => $owner );
        $shelflist->{$element}->{ownername} = defined($member) ? $member->{firstname} . " " . $member->{surname} : '';
        $numberCanManage++ if $canmanage;    # possibly outmoded
        if ( $shelflist->{$element}->{'category'} eq '1' ) {
            $shelflist->{$element}->{shares} = IsSharedList($element);
            push( @shelveslooppriv, $shelflist->{$element} );
        } else {
            push( @shelvesloop, $shelflist->{$element} );
        }
    }

    my $url = $type eq 'opac' ? "/cgi-bin/koha/opac-shelves.pl" : "/cgi-bin/koha/virtualshelves/shelves.pl";
    my %qhash = ();
    foreach (qw(display viewshelf sortfield sort direction)) {
        $qhash{$_} = $query->param($_) if $query->param($_);
    }
    ( scalar keys %qhash ) and $url .= '?' . join '&', map { "$_=$qhash{$_}" } keys %qhash;
    if ( $shelfnumber && $totitems ) {
        $template->param(  pagination_bar => pagination_bar( $url, ( int( $totitems / $shelflimit ) ) + ( ( $totitems % $shelflimit ) > 0 ? 1 : 0 ), $itemoff, "itemoff" )  );
    } elsif ( $totshelves ) {
        $template->param(
             pagination_bar => pagination_bar( $url, ( int( $totshelves / $shelveslimit ) ) + ( ( $totshelves % $shelveslimit ) > 0 ? 1 : 0 ), $shelfoff, "shelfoff" )  );
    }
    $template->param(
        shelveslooppriv                                                    => \@shelveslooppriv,
        shelvesloop                                                        => \@shelvesloop,
        shelvesloopall                                                     => [ ( @shelvesloop, @shelveslooppriv ) ],
        numberCanManage                                                    => $numberCanManage,
        "BiblioDefaultView" . C4::Context->preference("BiblioDefaultView") => 1,
        csv_profiles                                                       => GetCsvProfilesLoop('marc')
    );
    if (   $shelfnumber
        or $shelves
        or $edit ) {
        $template->param( vseflag => 1 );
    }
    if ($shelves or    # note: this part looks duplicative, but is intentional
        $edit
      ) {
        $template->param( seflag => 1 );
        #This hack is just another argument for refactoring this script one day
        #At this point you are adding or editing a list; if you add, then you add a private list (by default) with permissions as below; if you edit, do not pass these permissions, they must come from the database
        $template->param( allow_add => 0, allow_delete_own => 1, allow_delete_other => 0) unless $shelfnumber;
    }

#Next call updates the shelves for the Lists button.
#May not always be needed (when nothing changed), but doesn't take much.
    my ($total, $pubshelves, $barshelves) = C4::VirtualShelves::GetSomeShelfNames($loggedinuser, 'MASTHEAD');
    $template->param(
            barshelves     => $total->{bartotal},
            barshelvesloop => $barshelves,
            pubshelves     => $total->{pubtotal},
            pubshelvesloop => $pubshelves,
    );

    output_html_with_http_headers $query, $cookie, $template->output;
}

1;
__END__

=head1 NAME

VirtualShelves/Page.pm

=head1 DESCRIPTION

Module used for both OPAC and intranet pages.

=head1 CGI PARAMETERS

=over 4

=item C<modifyshelfcontents>

If this script has to modify the shelf content.

=item C<shelfnumber>

To know on which shelf to work.

=item C<addbarcode>

=item C<op>

 Op can be:
    * modif: show the template allowing modification of the shelves;
    * modifsave: save changes from modif mode.

=item C<viewshelf>

Load template with 'viewshelves param' displaying the shelf's information.

=item C<shelves>

If the param shelves == 1, then add or delete a shelf.

=item C<addshelf>

If the param shelves == 1, then addshelf is the name of the shelf to add.

=back

=cut
