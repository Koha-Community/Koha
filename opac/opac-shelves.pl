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


=head1 NAME

    opac-shelves.pl

=head1 DESCRIPTION

    this script is used to script to provide virtualshelf management

=head1 CGI PARAMETERS

=over 4

=item C<modifyshelfcontents>

    if this script has to modify the shelve content.

=item C<shelfnumber>

    to know on which shelve this script has to work.

=item C<addbarcode>

=item C<op>

    op can be equals to:
        * modifsave to save change on the shelves
        * modif to change the template to allow to modify the shelves.

=item C<viewshelf>

    to load the template with 'viewshelves param' which allow to read the shelves information.

=item C<shelves>

    if equals to 1. then call the function shelves which add
    or delete a shelf.

=item C<addshelf>

    if the param shelves = 1 then addshelf must be equals to the name of the shelf to add.

=back

=cut

use strict;
use warnings;
use CGI;
use C4::Output;
use C4::VirtualShelves;
use C4::Circulation;
use C4::Auth;
use C4::Output;
use C4::Biblio;

my $query = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-shelves.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

if ( $query->param('modifyshelfcontents') ) {
    my $shelfnumber = $query->param('viewshelf');
    my $barcode     = $query->param('addbarcode');
    my ($item) = GetItemnumberFromBarcode($barcode);
    my ($biblio) = GetBiblioFromItemNumber($item->{'itemnumber'});
    if ( ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' ) ) {
        AddToShelf( $biblio->{'biblionumber'}, $shelfnumber );
        foreach ( $query->param ) {
            if (/REM-(\d*)/) {
                my $biblionumber = $1;
                DelFromShelf( $biblionumber, $shelfnumber );
            }
        }
    }
}

# set the default tab, etc.
my $shelf_type = $query->param('display');
if ((!$shelf_type) || ($shelf_type eq 'privateshelves'))  {
    $template->param(showprivateshelves => 1);
} elsif ($shelf_type eq 'publicshelves') {
    $template->param(showpublicshelves => 1);
}

# getting the Shelves list
my $shelflist = GetShelves( $loggedinuser, 2 );
$template->param( { loggedinuser => $loggedinuser } );
my $op = $query->param('op');

SWITCH: {
    if ( $op && ( $op eq 'modifsave' ) ) {
        ModShelf(
            $query->param('shelfnumber'), $query->param('shelfname'),
            $loggedinuser,                $query->param('category'), $query->param('sortfield')
        );
        last SWITCH;
    }
    if ( $op && ( $op eq 'modif' ) ) {
        my ( $shelfnumber, $shelfname, $owner, $category, $sortfield ) =
          GetShelf( $query->param('shelf') );
        $template->param(
            edit                => 1,
            shelfnumber         => $shelfnumber,
            shelfname           => $shelfname,
            "category$category" => 1,
            "sort_$sortfield"   => 1,
        );
        last SWITCH;
    }
    if ( $query->param('viewshelf') ) {

        #check that the user can view the shelf
        my $shelfnumber = $query->param('viewshelf');
        if ( ShelfPossibleAction( $loggedinuser, $shelfnumber, 'view' ) ) {
            my $items = GetShelfContents($shelfnumber);
            $template->param(
                shelfname   => $shelflist->{$shelfnumber}->{'shelfname'},
                shelfnumber => $shelfnumber,
                viewshelf   => $query->param('viewshelf'),
                manageshelf => &ShelfPossibleAction( $loggedinuser, $shelfnumber, 'manage' ),
                itemsloop   => $items,
            );
        }
        last SWITCH;
    }
    if ( $query->param('shelves') ) {
        if ( my $newshelf = $query->param('addshelf') ) {
            my $shelfnumber = AddShelf(
                $newshelf,
                $query->param('owner'),
                $query->param('category')
            );

            if ( $shelfnumber == -1 ) {    #shelf already exists.
                $template->param(
                    {
                        shelfnumber => $shelfnumber,
                        already     => 1
                    }
                );
            }
            print $query->redirect("/cgi-bin/koha/opac-shelves.pl?viewshelf=$shelfnumber");
            exit;
        }
        my @paramsloop;
        foreach ( $query->param() ) {
            my %line;
            if (/DEL-(\d+)/) {
                my $delshelf = $1;
                my ( $status, $count ) = DelShelf($delshelf);
                if ($status) {
                    $line{'status'} = $status;
                    $line{'count'}  = $count;
                }
                print $query->redirect("/cgi-bin/koha/opac-shelves.pl");
                exit;
            }

            #if the shelf is not deleted, %line points on null
            # push( @paramsloop, \%line );
        }
        $template->param( paramsloop => \@paramsloop );
        my ($shelflist) = GetShelves( $loggedinuser, 2 );
        my $color = '';
        my @shelvesloop;
        foreach my $element ( sort keys %$shelflist ) {
            my %line;
            ( $color eq 1 ) ? ( $color = 0 ) : ( $color = 1 );
            $line{'toggle'}         = $color;
            $line{'shelf'}          = $element;
            $line{'shelfname'}      = $shelflist->{$element}->{'shelfname'};
            $line{'shelfvirtualcount'} = $shelflist->{$element}->{'count'};
            push( @shelvesloop, \%line );
        }
        $template->param(
            shelvesloop => \@shelvesloop,
            shelves     => 1,
        );
        last SWITCH;
    }
}

