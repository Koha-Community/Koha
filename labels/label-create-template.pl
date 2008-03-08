#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template::Pro;
use POSIX;

#use Data::Dumper;
#use Smart::Comments;

my $dbh   = C4::Context->dbh;
my $query = new CGI;
### $query

my $tmpl_code    = $query->param('tmpl_code');
my $tmpl_desc    = $query->param('tmpl_desc');
my $page_height  = $query->param('page_height');
my $page_width   = $query->param('page_width');
my $label_height = $query->param('label_height');
my $label_width  = $query->param('label_width');
my $topmargin    = $query->param('topmargin');
my $leftmargin   = $query->param('leftmargin');
my $cols         = $query->param('cols');
my $rows         = $query->param('rows');
my $colgap       = $query->param('colgap');
my $rowgap       = $query->param('rowgap');
my $units        = $query->param('units');
my $font         = $query->param('fonts');
my $fontsize     = $query->param('fontsize');

my $batch_id     = $query->param('batch_id');


my $op = $query->param('op');
my @resultsloop;

my ( $template, $loggedinuser, $cookie );

if ( $op eq 'blank' ) {

    my @units = (
        { unit => 'INCH',  desc => 'Inches' },
        { unit => 'CM',    desc => 'Centimeters' },
        { unit => 'MM',    desc => 'Millimeters' },
        { unit => 'POINT', desc => 'Postscript Points' },
    );

    my @fonts = (        #FIXME: There is probably a way to discover what additional fonts are installed on a user's system and generate this list dynamically...
        { font => 'TR',     name => 'Times Roman' },
        { font => 'TB',     name => 'Times Bold' },
        { font => 'TI',     name => 'Times Italic' },
        { font => 'TBI',    name => 'Times Bold Italic' },
        { font => 'C',      name => 'Courier' },
        { font => 'CB',     name => 'Courier Bold' },
        { font => 'CO',     name => 'Courier Oblique' },
        { font => 'CBO',    name => 'Courier Bold Oblique' },
        { font => 'H',      name => 'Helvetica' },
        { font => 'HB',     name => 'Helvetica Bold' },
        { font => 'HO',     name => 'Helvetica Oblique' },
        { font => 'HBO',    name => 'Helvetica Bold Oblique' },
    );

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "labels/label-create-template.tmpl",
            query           => $query,
            type            => "intranet",
            authnotrequired => 1,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    $template->param(
        units   => \@units,
        fonts   => \@fonts,
    );

}

elsif ( $op eq 'Create' ) {
    CreateTemplate(

        $tmpl_code,   $tmpl_desc,   $page_width,
        $page_height, $label_width, $label_height, $topmargin,
        $leftmargin,  $cols,        $rows,         $colgap,
        $rowgap,      $font,        $fontsize,     $units );

 print $query->redirect("./label-templates.pl");
exit;

}

elsif ( $op eq 'Cancel' ) {
    print $query->redirect("./label-home.pl");
    exit;
}

output_html_with_http_headers $query, $cookie, $template->output;
