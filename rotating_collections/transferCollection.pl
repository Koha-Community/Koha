#!/usr/bin/perl
use strict;
#use warnings; FIXME - Bug 2505
require Exporter;

use C4::Output;
use C4::Auth;
use C4::Context;
use C4::RotatingCollections;
use C4::Branch;

use CGI;

my $query = new CGI;

my $colId = $query->param('colId');
my $toBranch = $query->param('toBranch');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "rotating_collections/transferCollection.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

## Transfer collection
my ( $success, $errorCode, $errorMessage );
if ( $toBranch ) {
  ( $success, $errorCode, $errorMessage ) = TransferCollection( $colId, $toBranch );

  if ( $success ) {
    $template->param( transferSuccess => 1 );
  } else {
    $template->param( transferFailure => 1,
                      errorCode => $errorCode,
                      errorMessage => $errorMessage
    );
  }
}

## Set up the toBranch select options
my $branches = GetBranches();
my @branchoptionloop;
foreach my $br (keys %$branches) {
  my %branch;
  $branch{code}=$br;
  $branch{name}=$branches->{$br}->{'branchname'};
  push (@branchoptionloop, \%branch);
}
    
## Get data about collection
my ( $colId, $colTitle, $colDesc, $colBranchcode ) = GetCollection( $colId );                                
$template->param(
                intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
                intranetstylesheet => C4::Context->preference("intranetstylesheet"),
                IntranetNav => C4::Context->preference("IntranetNav"),
                                  
                colId => $colId,
                colTitle => $colTitle,
                colDesc => $colDesc,
                colBranchcode => $colBranchcode,
                branchoptionloop => \@branchoptionloop
                );
                                                                                                
output_html_with_http_headers $query, $cookie, $template->output;