# rebuild shelflist in case a shelf has been added
($shelflist) = GetShelves( $loggedinuser, 2 ) ;    
my $color='';
my @shelvesloop;
my @shelveslooppriv;

foreach my $element (sort { lc($shelflist->{$a}->{'shelfname'}) cmp lc($shelflist->{$b}->{'shelfname'}) } keys %$shelflist) {
    my %line;
    my %linepriv;
    ($color eq 0) ? ($color=1) : ($color=0);
    if ($shelflist->{$element}->{'category'} eq 2) {
        $line{'toggle'}= $color;
        $line{'shelf'}=$element;
        $line{'shelfname'}=$shelflist->{$element}->{'shelfname'};
        $line{'sortfield'}=$shelflist->{$element}->{'sortfield'};
        $line{"category".$shelflist->{$element}->{'category'}} = 1;
        $line{'mine'} = 1 if $shelflist->{$element}->{'owner'} eq $loggedinuser;
        $line{'shelfvirtualcount'}=$shelflist->{$element}->{'count'};
        $line{'canmanage'} = ShelfPossibleAction($loggedinuser,$element,'manage');
        $line{'firstname'}=$shelflist->{$element}->{'firstname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
        $line{'surname'}=$shelflist->{$element}->{'surname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
        push (@shelvesloop, \%line);
    } elsif ($shelflist->{$element}->{'category'} eq 1) {
        $linepriv{'toggle'}= $color;
        $linepriv{'shelf'}=$element;
        $linepriv{'shelfname'}=$shelflist->{$element}->{'shelfname'};
        $linepriv{'sortfield'}=$shelflist->{$element}->{'sortfield'};
        $linepriv{"category".$shelflist->{$element}->{'category'}} = 1;
        $linepriv{'mine'} = 1 if $shelflist->{$element}->{'owner'} eq $loggedinuser;
        $linepriv{'shelfvirtualcount'}=$shelflist->{$element}->{'count'};
        $linepriv{'canmanage'} = ShelfPossibleAction($loggedinuser,$element,'manage');
        $linepriv{'firstname'}=$shelflist->{$element}->{'firstname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
        $linepriv{'surname'}=$shelflist->{$element}->{'surname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
        push (@shelveslooppriv, \%linepriv);
    }
}

$template->param(
    shelveslooppriv => \@shelveslooppriv,
    shelvesloop             => \@shelvesloop,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;
