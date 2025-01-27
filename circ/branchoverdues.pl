#!/usr/bin/perl

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
use C4::Context;
use CGI          qw ( -utf8 );
use C4::Output   qw( output_html_with_http_headers );
use C4::Auth     qw( get_template_and_user );
use C4::Overdues qw( GetOverduesForBranch );
use C4::Biblio   qw( GetMarcFromKohaField GetMarcStructure );
use C4::Koha     qw( GetAuthorisedValues );
use Koha::BiblioFrameworks;

=head1 branchoverdues.pl

This view is used to display all overdue items to the librarian.

It is automatically filtered by branch and can optionally be filtered
by item location.

=cut

my $input = CGI->new;
my $dbh   = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "circ/branchoverdues.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "overdues_report" },
    }
);

my $default = C4::Context->userenv->{'branch'};

# Deal with the vars recept from the template
my $borrowernumber = $input->param('borrowernumber');
my $itemnumber     = $input->param('itemnumber');
my $method         = $input->param('method');
my $overduelevel   = $input->param('overduelevel');
my $location       = $input->param('location');

# FIXME: better check that borrowernumber is defined and valid.
# FIXME: same for itemnumber and other variables passed in here.

my @overduesloop;
my @getoverdues = GetOverduesForBranch( $default, $location );

# search for location authorised value
my ( $tag, $subfield ) = GetMarcFromKohaField('items.location');
my $tagslib = &GetMarcStructure( 1, '' );
if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
    my $values = GetAuthorisedValues( $tagslib->{$tag}->{$subfield}->{authorised_value} );
    for (@$values) { $_->{selected} = 1 if defined $location && $location eq $_->{authorised_value} }
    $template->param( locationsloop => $values );
}

# now display infos
foreach my $num (@getoverdues) {
    my %overdueforbranch;
    $overdueforbranch{'date_due'}          = $num->{date_due};
    $overdueforbranch{'title'}             = $num->{'title'};
    $overdueforbranch{'subtitle'}          = $num->{'subtitle'};
    $overdueforbranch{'medium'}            = $num->{'medium'};
    $overdueforbranch{'part_number'}       = $num->{'part_number'};
    $overdueforbranch{'part_name'}         = $num->{'part_name'};
    $overdueforbranch{'description'}       = $num->{'description'};
    $overdueforbranch{'barcode'}           = $num->{'barcode'};
    $overdueforbranch{'biblionumber'}      = $num->{'biblionumber'};
    $overdueforbranch{'author'}            = $num->{'author'};
    $overdueforbranch{'borrowersurname'}   = $num->{'surname'};
    $overdueforbranch{'borrowerfirstname'} = $num->{'firstname'};
    $overdueforbranch{'borrowerphone'}     = $num->{'phone'};
    $overdueforbranch{'borroweremail'}     = $num->{'email'};
    $overdueforbranch{'homebranch'}        = $num->{'homebranch'};
    $overdueforbranch{'itemcallnumber'}    = $num->{'itemcallnumber'};
    $overdueforbranch{'borrowernumber'}    = $num->{'borrowernumber'};
    $overdueforbranch{'itemnumber'}        = $num->{'itemnumber'};
    $overdueforbranch{'cardnumber'}        = $num->{'cardnumber'};

    push( @overduesloop, \%overdueforbranch );
}

# initiate the templates for the overdueloop
$template->param(
    overduesloop => \@overduesloop,
    location     => $location,
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find('FA');

output_html_with_http_headers $input, $cookie, $template->output;
