#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use GD::Barcode::UPCE;

my $htdocs_path = C4::Context->config('intrahtdocs');
my $query       = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "barcodes/label-print.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $dbh    = C4::Context->dbh;
my $query2 = "SELECT * FROM labels_conf LIMIT 1";
my $sth    = $dbh->prepare($query2);
$sth->execute();
my $conf_data = $sth->fetchrow_hashref;

# get barcode type from $conf_data
my $barcodetype = $conf_data->{'barcodetype'};
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
                        SELECT * FROM biblio,biblioitems,items WHERE itemnumber=? AND
                                items.biblioitemnumber=biblioitems.biblioitemnumber AND
                                biblioitems.biblionumber=biblio.biblionumber";

    my $sth1 = $dbh->prepare($query1);
    $sth1->execute( $data->{'itemnumber'} );
    my $data1 = $sth1->fetchrow_hashref();
    push( @resultsloop, $data1 );
    $sth1->finish;

    $i1++;
}
$sth->finish;

#lets write barcode files to tmp dir for every item in @resultsloop

binmode(FILE);
foreach my $item (@resultsloop) {
    my $filename = "$htdocs_path/barcodes/$barcodetype-$item->{'barcode'}.png";
    open( FILE, ">$filename" );
    eval {
        print FILE GD::Barcode->new( $barcodetype, $item->{'barcode'} )
          ->plot->png;
    };
    if ($@) {
        $item->{'barcodeerror'} = 1;
    }
    close(FILE);
}

$template->param(
    resultsloop             => \@resultsloop,
    itemtype_opt            => $conf_data->{'itemtype'},
    papertype_opt           => $conf_data->{'papertype'},
    author_opt              => $conf_data->{'author'},
    id_opt                  => $conf_data->{'id'},
    barcodetype_opt         => $conf_data->{'barcodetype'},
    title_opt               => $conf_data->{'title'},
    isbn_opt                => $conf_data->{'isbn'},
    dewey_opt               => $conf_data->{'dewey'},
    class_opt               => $conf_data->{'class'},
    intranetcolorstylesheet =>
      C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);
output_html_with_http_headers $query, $cookie, $template->output;
