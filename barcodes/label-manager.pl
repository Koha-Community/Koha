#!/usr/bin/perl

# This file is part of Koha.
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
use C4::Labels;
use C4::Output;

use POSIX;

my $dbh            = C4::Context->dbh;
my $query          = new CGI;
my $op             = $query->param('op');
my $barcodetype    = $query->param('barcodetype');
my $title          = $query->param('title');
my $isbn           = $query->param('isbn');
my $itemtype       = $query->param('itemtype');
my $bcn            = $query->param('bcn');
my $dcn            = $query->param('dcn');
my $classif        = $query->param('classif');
my $itemcallnumber = $query->param('itemcallnumber');
my $subclass       = $query->param('subclass');
my $author         = $query->param('author');
my $tmpl_id        = $query->param('tmpl_id');
my $itemnumber     = $query->param('itemnumber');
my $summary        = $query->param('summary');
my $startlabel     = $query->param('startlabel');
my $printingtype   = $query->param('printingtype');
my $guidebox       = $query->param('guidebox');
my $fontsize       = $query->param('fontsize');

#warn "ID =$tmpl_id";

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "barcodes/label-manager.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { tools => 1 },
        debug           => 1,
    }
);

if ( $op eq 'save_conf' ) {
    SaveConf(
        $barcodetype,    $title,  $isbn,    $itemtype,
        $bcn,            $dcn,    $classif, $subclass,
        $itemcallnumber, $author, $tmpl_id, $printingtype,
        $guidebox,       $startlabel
    );

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
    warn "MASON, deleting label..";
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

my $dbh    = C4::Context->dbh;
my $query2 = "SELECT * FROM labels_conf LIMIT 1";
my $sth    = $dbh->prepare($query2);
$sth->execute();

my $data = $sth->fetchrow_hashref;
$sth->finish;

#calc-ing number of sheets

#$sheets_needed = ceil($sheets_needed);    # rounding up int's

#my $tot_labels       = ( $sheets_needed * 8 );
#my $start_results    = ( $number_of_results + $startrow );
#my $labels_remaining = ( $tot_labels - $start_results );

$template->param(
    resultsloop => \@resultsloop,

    #  startrow         => $startrow,
    #  sheets           => $sheets_needed,
    #  labels_remaining => $labels_remaining,
    intranetcolorstylesheet =>
      C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);
output_html_with_http_headers $query, $cookie, $template->output;
