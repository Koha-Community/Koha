#!/usr/bin/perl

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

use strict;
#use warnings; FIXME - Bug 2505
require Exporter;
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Suggestions;
use C4::Koha; #GetItemTypes
use C4::Branch;
use C4::Budgets;
use C4::Search;
use C4::Dates qw(format_date);
use C4::Members;
use C4::Debug;

sub Init{
    my $suggestion= shift @_;
    foreach my $date qw(suggesteddate manageddate){
        $suggestion->{$date}=(($suggestion->{$date} eq "0000-00-00" ||$suggestion->{$date} eq "")?
                                $suggestion->{$date}=C4::Dates->today:
                                format_date($suggestion->{$date}) 
                              );
    }               
    foreach my $date qw(rejecteddate accepteddate){
    $suggestion->{$date}=(($suggestion->{$date} eq "0000-00-00" ||$suggestion->{$date} eq "")?
                                "":
                                format_date($suggestion->{$date}) 
                              );
	}
    $suggestion->{'managedby'}=C4::Context->userenv->{"number"} unless ($suggestion->{'managedby'});
    $suggestion->{'createdby'}=C4::Context->userenv->{"number"} unless ($suggestion->{'createdby'});
    $suggestion->{'branchcode'}=C4::Context->userenv->{"branch"} unless ($suggestion->{'branchcode'});
}

sub GetCriteriumDesc{
    my ($criteriumvalue,$displayby)=@_;
    return ($criteriumvalue eq 'ASKED'?"Pending":ucfirst(lc( $criteriumvalue))) if ($displayby =~/status/i);
    return (GetBranchName($criteriumvalue)) if ($displayby =~/branchcode/);
    return (GetSupportName($criteriumvalue)) if ($displayby =~/itemtype/);
    if ($displayby =~/managedby/||$displayby =~/acceptedby/){
        my $borr=C4::Members::GetMember(borrowernumber=>$criteriumvalue);
        return "" unless $borr;
        return $$borr{firstname} . ", " . $$borr{surname};
    }
    if ( $displayby =~ /budgetid/) {
        my $budget = GetBudget($criteriumvalue);
        return "" unless $budget;
        return $$budget{budget_name};
    }
}

my $input           = CGI->new;
my $suggestedbyme   = (defined $input->param('suggestedbyme')? $input->param('suggestedbyme'):1);
my $op              = $input->param('op')||'else';
my @editsuggestions = $input->param('edit_field');
my $branchfilter   = $input->param('branchcode');
my $suggestedby    = $input->param('suggestedby');
my $managedby    = $input->param('managedby');
my $displayby    = $input->param('displayby');
my $tabcode    = $input->param('tabcode');

# filter informations which are not suggestion related.
my $suggestion_ref  = $input->Vars;
delete $$suggestion_ref{$_} foreach qw( suggestedbyme op displayby tabcode edit_field );
foreach (keys %$suggestion_ref){
    delete $$suggestion_ref{$_} if (!$$suggestion_ref{$_} && ($op eq 'else' || $op eq 'change'));
}
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "suggestion/suggestion.tmpl",
            query           => $input,
            type            => "intranet",
            flagsrequired   => { catalogue => 1 },
        }
    );

