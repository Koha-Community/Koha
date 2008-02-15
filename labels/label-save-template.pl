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

my $tmpl_id      = $query->param('tmpl_id');
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
my $fontsize     = $query->param('fontsize');
my $units        = $query->param('units');
my $active       = $query->param('active');
my $prof_id      = $query->param('prof_id');

SaveTemplate(

    $tmpl_id,     $tmpl_code,   $tmpl_desc,    $page_width,
    $page_height, $label_width, $label_height, $topmargin,
    $leftmargin,  $cols,        $rows,         $colgap,
    $rowgap,      $fontsize,     $units

);

SetAssociatedProfile( $prof_id, $tmpl_id );

print $query->redirect("./label-templates.pl");


