#!/usr/bin/perl

#script to provide virtualshelf management
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

use strict;
use warnings;

use CGI qw ( -utf8 );
use C4::Biblio;
use C4::Output;
use C4::Auth;

use Koha::Virtualshelves;

our $query        	= new CGI;
our @biblionumber 	= $query->param('biblionumber');
our $selectedshelf 	= $query->param('selectedshelf');
our $newshelf 		= $query->param('newshelf');
our $shelfnumber  	= $query->param('shelfnumber');
our $newvirtualshelf	= $query->param('newvirtualshelf');
our $category     	= $query->param('category');
our $authorized          = 1;
our $errcode		= 0;
our @biblios = ();

# if virtualshelves is disabled, leave immediately
if ( ! C4::Context->preference('virtualshelves') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

if (scalar(@biblionumber) == 1) {
    @biblionumber = (split /\//,$biblionumber[0]);
}

our ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-addbybiblionumber.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
    }
);

if( $newvirtualshelf) {
    HandleNewVirtualShelf();
    exit if $authorized;
    ShowTemplate(); #error message
}
elsif($shelfnumber) {
    HandleShelfNumber();
    exit if $authorized;
    ShowTemplate(); #error message
}
elsif($selectedshelf) {
    HandleSelectedShelf();
    LoadBib() if $authorized;
    ShowTemplate();
}
else {
    HandleSelect();
    LoadBib() if $authorized;
    ShowTemplate();
}
#end

sub HandleNewVirtualShelf {
    if ( $loggedinuser > 0 and
        (
            $category == 1
                or $category == 2 and $loggedinuser>0 && C4::Context->preference('OpacAllowPublicListCreation')
        )
    ) {
        my $shelf = eval {
            Koha::Virtualshelf->new(
                {
                    shelfname => $newvirtualshelf,
                    category => $category,
                    owner => $loggedinuser,
                }
            )->store;
        };
        if ( $@ or not $shelf ) {
            $authorized = 0;
            $errcode = 1;
            return;
        }

        for my $bib (@biblionumber) {
            $shelf->add_biblio( $bib, $loggedinuser );
        }

        #Reload the page where you came from
        print $query->header;
        print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"window.opener.location.reload(true);self.close();\"></body></html>";
    }
}

sub HandleShelfNumber {
    my $shelfnumber = $query->param('shelfnumber');
    my $shelf = Koha::Virtualshelves->find( $shelfnumber );
    if ( $shelf->can_biblios_be_added( $loggedinuser ) ) {
        for my $bib (@biblionumber) {
            $shelf->add_biblio( $bib, $loggedinuser );
        }
        #Close this page and return
        print $query->header;
        print "<html><meta http-equiv=\"refresh\" content=\"0\" /><body onload=\"self.close();\"></body></html>";
    } else {
        # TODO
    }
}

sub HandleSelectedShelf {
    my $shelfnumber = $query->param('selectedshelf');
    my $shelf = Koha::Virtualshelves->find( $shelfnumber );
    if ( $shelf->can_biblios_be_added( $loggedinuser ) ) {
        $template->param(
            singleshelf               => 1,
            shelfnumber               => $shelf->shelfnumber,
            shelfname                 => $shelf->shelfname,
        );
    } else {
        # TODO
    }
}

sub HandleSelect {
    return unless $authorized= $loggedinuser>0;
    my $private_shelves = Koha::Virtualshelves->search(
        {
            category => 1,
            owner => $loggedinuser,
        },
        { order_by => 'shelfname' }
    );
    my $shelves_shared_with_me = Koha::Virtualshelves->search(
        {
            category => 1,
            'virtualshelfshares.borrowernumber' => $loggedinuser,
            -or => {
                allow_add => 1,
                owner => $loggedinuser,
            }
        },
        {
            join => 'virtualshelfshares',
        }
    );
    my $public_shelves= Koha::Virtualshelves->search(
        {
            category => 2,
            -or => {
                allow_add => 1,
                owner => $loggedinuser,
            }
        },
        { order_by => 'shelfname' }
    );
    $template->param (
        private_shelves => $private_shelves,
        private_shelves_shared_with_me => $shelves_shared_with_me,
        public_shelves  => $public_shelves,
    );
}

sub LoadBib {
    for my $bib (@biblionumber) {
        my $data = GetBiblioData( $bib );
        push(@biblios,
            { biblionumber => $bib,
              title        => $data->{'title'},
              author       => $data->{'author'},
        } );
    }
    $template->param(
        multiple => (scalar(@biblios) > 1),
    total    => scalar @biblios,
    biblios  => \@biblios,
    );
}

sub ShowTemplate {
    $template->param (
    newshelf => $newshelf||0,
    authorized	=> $authorized,
    errcode		=> $errcode,
    OpacAllowPublicListCreation => C4::Context->preference('OpacAllowPublicListCreation'),
    );
    output_html_with_http_headers $query, $cookie, $template->output;
}
