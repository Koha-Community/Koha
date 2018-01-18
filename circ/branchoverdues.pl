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
use CGI qw ( -utf8 );
use C4::Output;
use C4::Auth;
use C4::Overdues;
use C4::Biblio;
use C4::Koha;
use C4::Debug;
use Koha::DateUtils;
use Koha::BiblioFrameworks;
use Data::Dumper;

=head1 branchoverdues.pl

 this module is a new interface, allow to the librarian to check all items on overdues (based on the acountlines type 'FU' )
 this interface is filtered by branches (automatically), and by location (optional) ....

=cut

my $input       = new CGI;
my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user({
        template_name   => "circ/branchoverdues.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
});

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
$debug and warn "HERE : $default / $location" . Dumper(@getoverdues);
# search for location authorised value
my ($tag,$subfield) = GetMarcFromKohaField('items.location','');
my $tagslib = &GetMarcStructure(1,'');
if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
    my $values= GetAuthorisedValues($tagslib->{$tag}->{$subfield}->{authorised_value});
    for (@$values) { $_->{selected} = 1 if $location eq $_->{authorised_value} }
    $template->param(locationsloop => $values);
}
# now display infos
foreach my $num (@getoverdues) {
    my %overdueforbranch;
    my $record = GetMarcBiblio({ biblionumber => $num->{biblionumber} });
    if ($record){
        $overdueforbranch{'subtitle'} = GetRecordValue('subtitle',$record,'')->[0]->{subfield};
    }
    my $dt = dt_from_string($num->{date_due}, 'sql');
    $overdueforbranch{'date_due'}          = output_pref($dt);
    $overdueforbranch{'title'}             = $num->{'title'};
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
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

output_html_with_http_headers $input, $cookie, $template->output;
