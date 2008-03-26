#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template::Pro;
use POSIX;


my $dbh         = C4::Context->dbh;
my $query       = new CGI;
my $op          = $query->param('op');
#my $prof_code   = $query->param('prof_code');
my $prof_id     = $query->param('prof_id');
#my $printername = $query->param('printername');
#my $tmpl_id     = $query->param('tmpl_id');
#my $paper_bin   = $query->param('paper_bin');
#my $offset_horz = $query->param('offset_horz');
#my $offset_vert = $query->param('offset_vert');
#my $creep_horz  = $query->param('creep_horz');
#my $creep_vert  = $query->param('creep_vert');

# little block for displaying active layout/template/batch in templates
# ----------
my $batch_id                    = $query->param('batch_id');
my $active_layout               = get_active_layout();
my $active_template             = GetActiveLabelTemplate();
my $active_layout_name          = $active_layout->{'layoutname'};
my $active_template_name        = $active_template->{'tmpl_code'};
# ----------

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-profiles.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my @resultsloop;

if ( $op eq 'delete' ) {
    my $dberror = DeleteProfile($prof_id);
    warn "DB returned error: $dberror" if $dberror;
}

@resultsloop = GetAllPrinterProfiles();

$template->param(
    batch_id => $batch_id,
    active_layout_name => $active_layout_name,
    active_template_name => $active_template_name,

    resultsloop => \@resultsloop,
);

output_html_with_http_headers $query, $cookie, $template->output;
