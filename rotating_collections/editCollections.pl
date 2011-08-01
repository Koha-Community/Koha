#!/usr/bin/perl

use strict;
#use warnings; FIXME - Bug 2505
require Exporter;

use CGI;

use C4::Output;
use C4::Auth;
use C4::Context;

use C4::RotatingCollections;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "rotating_collections/editCollections.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

# Create new Collection
if ( $query->param('action') eq 'create' ) {
  my $title = $query->param('title');
  my $description = $query->param('description');
                            
  my ( $createdSuccessfully, $errorCode, $errorMessage ) = CreateCollection( $title, $description );
                              
  $template->param(
    previousActionCreate => 1,
    createdTitle => $title,
  );
                                          
  if ( $createdSuccessfully ) {
    $template->param( createSuccess => 1 );
  } else {
    $template->param( createFailure => 1 );
    $template->param( failureMessage => $errorMessage );
  }                                                        
}

## Delete a club or service
elsif ( $query->param('action') eq 'delete' ) {
  my $colId = $query->param('colId');
  my ( $success, $errorCode, $errorMessage ) = DeleteCollection( $colId );
    
  $template->param( previousActionDelete => 1 );
  if ( $success ) {
    $template->param( deleteSuccess => 1 );
  } else {
    $template->param( deleteFailure => 1 );
    $template->param( failureMessage => $errorMessage );
  }
}

## Edit a club or service: grab data, put in form.
elsif ( $query->param('action') eq 'edit' ) {
  my $colId = $query->param('colId');
  my ( $colId, $colTitle, $colDesc, $colBranchcode ) = GetCollection( $colId );

  $template->param(
      previousActionEdit => 1,
      editColId => $colId,
      editColTitle => $colTitle,
      editColDescription => $colDesc,
  );
}

# Update a Club or Service
elsif ( $query->param('action') eq 'update' ) {
  my $colId = $query->param('colId');
  my $title = $query->param('title');
  my $description = $query->param('description');
                            
  my ( $createdSuccessfully, $errorCode, $errorMessage ) 
    = UpdateCollection( $colId, $title, $description );
                              
  $template->param(
    previousActionUpdate => 1,
    updatedTitle => $title,
  );
                                          
  if ( $createdSuccessfully ) {
    $template->param( updateSuccess => 1 );
  } else {
    $template->param( updateFailure => 1 );
    $template->param( failureMessage => $errorMessage );
  }                                                        
}
                                                        
my $collections = GetCollections();

$template->param(
		intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
		
		collectionsLoop => $collections,
		);

output_html_with_http_headers $query, $cookie, $template->output;
