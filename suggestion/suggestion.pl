#!/usr/bin/perl

# This file is part of Koha.
# Copyright 2006-2010 BibLibre

#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

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
use C4::Members;
use C4::Debug;

use Koha::DateUtils qw( dt_from_string );

use URI::Escape;

sub Init{
    my $suggestion= shift @_;
    # "Managed by" is used only when a suggestion is being edited (not when created)
    if ($suggestion->{'suggesteddate'} eq "0000-00-00" ||$suggestion->{'suggesteddate'} eq "") {
        # new suggestion
        $suggestion->{suggesteddate} = dt_from_string;
        $suggestion->{'suggestedby'} = C4::Context->userenv->{"number"} unless ($suggestion->{'suggestedby'});
    }
    else {
        # editing of an existing suggestion
        $suggestion->{manageddate} = dt_from_string;
        $suggestion->{'managedby'} = C4::Context->userenv->{"number"} unless ($suggestion->{'managedby'});
    }
    $suggestion->{'branchcode'}=C4::Context->userenv->{"branch"} unless ($suggestion->{'branchcode'});
}

sub GetCriteriumDesc{
    my ($criteriumvalue,$displayby)=@_;
    if ($displayby =~ /status/i) {
        if ( grep { /^($criteriumvalue)$/ } qw(ASKED ACCEPTED REJECTED CHECKED ORDERED AVAILABLE) ) {
            return ($criteriumvalue eq 'ASKED'?"Pending":ucfirst(lc( $criteriumvalue)));
        } else {
            return GetAuthorisedValueByCode('SUGGEST_STATUS', $criteriumvalue) || $criteriumvalue;
        }
    }
    return (GetBranchName($criteriumvalue)) if ($displayby =~/branchcode/);
    return (GetSupportName($criteriumvalue)) if ($displayby =~/itemtype/);
    if ($displayby =~/suggestedby/||$displayby =~/managedby/||$displayby =~/acceptedby/){
        my $borr=C4::Members::GetMember(borrowernumber=>$criteriumvalue);
        return "" unless $borr;
        return $$borr{surname} . ", " . $$borr{firstname};
    }
    if ( $displayby =~ /budgetid/) {
        my $budget = GetBudget($criteriumvalue);
        return "" unless $budget;
        return $$budget{budget_name};
    }
}

my $input           = CGI->new;
my $redirect  = $input->param('redirect');
my $suggestedbyme   = (defined $input->param('suggestedbyme')? $input->param('suggestedbyme'):1);
my $op              = $input->param('op')||'else';
my @editsuggestions = $input->param('edit_field');
my $suggestedby     = $input->param('suggestedby');
my $returnsuggestedby = $input->param('returnsuggestedby');
my $returnsuggested = $input->param('returnsuggested');
my $managedby       = $input->param('managedby');
my $displayby       = $input->param('displayby') || '';
my $tabcode         = $input->param('tabcode');

# filter informations which are not suggestion related.
my $suggestion_ref  = $input->Vars;

# get only the columns of Suggestion
my $schema = Koha::Database->new()->schema;
my $columns = ' '.join(' ', $schema->source('Suggestion')->columns).' ';
my $suggestion_only = { map { $columns =~ / $_ / ? ($_ => $suggestion_ref->{$_}) : () } keys %$suggestion_ref };
$suggestion_only->{STATUS} = $suggestion_ref->{STATUS};

delete $$suggestion_ref{$_} foreach qw( suggestedbyme op displayby tabcode edit_field );
foreach (keys %$suggestion_ref){
    delete $$suggestion_ref{$_} if (!$$suggestion_ref{$_} && ($op eq 'else' || $op eq 'change'));
}
my ( $template, $borrowernumber, $cookie, $userflags ) = get_template_and_user(
        {
            template_name   => "suggestion/suggestion.tt",
            query           => $input,
            type            => "intranet",
            flagsrequired   => { catalogue => 1 },
        }
    );

$borrowernumber = $input->param('borrowernumber') if ( $input->param('borrowernumber') );
$template->param('borrowernumber' => $borrowernumber);

