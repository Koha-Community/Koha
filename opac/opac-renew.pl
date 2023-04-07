#!/usr/bin/perl

#written 18/1/2000 by chris@katipo.co.nz
# adapted for use in the hlt opac by finlay@katipo.co.nz 29/11/2002
# script to renew items from the web
# Parts Copyright 2010,2011 Catalyst IT

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
use C4::Circulation qw( CanBookBeRenewed AddRenewal );
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Members;
use Koha::Items;
use Koha::Patrons;
my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
	{
        template_name   => "opac-user.tt",
        query           => $query,
        type            => "opac",
	}
);
my @issues = $query->multi_param('issue');

my $opacrenew = C4::Context->preference("OpacRenewalAllowed");

my $errorstring = q{};
my $renewed     = q{};

my $patron = Koha::Patrons->find( $borrowernumber );

if (   $patron->category->effective_BlockExpiredPatronOpacActions
    && $patron->is_expired )
{
    $errorstring = 'card_expired';
}
else {
    my @renewed;
    my $issues = Koha::Checkouts->search(
        {
            issue_id => { -in => \@issues }
        }, {
            prefetch => 'item'
        }
    );
    while( my $issue = $issues->next) {
        my ( $status, $error ) =
          CanBookBeRenewed( $patron, $issue );
        if ( $status == 1 && $opacrenew == 1 ) {
            AddRenewal(
                {
                    borrowernumber => $borrowernumber,
                    itemnumber     => $issue->itemnumber,
                    seen           => 0
                }
            );
            push( @renewed, $issue->itemnumber );
        }
        else {
            $errorstring .= $error . "|";
        }
    }
    $renewed = join( ':', @renewed );
}

print $query->redirect("/cgi-bin/koha/opac-user.pl?renew_error=$errorstring&renewed=$renewed");

