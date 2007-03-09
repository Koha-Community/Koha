#!/usr/bin/perl

# This file is part of koha
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

use strict;
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;

use GD::Barcode::UPCE;
use Data::Random qw(:all);

my $htdocs_path = C4::Context->config('intrahtdocs');

my $query = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "barcodes/label-print.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 1 },
        debug           => 1,
    }
);

my $dbh    = C4::Context->dbh;
my $query2 = "SELECT * FROM labels_conf LIMIT 1";
my $sth    = $dbh->prepare($query2);
$sth->execute();

my $conf_data = $sth->fetchrow_hashref;

$sth->finish;

my @data;
my $query3 = "Select * from labels";
my $sth    = $dbh->prepare($query3);
$sth->execute();
my @resultsloop;
my $cnt = $sth->rows;
my $i1  = 1;
while ( my $data = $sth->fetchrow_hashref ) {

    # lets get some summary info from each item

    my $query1 = "
                        select * from biblio,biblioitems,items where itemnumber=? and
                                items.biblioitemnumber=biblioitems.biblioitemnumber and
                                biblioitems.biblionumber=biblio.biblionumber";

    my $sth1 = $dbh->prepare($query1);
    $sth1->execute( $data->{'itemnumber'} );
    my $data1 = $sth1->fetchrow_hashref();

    push( @resultsloop, $data1 );
    $sth1->finish;

    $i1++;
}
$sth->finish;

#------------------------------------------------------

#lets write barcode files to tmp dir for every item in @resultsloop

binmode(FILE);
foreach my $item (@resultsloop) {

    my $random = int( rand(100000000000) ) + 999999999999;

    #warn  "$random\n";

    $item->{'barcode'} = $random;

    #	my $itembarcode = $item->{'barcode'};
    #	warn $item->{'barcode'};

    my $filename = "$htdocs_path/barcodes/$item->{'barcode'}.png";

    #warn $filename;
    open( FILE, ">$filename" );

    print FILE GD::Barcode->new( 'EAN13', $item->{'barcode'} )->plot->png;

    #	warn $GD::Barcode::errStr;

    close(FILE);

    #warn Dumper  $item->{'barcode'};

}

# lets pass the config setting

$template->param(

    resultsloop => \@resultsloop,

    itemtype_opt       => $conf_data->{'itemtype'},
    papertype_opt      => $conf_data->{'papertype'},
    author_opt         => $conf_data->{'author'},
    barcode_opt        => $conf_data->{'barcode'},
    id_opt             => $conf_data->{'id'},
    type_opt           => $conf_data->{'type'},
    title_opt          => $conf_data->{'title'},
    isbn_opt           => $conf_data->{'isbn'},
    dewey_opt          => $conf_data->{'dewey'},
    class_opt          => $conf_data->{'class'},
    subclass_opt       => $conf_data->{'subclass'},
    itemcallnumber_opt => $conf_data->{'itemcallnumber'},

    intranetcolorstylesheet =>
      C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);
output_html_with_http_headers $query, $cookie, $template->output;