#########################################
##  Operations
##
if ($op =~/save/i){
    if ($$suggestion_ref{'suggestionid'}>0){
    &ModSuggestion($suggestion_ref);
    }  
    else {
        ###FIXME:Search here if suggestion already exists.
        my $suggestions_loop =
            SearchSuggestion( $suggestion_ref );
        if (@$suggestions_loop>=1){
            #some suggestion are answering the request Donot Add	
        } 
        else {    
            ## Adding some informations related to suggestion
            &NewSuggestion($suggestion_ref);
        }
        # empty fields, to avoid filter in "SearchSuggestion"
    }  
    map{delete $$suggestion_ref{$_}} keys %$suggestion_ref;
    $op = 'else';
}
elsif ($op=~/add/) {
    #Adds suggestion  
    Init($suggestion_ref);
    $op ='save';
} 
elsif ($op=~/edit/) {
    #Edit suggestion  
    $suggestion_ref=&GetSuggestion($$suggestion_ref{'suggestionid'});
    Init($suggestion_ref);
    $op ='save';
}  
elsif ($op eq "change" ) {
	if ($$suggestion_ref{"STATUS"}){
		if (my $tmpstatus=lc($$suggestion_ref{"STATUS"}) =~/ACCEPTED|REJECTED/i){
			$$suggestion_ref{"$tmpstatus"."date"}=C4::Dates->today;
			$$suggestion_ref{"$tmpstatus"."by"}=C4::Context->userenv->{number};
		}
		$$suggestion_ref{"manageddate"}=C4::Dates->today;
		$$suggestion_ref{"managedby"}=C4::Context->userenv->{number};
	}
	if ( my $reason = $$suggestion_ref{"reason$tabcode"}){
		if ( $reason eq "other" ) {
				$reason = $$suggestion_ref{"other_reason$tabcode"};
		}
		$$suggestion_ref{'reason'}=$reason;
	}
	delete $$suggestion_ref{$_} foreach ("reason$tabcode", "other_reason$tabcode");
 	foreach (keys %$suggestion_ref){
		delete $$suggestion_ref{$_} unless ($$suggestion_ref{$_});
	}
    foreach my $suggestionid (@editsuggestions) {
        next unless $suggestionid;
        $$suggestion_ref{'suggestionid'}=$suggestionid;
        &ModSuggestion($suggestion_ref);
    }
    $op = 'else';
}elsif ($op eq "delete" ) {
    foreach my $delete_field (@editsuggestions) {
        &DelSuggestion( $borrowernumber, $delete_field,'intranet' );
    }
    $op = 'else';
}
if ($op=~/else/) {
    $op='else';
    
    $displayby||="STATUS";
    my $criteria_list=GetDistinctValues("suggestions.".$displayby);
    my @allsuggestions;
    my $reasonsloop = GetAuthorisedValues("SUGGEST");
    foreach my $criteriumvalue (map{$$_{'value'}} @$criteria_list){
        my $definedvalue = defined $$suggestion_ref{$displayby} && $$suggestion_ref{$displayby} ne "";
        
        next if ($definedvalue && $$suggestion_ref{$displayby} ne $criteriumvalue);
        $$suggestion_ref{$displayby}=$criteriumvalue;
#        warn $$suggestion_ref{$displayby}."=$criteriumvalue; $displayby";
    
        my $suggestions = &SearchSuggestion($suggestion_ref);
        foreach my $suggestion (@$suggestions){
            $suggestion->{budget_name}=GetBudget($suggestion->{budgetid})->{budget_name} if $suggestion->{budgetid};
            foreach my $date qw(suggesteddate manageddate accepteddate){
                if ($suggestion->{$date} ne "0000-00-00" && $suggestion->{$date} ne "" ){
                $suggestion->{$date}=format_date($suggestion->{$date}) ;
                } else {
                $suggestion->{$date}="" ;
                }             
            }    
        }
        push @allsuggestions,{
                            "suggestiontype"=>$criteriumvalue||"suggest",
                            "suggestiontypelabel"=>GetCriteriumDesc($criteriumvalue,$displayby)||"",
                            "suggestionscount"=>scalar(@$suggestions),             
                            'suggestions_loop'=>$suggestions,
                            'reasonsloop'     => $reasonsloop,
                            };

        delete $$suggestion_ref{$displayby} unless $definedvalue;
    }

    $template->param(
        "displayby"=> $displayby,
        "notabs"=> $displayby eq "",
        suggestions       => \@allsuggestions,
    );
}

foreach my $element qw(managedby suggestedby){
#    $debug || warn $$suggestion_ref{$element};
    if ($$suggestion_ref{$element}){
        my $member=GetMember(borrowernumber=>$$suggestion_ref{$element});
        $template->param(
            $element."_borrowernumber"=>$$member{borrowernumber},
            $element."_firstname"=>$$member{firstname},
            $element."_surname"=>$$member{surname},
            $element."_branchcode"=>$$member{branchcode},
            $element."_description"=>$$member{description},
            $element."_category_type"=>$$member{category_type}
        );
    }
}
$template->param(
    %$suggestion_ref,  
    "op_$op"                => 1,
    dateformat    => C4::Context->preference("dateformat"),
    "op"             =>$op,
);


####################
## Initializing selection lists

#branch display management
my $onlymine=C4::Context->preference('IndependantBranches') && 
            C4::Context->userenv && 
            C4::Context->userenv->{flags}!=1 && 
            C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my @branchloop;

foreach my $thisbranch ( sort {$branches->{$a}->{'branchname'} cmp $branches->{$b}->{'branchname'}} keys %$branches ) {
    my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
        selected   => ($branches->{$thisbranch}->{'branchcode'} eq $branchfilter)
                    ||($branches->{$thisbranch}->{'branchcode'} eq $$suggestion_ref{'branchcode'})    
    );
    push @branchloop, \%row;
}
$branchfilter=C4::Context->userenv->{'branch'} if ($onlymine && !$branchfilter);

$template->param( branchloop => \@branchloop,
                branchfilter => $branchfilter);

# the index parameter is different for item-level itemtypes
my $supportlist=GetSupportList();				
foreach my $support(@$supportlist){
    $$support{'selected'}= $$support{'code'} eq $$suggestion_ref{'itemtype'};
    if ($$support{'imageurl'}){
        $$support{'imageurl'}= getitemtypeimagelocation( 'intranet', $$support{'imageurl'} );
    }
    else {
    delete $$support{'imageurl'}
    }
}
$template->param(itemtypeloop=>$supportlist);

#Budgets management
my $searchbudgets={ budget_branchcode=>$branchfilter} if $branchfilter;
my $budgets = GetBudgets($searchbudgets);

foreach my $budget (@$budgets){
    $budget->{'selected'}=1 if ($$suggestion_ref{'budgetid'} && $budget->{'budget_id'} eq $$suggestion_ref{'budgetid'})
};

$template->param( budgetsloop => $budgets);

my %hashlists;
foreach my $field qw(managedby acceptedby suggestedby budgetid STATUS) {
    my $values_list;
    $values_list=GetDistinctValues("suggestions.".$field) ;
    my @codes_list = map{
                        { 'code'=>$$_{'value'},
                        'desc'=>GetCriteriumDesc($$_{'value'},$field),
                        'selected'=> $$_{'value'} eq $$suggestion_ref{$field}
                        }
                    } @$values_list;
    $hashlists{lc($field)."_loop"}=\@codes_list;
}
$template->param(%hashlists);
$template->param(DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),);
output_html_with_http_headers $input, $cookie, $template->output;