#########################################
##  Operations
##
if ( $op =~ /save/i ) {
    $suggestion_only->{suggesteddate} = dt_from_string( $suggestion_only->{suggesteddate} )
        if $suggestion_only->{suggesteddate};

    if ( $suggestion_only->{"STATUS"} ) {
        if ( my $tmpstatus = lc( $suggestion_only->{"STATUS"} ) =~ /ACCEPTED|REJECTED/i ) {
            $suggestion_only->{ lc( $suggestion_only->{"STATUS"}) . "date" } = dt_from_string;
            $suggestion_only->{ lc( $suggestion_only->{"STATUS"}) . "by" }   = C4::Context->userenv->{number};
        }
        $suggestion_only->{manageddate} = dt_from_string;
        $suggestion_only->{"managedby"}   = C4::Context->userenv->{number};
    }
    if ( $suggestion_only->{'suggestionid'} > 0 ) {
        &ModSuggestion($suggestion_only);
    } else {
        ###FIXME:Search here if suggestion already exists.
        my $suggestions_loop =
            SearchSuggestion( $suggestion_only );
        if (@$suggestions_loop>=1){
            #some suggestion are answering the request Donot Add
        } 
        else {    
            ## Adding some informations related to suggestion
            &NewSuggestion($suggestion_only);
        }
        # empty fields, to avoid filter in "SearchSuggestion"
    }  
    map{delete $$suggestion_ref{$_}} keys %$suggestion_ref;
    $op = 'else';

    if( $redirect eq 'purchase_suggestions' ) {
        print $input->redirect("/cgi-bin/koha/members/purchase-suggestions.pl?borrowernumber=$borrowernumber");
    }

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
    # set accepted/rejected/managed informations if applicable
    # ie= if the librarian has choosen some action on the suggestions
    if ($suggestion_only->{"STATUS"} eq "ACCEPTED"){
        $suggestion_only->{accepteddate} = dt_from_string;
        $suggestion_only->{"acceptedby"}=C4::Context->userenv->{number};
    } elsif ($suggestion_only->{"STATUS"} eq "REJECTED"){
        $suggestion_only->{rejecteddate} = dt_from_string;
        $suggestion_only->{"rejectedby"}=C4::Context->userenv->{number};
    }
    if ($suggestion_only->{"STATUS"}){
        $suggestion_only->{manageddate} = dt_from_string;
        $suggestion_only->{"managedby"}=C4::Context->userenv->{number};
    }
    if ( my $reason = $$suggestion_ref{"reason$tabcode"}){
        if ( $reason eq "other" ) {
            $reason = $$suggestion_ref{"other_reason$tabcode"};
        }
        $suggestion_only->{reason}=$reason;
    }

    foreach my $suggestionid (@editsuggestions) {
        next unless $suggestionid;
        $suggestion_only->{'suggestionid'}=$suggestionid;
        &ModSuggestion($suggestion_only);
    }
    my $params = '';
    foreach my $key (
        qw(
        displayby branchcode title author isbn publishercode copyrightdate
        collectiontitle suggestedby suggesteddate_from suggesteddate_to
        manageddate_from manageddate_to accepteddate_from
        accepteddate_to budgetid
        )
      )
    {
        $params .= $key . '=' . uri_escape($input->param($key)) . '&'
          if defined($input->param($key));
    }
    print $input->redirect("/cgi-bin/koha/suggestion/suggestion.pl?$params");
}elsif ($op eq "delete" ) {
    foreach my $delete_field (@editsuggestions) {
        &DelSuggestion( $borrowernumber, $delete_field,'intranet' );
    }
    $op = 'else';
}
elsif ( $op eq 'show' ) {
    $suggestion_ref=&GetSuggestion($$suggestion_ref{'suggestionid'});
    $$suggestion_ref{branchname} = GetBranchName $$suggestion_ref{branchcode};
    my $budget = GetBudget $$suggestion_ref{budgetid};
    $$suggestion_ref{budgetname} = $$budget{budget_name};
    Init($suggestion_ref);
}
if ($op=~/else/) {
    $op='else';
    
    $displayby||="STATUS";
    delete $$suggestion_ref{'branchcode'} if($displayby eq "branchcode");
    # distinct values of display by
    my $criteria_list=GetDistinctValues("suggestions.".$displayby);
    my (@criteria_dv, $criteria_has_empty);
    foreach (@$criteria_list) {
        if ($_->{value}) {
            push @criteria_dv, $_->{value};
        } else {
            $criteria_has_empty = 1;
        }
    }
    # agregate null and empty values under empty value
    push @criteria_dv, '' if $criteria_has_empty;

    my @allsuggestions;
    my $reasonsloop = GetAuthorisedValues("SUGGEST");
    foreach my $criteriumvalue ( @criteria_dv ) {
        # By default, display suggestions from current working branch
        unless ( exists $$suggestion_ref{'branchcode'} ) {
            $$suggestion_ref{'branchcode'} = C4::Context->userenv->{'branch'};
        }
        my $definedvalue = defined $$suggestion_ref{$displayby} && $$suggestion_ref{$displayby} ne "";

        next if ( $definedvalue && $$suggestion_ref{$displayby} ne $criteriumvalue );
        $$suggestion_ref{$displayby} = $criteriumvalue;

        my $suggestions = &SearchSuggestion($suggestion_ref);
        foreach my $suggestion (@$suggestions) {
            if ($suggestion->{budgetid}){
                my $bud = GetBudget( $suggestion->{budgetid} );
                $suggestion->{budget_name} = $bud->{budget_name} if $bud;
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

foreach my $element ( qw(managedby suggestedby acceptedby) ) {
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
    "op"             =>$op,
);

if(defined($returnsuggested) and $returnsuggested ne "noone")
{
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=".$returnsuggested."#suggestions");
}

####################
## Initializing selection lists

#branch display management
my $branchfilter = ($displayby ne "branchcode") ? $input->param('branchcode') : '';
my $onlymine =
     C4::Context->preference('IndependentBranches')
  && C4::Context->userenv
  && !C4::Context->IsSuperLibrarian()
  && C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my @branchloop;

foreach my $thisbranch ( sort {$branches->{$a}->{'branchname'} cmp $branches->{$b}->{'branchname'}} keys %$branches ) {
    my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
        selected   => ($branchfilter and $branches->{$thisbranch}->{'branchcode'} eq $branchfilter ) || ( $$suggestion_ref{'branchcode'} and $branches->{$thisbranch}->{'branchcode'} eq $$suggestion_ref{'branchcode'} )
    );
    push @branchloop, \%row;
}
$branchfilter=C4::Context->userenv->{'branch'} if ($onlymine && !$branchfilter);

$template->param( branchloop => \@branchloop,
                branchfilter => $branchfilter);

# the index parameter is different for item-level itemtypes
my $supportlist = GetSupportList();

foreach my $support (@$supportlist) {
    $$support{'selected'} = (defined $$suggestion_ref{'itemtype'})
        ? $$support{'itemtype'} eq $$suggestion_ref{'itemtype'}
        : 0;
    if ( $$support{'imageurl'} ) {
        $$support{'imageurl'} = getitemtypeimagelocation( 'intranet', $$support{'imageurl'} );
    } else {
        delete $$support{'imageurl'};
    }
}
$template->param(itemtypeloop=>$supportlist);
$template->param( returnsuggestedby => $returnsuggestedby );

my $patron_reason_loop = GetAuthorisedValues("OPAC_SUG",$$suggestion_ref{'patronreason'});
$template->param(patron_reason_loop=>$patron_reason_loop);

#Budgets management
my $budgets = [];
if ($branchfilter) {
    my $searchbudgets = { budget_branchcode => $branchfilter };
    $budgets = GetBudgets($searchbudgets);
} else {
    $budgets = GetBudgets(undef);
}

my @budgets_loop;
foreach my $budget ( @{$budgets} ) {
    next unless (CanUserUseBudget($borrowernumber, $budget, $userflags));

    ## Please see file perltidy.ERR
    $budget->{'selected'} = 1
        if ($$suggestion_ref{'budgetid'}
        && $budget->{'budget_id'} eq $$suggestion_ref{'budgetid'});

    push @budgets_loop, $budget;
}

$template->param( budgetsloop => \@budgets_loop);
$template->param( "statusselected_$$suggestion_ref{'STATUS'}" =>1) if ($$suggestion_ref{'STATUS'});

# get currencies and rates
my @rates = GetCurrencies();
my $count = scalar @rates;
my $active_currency = GetCurrency();
my $selected_currency;
if ($$suggestion_ref{'currency'}) {
    $selected_currency = $$suggestion_ref{'currency'};
}
else {
    $selected_currency = $active_currency->{currency};
}

my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currcode} = $rates[$i]->{'currency'};
    $line{rate}     = $rates[$i]->{'rate'};
    $line{selected} = 1 if ($line{'currcode'} eq $selected_currency);
    push @loop_currency, \%line;
}
$template->param(
    loop_currency => \@loop_currency,
    price        => sprintf("%.2f", $$suggestion_ref{'price'}||0),
    total            => sprintf("%.2f", $$suggestion_ref{'total'}||0),
);

# lists of distinct values (without empty) for filters
my %hashlists;
foreach my $field ( qw(managedby acceptedby suggestedby budgetid) ) {
    my $values_list;
    $values_list = GetDistinctValues( "suggestions." . $field );
    my @codes_list = map {
        {   'code' => $$_{'value'},
            'desc' => GetCriteriumDesc( $$_{'value'}, $field ) || $$_{'value'},
            'selected' => ($$suggestion_ref{$field}) ? $$_{'value'} eq $$suggestion_ref{$field} : 0,
        }
    } grep {
        $$_{'value'}
    } @$values_list;
    $hashlists{ lc($field) . "_loop" } = \@codes_list;
}

$template->param(
    %hashlists,
    borrowernumber           => ($input->param('borrowernumber') // undef),
    SuggestionStatuses       => GetAuthorisedValues('SUGGEST_STATUS'),
);
output_html_with_http_headers $input, $cookie, $template->output;
