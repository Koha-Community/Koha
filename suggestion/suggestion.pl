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

use Modern::Perl;
require Exporter;
use CGI qw ( -utf8 );
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Suggestions;
use C4::Koha;
use C4::Budgets;
use C4::Search;
use C4::Members;
use C4::Debug;

use Koha::DateUtils qw( dt_from_string );
use Koha::AuthorisedValues;
use Koha::Acquisition::Currencies;
use Koha::Libraries;
use Koha::Patrons;

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
        unless ( grep { /$criteriumvalue/ } qw(ASKED ACCEPTED REJECTED CHECKED ORDERED AVAILABLE) ) {
            my $av = Koha::AuthorisedValues->search({ category => 'SUGGEST_STATUS', authorised_value => $criteriumvalue });
            return $av->count ? $av->next->lib : 'Unknown';
        }
        return ($criteriumvalue eq 'ASKED'?"Pending":ucfirst(lc( $criteriumvalue))) if ($displayby =~/status/i);
    }
    return Koha::Libraries->find($criteriumvalue)->branchname
        if $displayby =~ /branchcode/;
    if ( $displayby =~ /itemtype/ ) {
        my $av = Koha::AuthorisedValues->search({ category => 'SUGGEST_FORMAT', authorised_value => $criteriumvalue });
        return $av->count ? $av->next->lib : 'Unknown';
    }
    if ($displayby =~/suggestedby/||$displayby =~/managedby/||$displayby =~/acceptedby/){
        my $patron = Koha::Patrons->find( $criteriumvalue );
        return "" unless $patron;
        return $patron->surname . ", " . $patron->firstname;
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
my @editsuggestions = $input->multi_param('edit_field');
my $suggestedby     = $input->param('suggestedby');
my $returnsuggestedby = $input->param('returnsuggestedby');
my $returnsuggested = $input->param('returnsuggested');
my $managedby       = $input->param('managedby');
my $displayby       = $input->param('displayby') || '';
my $tabcode         = $input->param('tabcode');
my $reasonsloop     = GetAuthorisedValues("SUGGEST");

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
            flagsrequired   => { acquisition => 'suggestions_manage' },
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

    my $otherreason = $input->param('other_reason');
    if ($suggestion_only->{reason} eq 'other' && $otherreason) {
        $suggestion_only->{reason} = $otherreason;
    }

    if ( $suggestion_only->{'suggestionid'} > 0 ) {
        &ModSuggestion($suggestion_only);
    } else {
        ###FIXME:Search here if suggestion already exists.
        my $suggestions_loop =
            SearchSuggestion( $suggestion_only );
        if (@$suggestions_loop>=1){
            #some suggestion are answering the request Donot Add
            my @messages;
            for my $suggestion ( @$suggestions_loop ) {
                push @messages, { type => 'error', code => 'already_exists', id => $suggestion->{suggestionid} };
            }
            $template->param( messages => \@messages );
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
    $suggestion_ref->{reasonsloop} = $reasonsloop;
    my $other_reason = 1;
    foreach my $reason ( @{ $reasonsloop } ) {
        if ($suggestion_ref->{reason} eq $reason->{lib}) {
            $other_reason = 0;
        }
    }
    $other_reason = 0 unless $suggestion_ref->{reason};
    $template->param(other_reason => $other_reason);
    Init($suggestion_ref);
    $op ='save';
}  
elsif ($op eq "change" ) {
    # set accepted/rejected/managed informations if applicable
    # ie= if the librarian has chosen some action on the suggestions
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
    # aggregate null and empty values under empty value
    push @criteria_dv, '' if $criteria_has_empty;

    my @allsuggestions;
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
        my $patron = Koha::Patrons->find( $$suggestion_ref{$element} );
        my $category = $patron->category;
        $template->param(
            $element."_borrowernumber"=>$patron->borrowernumber,
            $element."_firstname"=>$patron->firstname,
            $element."_surname"=>$patron->surname,
            $element."_cardnumber"=>$patron->cardnumber,
            $element."_branchcode"=>$patron->branchcode,
            $element."_description"=>$category->description,
            $element."_category_type"=>$category->category_type,
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

my $branchfilter = ($displayby ne "branchcode") ? $input->param('branchcode') : C4::Context->userenv->{'branch'};

$template->param(
    branchfilter => $branchfilter,
);

$template->param( returnsuggestedby => $returnsuggestedby );

my $patron_reason_loop = GetAuthorisedValues("OPAC_SUG");
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
if( $suggestion_ref->{STATUS} ) {
    $template->param(
        "statusselected_".$suggestion_ref->{STATUS} => 1,
        selected_status => $suggestion_ref->{STATUS}, # We need template var selected_status in the second part of the template where template var suggestion.STATUS is out of scope
    );
}

my @currencies = Koha::Acquisition::Currencies->search;
$template->param(
    currencies   => \@currencies,
    suggestion   => $suggestion_ref,
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
