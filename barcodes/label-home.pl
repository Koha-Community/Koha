#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

#use Data::Dumper;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "barcodes/label-home.tmpl",
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

my $data = $sth->fetchrow_hashref;
$sth->finish;

$template->param( guidebox => 1 ) if ( $data->{'guidebox'} );

$data->{'printingtype'} = 'both' if ( !$data->{'printingtype'} );
$template->param( "printingtype_$data->{'printingtype'}" => 1 );

$template->param( "$data->{'barcodetype'}_checked"              => 1 );
$template->param( "startrow" . $data->{'startrow'} . "_checked" => 1 );
$template->param(
    itemtype    => $data->{'itemtype'},
    papertype   => $data->{'papertype'},
    author      => $data->{'author'},
    barcode     => $data->{'barcode'},
    id          => $data->{'id'},
    barcodetype => $data->{'barcodetype'},
    title       => $data->{'title'},
    isbn        => $data->{'isbn'},
    dewey       => $data->{'dewey'},
    class       => $data->{'class'},
    startrow    => $data->{'startrow'},

    intranetcolorstylesheet =>
      C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);

output_html_with_http_headers $query, $cookie, $template->output;
