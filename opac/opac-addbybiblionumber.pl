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

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );

use Koha::Biblios;
use Koha::Virtualshelves;

my $query           = CGI->new;
my @biblionumbers   = $query->multi_param('biblionumber');
my $selectedshelf   = $query->param('selectedshelf');
my $newshelf        = $query->param('newshelf');
my $shelfnumber     = $query->param('shelfnumber');
my $newvirtualshelf = $query->param('newvirtualshelf');
my $public          = $query->param('public');
my ( $errcode, $authorized ) = ( 0, 1 );
my @biblios;

# if virtualshelves is disabled, leave immediately
if ( !C4::Context->preference('virtualshelves') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

if ( scalar(@biblionumbers) == 1 ) {
    @biblionumbers = ( split /\//, $biblionumbers[0] );
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "opac-addbybiblionumber.tt",
        query           => $query,
        type            => "opac",
    }
);

if ($newvirtualshelf) {
    if ($loggedinuser > 0
        and (  !$public
            or $public and $loggedinuser > 0 && C4::Context->preference('OpacAllowPublicListCreation') )
      ) {
        my $shelf = eval { Koha::Virtualshelf->new( { shelfname => $newvirtualshelf, public => $public, owner => $loggedinuser, } )->store; };
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
    }
} elsif ($shelfnumber) {
    my $shelfnumber = $query->param('shelfnumber');
    my $shelf       = Koha::Virtualshelves->find($shelfnumber);
    if ( $shelf->can_biblios_be_added($loggedinuser) ) {
        for my $biblionumber (@biblionumbers) {
            $shelf->add_biblio( $biblionumber, $loggedinuser );
        }

        #Close this page and return
        print $query->header;
        print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"self.close();\"></body></html>";
        exit;
    } else {
        $authorized = 0;
    }
} elsif ($selectedshelf) {
    my $shelfnumber = $query->param('selectedshelf');
    my $shelf       = Koha::Virtualshelves->find($shelfnumber);
    if ( $shelf->can_biblios_be_added($loggedinuser) ) {
        $template->param(
            singleshelf => 1,
            shelfnumber => $shelf->shelfnumber,
            shelfname   => $shelf->shelfname,
        );
    } else {
        $authorized = 0;
    }
} else {
    if ( $loggedinuser > 0 ) {
        my $private_shelves = Koha::Virtualshelves->search(
            {   public   => 0,
                owner    => $loggedinuser,
                allow_change_from_owner => 1,
            },
            { order_by => 'shelfname' }
        );
        my $shelves_shared_with_me = Koha::Virtualshelves->search(
            {   public                              => 0,
                'virtualshelfshares.borrowernumber' => $loggedinuser,
                allow_change_from_others            => 1,
            },
            { join => 'virtualshelfshares', }
        );
        my $public_shelves;
        if ( $loggedinuser ) {
            if ( Koha::Patrons->find( $loggedinuser )->can_patron_change_permitted_staff_lists ) {
                $public_shelves = Koha::Virtualshelves->search(
                    {   public   => 1,
                        -or      => [
                            -and => {
                                allow_change_from_owner => 1,
                                owner     => $loggedinuser,
                            },
                            allow_change_from_others          => 1,
                            allow_change_from_staff           => 1,
                            allow_change_from_permitted_staff => 1
                        ],
                    },
                    { order_by => 'shelfname' }
                );
            } elsif ( Koha::Patrons->find( $loggedinuser )->can_patron_change_staff_only_lists ) {
                $public_shelves = Koha::Virtualshelves->search(
                    {   public   => 1,
                        -or      => [
                            -and => {
                                allow_change_from_owner => 1,
                                owner     => $loggedinuser,
                            },
                            allow_change_from_others          => 1,
                            allow_change_from_staff           => 1
                        ],
                    },
                    { order_by => 'shelfname' }
                );
            } else {
                $public_shelves = Koha::Virtualshelves->search(
                    {   public   => 1,
                        -or      => [
                            -and => {
                                allow_change_from_owner => 1,
                                owner => $loggedinuser,
                            },
                            allow_change_from_others => 1,
                        ],
                    },
                    {order_by => 'shelfname' }
                );
            }
        } else {
            $public_shelves = Koha::Virtualshelves->search(
                {   public   => 1,
                    -or      => [
                        -and => {
                            allow_change_from_owner => 1,
                            owner => $loggedinuser,
                        },
                        allow_change_from_others => 1,
                    ],
                },
                {order_by => 'shelfname' }
            );
        }

        $template->param(
            private_shelves                => $private_shelves,
            private_shelves_shared_with_me => $shelves_shared_with_me,
            public_shelves                 => $public_shelves,
        );
    } else {
        $authorized = 0;
    }
}

if ($authorized) {
    for my $biblionumber (@biblionumbers) {
        my $biblio = Koha::Biblios->find( $biblionumber );
        push(
            @biblios,
            {   biblionumber => $biblionumber,
                title        => $biblio->title,
                subtitle     => $biblio->subtitle,
                medium       => $biblio->medium,
                part_number  => $biblio->part_number,
                part_name    => $biblio->part_name,
                author       => $biblio->author,
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
        OpacAllowPublicListCreation => C4::Context->preference('OpacAllowPublicListCreation'),
    );
}
$template->param( authorized => $authorized, errcode => $errcode, );
output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
