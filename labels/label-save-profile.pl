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

my $prof_id     = $query->param('prof_id');
my $offset_horz = $query->param('offset_horz');
my $offset_vert = $query->param('offset_vert');
my $creep_horz  = $query->param('creep_horz');
my $creep_vert  = $query->param('creep_vert');
my $units       = $query->param('unit');

SaveProfile(
    $prof_id,   $offset_horz,   $offset_vert,   $creep_horz,    $creep_vert,    $units
);


 print $query->redirect("./label-profiles.pl");


