#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use HTML::Template;
use POSIX;

my $dbh         = C4::Context->dbh;
my $query       = new CGI;
my $op          = $query->param('op');
my $barcodetype = $query->param('barcodetype');
my $title       = $query->param('title');
my $isbn        = $query->param('isbn');
my $itemtype    = $query->param('itemtype');
my $bcn         = $query->param('bcn');
my $dcn         = $query->param('dcn');
my $classif     = $query->param('classif');
my $author      = $query->param('author');
my $papertype   = $query->param('papertype');
my $itemnumber  = $query->param('itemnumber');
my $summary     = $query->param('summary');
my $startrow    = $query->param('startrow');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "barcodes/label-manager.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

if ( $op eq 'save_conf' ) {
    my $query2 = "DELETE FROM labels_conf";
    my $sth2   = $dbh->prepare($query2);
    $sth2->execute();
    $sth2->finish;
    my $query2 = "INSERT INTO labels_conf 
			( barcodetype, title, isbn, itemtype, barcode, 	
			  dewey, class, author, papertype, startrow)
			   values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";
    my $sth2 = $dbh->prepare($query2);
    $sth2->execute(
        $barcodetype, $title,   $isbn,   $itemtype,  $bcn,
        $dcn,         $classif, $author, $papertype, $startrow
    );
    $sth2->finish;

}
elsif ( $op eq 'add' ) {
    my $query2 = "INSERT INTO labels ( itemnumber ) values ( ? )";
    my $sth2   = $dbh->prepare($query2);
    $sth2->execute($itemnumber);
    $sth2->finish;
}
elsif ( $op eq 'deleteall' ) {
    my $query2 = "DELETE FROM labels";
    my $sth2   = $dbh->prepare($query2);
    $sth2->execute();
    $sth2->finish;
}
elsif ( $op eq 'delete' ) {
    my $query2 = "DELETE FROM labels where itemnumber = ?";
    my $sth2   = $dbh->prepare($query2);
    $sth2->execute($itemnumber);
    $sth2->finish;
}

#  first lets do a read of the labels table , to get the a list of the
# currently entered items to be prinited

my @resultsloop = ();
my $count;
my @data;
my $query3 = "Select * from labels";
my $sth    = $dbh->prepare($query3);
$sth->execute();

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

    $data1->{'labelno'} = $i1;
    $data1->{'summary'} =
      "$data1->{'barcode'}, $data1->{'title'}, $data1->{'isbn'}";

    push( @resultsloop, $data1 );
    $sth1->finish;

    $i1++;
}
$sth->finish;

# this script can be run from the side nav, and is not passed a value for $startrow
# so lets get it from the DB
if ( !$startrow ) {

    my $dbh    = C4::Context->dbh;
    my $query2 = "SELECT * FROM labels_conf LIMIT 1";
    my $sth    = $dbh->prepare($query2);
    $sth->execute();

    my $data = $sth->fetchrow_hashref;
    $startrow = $data->{'startrow'};
    $sth->finish;
}

#calc-ing number of sheets
my $number_of_results = scalar @resultsloop;
my $sheets_needed = ( ( --$number_of_results + $startrow ) / 8 );
        $sheets_needed = ceil($sheets_needed);    # rounding up int's

my $tot_labels = ($sheets_needed * 8);
my $start_results =  ($number_of_results + $startrow);
my $labels_remaining = ($tot_labels - $start_results);

$template->param(
    resultsloop             => \@resultsloop,
    startrow                => $startrow,
    sheets                  => $sheets_needed,
    labels_remaining        => $labels_remaining,

    intranetcolorstylesheet =>
      C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);
output_html_with_http_headers $query, $cookie, $template->output;
