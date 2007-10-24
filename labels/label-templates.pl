#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template;
use POSIX;

#use Data::Dumper;

my $dbh       = C4::Context->dbh;
my $query     = new CGI;
my $op        = $query->param('op');
my $tmpl_code = $query->param('tmpl_code');
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
        template_name   => "labels/label-templates.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);


my @resultsloop;


if ( $op eq 'set_active_template' ) {
    SetActiveTemplate($tmpl_id);
}

elsif ( $op eq 'delete' ) {
    DeleteTemplate($tmpl_id);
}

elsif ( $op eq 'save' ) {
    SaveTemplate($tmpl_code);
}

    @resultsloop = GetAllLabelTemplates();

# little block for displaying active layout/template/batch in templates
# ----------
my $batch_id     = $query->param('batch_id');
my $active_layout = get_active_layout();
my $active_template = GetActiveLabelTemplate();
my $active_layout_name = $active_layout->{'layoutname'};
my $active_template_name = $active_template->{'tmpl_code'};
# ----------

$template->param(

    batch_id => $batch_id,
    active_layout_name => $active_layout_name,
    active_template_name => $active_template_name,

    resultsloop => \@resultsloop,
);

output_html_with_http_headers $query, $cookie, $template->output;
