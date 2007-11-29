#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template::Pro;
use POSIX;

# use Data::Dumper;

my $dbh       = C4::Context->dbh;
my $query     = new CGI;

my $tmpl_id = $query->param('tmpl_id');

my $width      = $query->param('width');
my $height     = $query->param('height');
my $topmargin  = $query->param('topmargin');
my $leftmargin = $query->param('leftmargin');
my $columns    = $query->param('columns');
my $rows       = $query->param('rows');
my $colgap     = $query->param('colgap');
my $rowgap     = $query->param('rowgap');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-template.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $tmpl = GetSingleLabelTemplate($tmpl_id);

my @units = (
    { unit => 'INCH',  desc => 'Inches' },
    { unit => 'CM',    desc => 'Centimeters' },
    { unit => 'MM',    desc => 'Millimeters' },
    { unit => 'POINT', desc => 'Postscript Points' },
);

foreach my $unit (@units) {
    if ( $unit->{'unit'} eq $tmpl->{'units'} ) {
        $unit->{'selected'} = 1;
    }
}

$template->param(

    units => \@units,

    tmpl_id      => $tmpl->{'tmpl_id'},
    tmpl_code    => $tmpl->{'tmpl_code'},
    tmpl_desc    => $tmpl->{'tmpl_desc'},
    page_width   => $tmpl->{'page_width'},
    page_height  => $tmpl->{'page_height'},
    label_width  => $tmpl->{'label_width'},
    label_height => $tmpl->{'label_height'},
    topmargin    => $tmpl->{'topmargin'},
    leftmargin   => $tmpl->{'leftmargin'},
    cols         => $tmpl->{'cols'},
    rows         => $tmpl->{'rows'},
    colgap       => $tmpl->{'colgap'},
    rowgap       => $tmpl->{'rowgap'},
    fontsize     => $tmpl->{'fontsize'},
    active       => $tmpl->{'active'},
);

output_html_with_http_headers $query, $cookie, $template->output;
