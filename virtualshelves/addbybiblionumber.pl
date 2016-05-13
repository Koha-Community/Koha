#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2016 Koha Development Team
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


=head1 NAME

addbybiblionumber.pl

=head1 DESCRIPTION

    This script allow to add a virtual in a virtual shelf from a biblionumber.

=head1 CGI PARAMETERS

=over 4

=item biblionumber

    The biblionumber

=item shelfnumber

    the shelfnumber where to add the virtual.

=item newvirtualshelf

    if this parameter exists, then it must be equals to the name of the shelf
    to add.

=item category

    if this script has to add a shelf, it add one with this category.

=item newshelf

    if this parameter exists, then we create a new shelf

=back

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Biblio;
use C4::Output;
use C4::Auth;

use Koha::Virtualshelves;

my $query           = new CGI;
my $shelfnumber     = $query->param('shelfnumber');
my $newvirtualshelf = $query->param('newvirtualshelf');
my $newshelf        = $query->param('newshelf');
my $category        = $query->param('category');
my $sortfield       = $query->param('sortfield');
my $confirmed       = $query->param('confirmed') || 0;
my ( $errcode, $authorized ) = ( 0, 1 );
my @biblionumbers = $query->multi_param('biblionumber');

if ( @biblionumbers == 0 && $query->param('biblionumbers') ) {
    my $str = $query->param('biblionumbers');
    @biblionumbers = split '/', $str;
} elsif ( @biblionumbers == 1 && $biblionumbers[0] =~ /\// ) {
    @biblionumbers = split '/', $biblionumbers[0];
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "virtualshelves/addbybiblionumber.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

if ($newvirtualshelf) {
    my $shelf = eval {
        Koha::Virtualshelf->new(
            {
                shelfname => $newvirtualshelf,
                category  => $category,
                sortfield => $sortfield,
                owner     => $loggedinuser,
            }
        )->store;
    };
    if ( $@ or not $shelf ) {
        $errcode    = 1;
        $authorized = 0;
    } else {

        for my $biblionumber (@biblionumbers) {
            $shelf->add_biblio( $biblionumber, $loggedinuser );
        }

        #Reload the page where you came from
        print $query->header;
        print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"window.opener.location.reload(true);self.close();\"></body></html>";
        exit;
    }

} elsif ( $shelfnumber && $confirmed ) {
    my $shelf = Koha::Virtualshelves->find($shelfnumber);
    if ( $shelf->can_biblios_be_added($loggedinuser) ) {
        for my $biblionumber (@biblionumbers) {
            $shelf->add_biblio( $biblionumber, $loggedinuser );
        }

        #Close this page and return
        print $query->header;
        print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"self.close();\"></body></html>";
        exit;
    } else {
        $errcode    = 2;    #no perm
        $authorized = 0;
    }

} elsif ($shelfnumber) {    #still needs confirmation
    my $shelf = Koha::Virtualshelves->find($shelfnumber);
    if ( $shelf->can_biblios_be_added($loggedinuser) ) {

        #confirm adding to specific shelf
        $template->param(
            singleshelf => 1,
            shelfnumber => $shelf->shelfnumber,
            shelfname   => $shelf->shelfname,
        );
    } else {
        $authorized = 0;
        $errcode    = 2;    #no perm
    }

} else {
    my $private_shelves = Koha::Virtualshelves->search(
        {   category => 1,
            owner    => $loggedinuser,
        },
        { order_by => 'shelfname' }
    );
    my $shelves_shared_with_me = Koha::Virtualshelves->search(
        {   category                            => 1,
            'virtualshelfshares.borrowernumber' => $loggedinuser,
            -or                                 => {
                allow_add => 1,
                owner     => $loggedinuser,
            }
        },
        { join => 'virtualshelfshares', }
    );
    my $public_shelves = Koha::Virtualshelves->search(
        {   category => 2,
            -or      => {
                allow_add => 1,
                owner     => $loggedinuser,
            }
        },
        { order_by => 'shelfname' }
    );
    $template->param(
        private_shelves                => $private_shelves,
        private_shelves_shared_with_me => $shelves_shared_with_me,
        public_shelves                 => $public_shelves,
    );

}

my @biblios;
for my $biblionumber (@biblionumbers) {
    my $data = GetBiblioData($biblionumber);
    push(
        @biblios,
        {   biblionumber => $biblionumber,
            title        => $data->{'title'},
            author       => $data->{'author'},
        }
    );
}
$template->param(
    multiple => ( scalar(@biblios) > 1 ),
    total    => scalar @biblios,
    biblios  => \@biblios,
);

$template->param(
    newshelf => $newshelf || 0,
    authorized => $authorized,
    errcode    => $errcode,
);
output_html_with_http_headers $query, $cookie, $template->output;
