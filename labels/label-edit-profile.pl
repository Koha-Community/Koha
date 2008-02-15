#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template::Pro;
use POSIX;

my $DEBUG = 0;
my $dbh       = C4::Context->dbh;
my $query     = new CGI;

my $op          = $query->param('op');
my $prof_id     = $query->param('prof_id');
my $offset_horz = $query->param('offset_horz');
my $offset_vert = $query->param('offset_vert');
my $creep_horz  = $query->param('creep_horz');
my $creep_vert  = $query->param('creep_vert');
my $units       = $query->param('unit');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-profile.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

if ($op eq '' || undef) {
    my $prof = GetSinglePrinterProfile($prof_id);

    my $tmpl = GetSingleLabelTemplate($prof->{'tmpl_id'});

    if ( $DEBUG ) {
        use Data::Dumper;
        warn Dumper($prof);
        warn Dumper($tmpl);
    }       

    my @units = (
        { unit => 'INCH',  desc => 'Inches' },
        { unit => 'CM',    desc => 'Centimeters' },
        { unit => 'MM',    desc => 'Millimeters' },
        { unit => 'POINT', desc => 'Postscript Points' },
    );

    foreach my $unit (@units) {
        if ( $unit->{'unit'} eq $prof->{'unit'} ) {
            $unit->{'selected'} = 1;
        }
    }

    $template->param(

        units => \@units,

        prof_id      => $prof->{'prof_id'},
        printername  => $prof->{'printername'},
        paper_bin    => $prof->{'paper_bin'},
        tmpl_code    => $tmpl->{'tmpl_code'},
        prof_code    => $prof->{'prof_code'},
        offset_horz  => $prof->{'offset_horz'},
        offset_vert  => $prof->{'offset_vert'},
        creep_horz   => $prof->{'creep_horz'},
        creep_vert   => $prof->{'creep_vert'},
    );
}

elsif ($op eq 'Save') {
    warn "Units are now $units";

    SaveProfile( $prof_id,   $offset_horz,   $offset_vert,   $creep_horz,    $creep_vert,    $units );
    print $query->redirect("./label-profiles.pl");
    exit;
}

elsif ($op eq 'Cancel') {
    print $query->redirect("./label-profiles.pl");
    exit;
}

output_html_with_http_headers $query, $cookie, $template->output;
