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
use C4::Biblio;
use C4::Output;
use C4::Auth;

use Koha::Virtualshelves;

my $query           = new CGI;
my @biblionumbers   = $query->multi_param('biblionumber');
my $selectedshelf   = $query->param('selectedshelf');
my $newshelf        = $query->param('newshelf');
my $shelfnumber     = $query->param('shelfnumber');
my $newvirtualshelf = $query->param('newvirtualshelf');
my $category        = $query->param('category');
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
        authnotrequired => 0,
    }
);

if ($newvirtualshelf) {
    if ($loggedinuser > 0
        and (  $category == 1
            or $category == 2 and $loggedinuser > 0 && C4::Context->preference('OpacAllowPublicListCreation') )
      ) {
        my $shelf = eval { Koha::Virtualshelf->new( { shelfname => $newvirtualshelf, category => $category, owner => $loggedinuser, } )->store; };
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
    } else {
        $authorized = 0;
    }
}

if ($authorized) {
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
        OpacAllowPublicListCreation => C4::Context->preference('OpacAllowPublicListCreation'),
    );
}
$template->param( authorized => $authorized, errcode => $errcode, );
output_html_with_http_headers $query, $cookie, $template->output;
