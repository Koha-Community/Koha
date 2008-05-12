#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 NAME

acceptorreject.pl

=head1 DESCRIPTION

this script modify the status of a subscription to ACCEPTED or to REJECTED

=head1 PARAMETERS

=over 4

=item title

=item author

=item note

=item copyrightdate

=item publishercode

=item volumedesc

=item publicationyear

=item place

=item isbn

=item status

=item suggestedbyme

=item op

op can be :
 * aorr_confirm : to confirm accept or reject
 * delete_confirm : to confirm the deletion
 * accepted : to display only accepted. 
 
=back


=cut

use strict;
require Exporter;
use CGI;

use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Suggestions;
use C4::Koha;    # GetAuthorisedValue
use C4::Dates qw(format_date);


my $input           = new CGI;
my $title           = $input->param('title');
my $author          = $input->param('author');
my $note            = $input->param('note');
my $copyrightdate   = $input->param('copyrightdate');
my $publishercode   = $input->param('publishercode');
my $volumedesc      = $input->param('volumedesc');
my $publicationyear = $input->param('publicationyear');
my $place           = $input->param('place');
my $isbn            = $input->param('isbn');
my $status          = $input->param('status');
my $suggestedbyme   = $input->param('suggestedbyme');
my $op              = $input->param('op') || "aorr_confirm";

my $dbh = C4::Context->dbh;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "suggestion/acceptorreject.tmpl",
        type            => "intranet",
        query           => $input,
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
    }
);

my $suggestions;

my $branchcode;
my $userenv = C4::Context->userenv;
if ($userenv) {
    unless ($userenv->{flags} == 1){
        $branchcode=$userenv->{branch};
    }
}

if ( $op eq "aorr_confirm" ) {
    my $parameters=$input->Vars;
    my @deletelist;
    my $suggestiontype=$parameters->{suggestiontype};
    foreach my $suggestionid (keys %$parameters){
        next unless $suggestionid=~/^\d+$/;
        ## it is a suggestion
        if ($parameters->{$suggestionid}=~/delete/i){
           push @deletelist,$suggestionid;    
        }
        else {        
        ## it is not a deletion    
            ## Get the Reason
            my $reason = $parameters->{"reason$suggestionid"};
            if ( $reason eq "other" ) {
                $reason = $parameters->{"other-reason$suggestionid"};
            }
            unless ($reason){
                $reason= $parameters->{"reason".$suggestiontype."all"};
            if ( $reason eq "other" ) {
                    $reason = $parameters->{"other-reason".$suggestiontype."all"};
            }
            }      
            ModStatus( $suggestionid, $parameters->{$suggestionid}, $loggedinuser, '', $reason );
        }
    }
    $op = "else";
    if (scalar(@deletelist)>0){  
        my $params = "&delete_field=".join ("&delete_field=",@deletelist);
        warn $params;    
        print $input->redirect("/cgi-bin/koha/suggestion/acceptorreject.pl?op=delete_confirm$params");
    }  
}

if ( $op eq "delete_confirm" ) {
    my @delete_field = $input->param("delete_field");
    foreach my $delete_field (@delete_field) {
        &DelSuggestion( $loggedinuser, $delete_field,"intranet" );
    }
    $op = 'else';
}

my $reasonsloop = GetAuthorisedValues("SUGGEST");
my $pending_suggestions = &SearchSuggestion( "", "", "", "", 'ASKED', "",$branchcode );
map{$_->{'reasonsloop'}=$reasonsloop;$_->{'date'}=format_date($_->{'date'})} @$pending_suggestions;
my $accepted_suggestions = &GetSuggestionByStatus('ACCEPTED',$branchcode);
map{$_->{'reasonsloop'}=$reasonsloop;$_->{'date'}=format_date($_->{'date'})} @$accepted_suggestions;
my $rejected_suggestions = &GetSuggestionByStatus('REJECTED',$branchcode);
map{$_->{'reasonsloop'}=$reasonsloop;$_->{'date'}=format_date($_->{'date'})} @$rejected_suggestions;

my @allsuggestions;
push @allsuggestions,{"suggestiontype"=>"accepted",
                    'suggestions_loop'=>$accepted_suggestions,    
                    'reasonsloop' => $reasonsloop};
push @allsuggestions,{"suggestiontype"=>"pending",
                     'suggestions_loop'=>$pending_suggestions,
                    'reasonsloop' => $reasonsloop};
push @allsuggestions,{"suggestiontype"=>"rejected",
                     'suggestions_loop'=>$rejected_suggestions,
                    'reasonsloop' => $reasonsloop};

$template->param(
    suggestions       => \@allsuggestions,
    "op_$op"                => 1,
    dateformat    => C4::Context->preference("dateformat"),
);

output_html_with_http_headers $input, $cookie, $template->output;
