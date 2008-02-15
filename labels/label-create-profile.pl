#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template::Pro;
use POSIX;

use Data::Dumper;
#use Smart::Comments;

my $dbh   = C4::Context->dbh;
my $query = new CGI;
### $query

my $op          = $query->param('op');

my $prof_id     = $query->param('prof_id');
my $printername = $query->param('printername');
my $paper_bin   = $query->param('paper_bin');
my $tmpl_id     = $query->param('tmpl_id');
my $offset_horz = $query->param('offset_horz');
my $offset_vert = $query->param('offset_vert');
my $creep_horz  = $query->param('creep_horz');
my $creep_vert  = $query->param('creep_vert');
my $units       = $query->param('unit');

my @resultsloop;
my @tmpllist;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "labels/label-create-profile.tmpl",
            query           => $query,
            type            => "intranet",
            authnotrequired => 1,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

if ( $op eq 'blank' || $op eq '' ) {

    my @units = (
        { unit => 'INCH',  desc => 'Inches' },
        { unit => 'CM',    desc => 'Centimeters' },
        { unit => 'MM',    desc => 'Millimeters' },
        { unit => 'POINT', desc => 'Postscript Points' },
    );

    my @tmpl = GetAllLabelTemplates();

    foreach my $data (@tmpl) {
        push ( @tmpllist, {tmpl_id      => $data->{'tmpl_id'},
                           tmpl_code    => $data->{'tmpl_code'}} );
    }

    $template->param(
        tmpllist        => \@tmpllist,
        unit            => \@units,
    );

}

elsif ( $op eq 'Save' ) {
    my $errmsg;
    my $dberror = CreateProfile(
        $prof_id,       $printername,   $paper_bin,     $tmpl_id,     $offset_horz,
        $offset_vert,   $creep_horz,    $creep_vert,    $units
    );
    unless ( $dberror ) {
        print $query->redirect("./label-profiles.pl");
        exit;
    }
    
    # FIXME: This exposes all CGI vars. Surely there is a better way to do it? -fbcit
    if ( $dberror =~ /Duplicate/ && $dberror =~ /$paper_bin/ ) {
        $errmsg = "You cannot create duplicate profiles for $printername/$paper_bin.
                    Click the Back button on your browser and enter a different paper bin
                    for $printername.";
    }

    else {
        $errmsg = $dberror;
    }

    $template->param (
        dberror         => $dberror,
        errmsg          => $errmsg,
    );

    warn "DB error: $dberror";
}

elsif ( $op eq 'Cancel' ) {
    print $query->redirect("./label-profiles.pl");
    exit;
}

output_html_with_http_headers $query, $cookie, $template->output;
