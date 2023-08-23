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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers output_and_exit_if_error );
use C4::Suggestions;
use C4::Koha qw( GetAuthorisedValues );
use C4::Budgets qw( GetBudget GetBudgets GetBudgetHierarchy CanUserUseBudget );
use C4::Search qw( FindDuplicate GetDistinctValues );
use C4::Members;
use Koha::DateUtils qw( dt_from_string );
use Koha::AuthorisedValues;
use Koha::Acquisition::Currencies;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Suggestions;
use Koha::Token;

use URI::Escape qw( uri_escape );

sub Init{
    my $suggestion= shift @_;
    # "Managed by" is used only when a suggestion is being edited (not when created)
    if ($suggestion->{'suggesteddate'} eq "") {
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
    if ( $displayby =~ /branchcode/ ) {
        return $criteriumvalue ? Koha::Libraries->find($criteriumvalue)->branchname : "__ANY__";
    }
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
my @editsuggestions = $input->multi_param('suggestionid');
my $suggestedby     = $input->param('suggestedby');
my $returnsuggestedby = $input->param('returnsuggestedby');
my $returnsuggested = $input->param('returnsuggested');
my $managedby       = $input->param('managedby');
my $displayby       = $input->param('displayby') || '';
my $tabcode         = $input->param('tabcode');
my $save_confirmed  = $input->param('save_confirmed') || 0;
my $notify          = $input->param('notify');
my $filter_archived = $input->param('filter_archived') || 0;

my $reasonsloop     = GetAuthorisedValues("SUGGEST");

# filter informations which are not suggestion related.
my $suggestion_ref  = { %{$input->Vars} }; # Copying, otherwise $input will be modified
delete $suggestion_ref->{csrf_token};

# get only the columns of Suggestion
my $schema = Koha::Database->new()->schema;
my $columns = ' '.join(' ', $schema->source('Suggestion')->columns).' ';
my $suggestion_only = { map { $columns =~ / $_ / ? ($_ => $suggestion_ref->{$_}) : () } keys %$suggestion_ref };
$suggestion_only->{STATUS} = $suggestion_ref->{STATUS};

delete $$suggestion_ref{$_} foreach qw( suggestedbyme op displayby tabcode notify filter_archived );
foreach (keys %$suggestion_ref){
    delete $$suggestion_ref{$_} if (!$$suggestion_ref{$_} && ($op eq 'else' ));
}
delete $suggestion_only->{branchcode} if $suggestion_only->{branchcode} eq '__ANY__';
delete $suggestion_only->{budgetid}   if $suggestion_only->{budgetid}   eq '__ANY__';
while ( my ( $k, $v ) = each %$suggestion_only ) {
    delete $suggestion_only->{$k} if $v eq '';
}

my ( $template, $borrowernumber, $cookie, $userflags ) = get_template_and_user(
        {
            template_name   => "suggestion/suggestion.tt",
            query           => $input,
            type            => "intranet",
            flagsrequired   => { suggestions => 'suggestions_manage' },
        }
    );

$borrowernumber = $input->param('borrowernumber') if ( $input->param('borrowernumber') );
$template->param('borrowernumber' => $borrowernumber);
my $branchfilter = $input->param('branchcode') || C4::Context->userenv->{'branch'};

#########################################
##  Operations
##

if ( $op =~ /save/i ) {
    output_and_exit_if_error($input, $cookie, $template, { check => 'csrf_token' });
    my @messages;
    my $biblio = MarcRecordFromNewSuggestion({
            title => $suggestion_only->{title},
            author => $suggestion_only->{author},
            itemtype => $suggestion_only->{itemtype},
            isbn => $suggestion_only->{isbn},
    });

    my $manager = Koha::Patrons->find( $suggestion_only->{managedby} );
    if ( $manager && not $manager->has_permission({suggestions => 'suggestions_manage'})) {
        push @messages, { type => 'error', code => 'manager_not_enough_permissions' };
        $template->param(
            messages => \@messages,
        );
        delete $suggestion_ref->{suggesteddate};
        delete $suggestion_ref->{manageddate};
        delete $suggestion_ref->{managedby};
        Init($suggestion_ref);
    }
    elsif ( !$suggestion_only->{suggestionid} && ( my ($duplicatebiblionumber, $duplicatetitle) = FindDuplicate($biblio) ) && !$save_confirmed ) {
        push @messages, { type => 'error', code => 'biblio_exists', id => $duplicatebiblionumber, title => $duplicatetitle };
        $template->param(
            messages => \@messages,
            need_confirm => 1
        );
        delete $suggestion_ref->{suggesteddate};
        delete $suggestion_ref->{manageddate};
        Init($suggestion_ref);
    }
    else {

        for my $date_key ( qw( suggesteddate manageddate accepteddate rejecteddate ) ) {
            # FIXME Do we need this?
            $suggestion_only->{$date_key} = dt_from_string( $suggestion_only->{$date_key} )
                if $suggestion_only->{$date_key};
        }

        if ( $suggestion_only->{"STATUS"} ) {
            if ( my $tmpstatus = lc( $suggestion_only->{"STATUS"} ) =~ /ACCEPTED|REJECTED/i ) {
                $suggestion_only->{ lc( $suggestion_only->{"STATUS"}) . "date" } = dt_from_string;
                $suggestion_only->{ lc( $suggestion_only->{"STATUS"}) . "by" }   = C4::Context->userenv->{number};
            }
            $suggestion_only->{manageddate} = dt_from_string;
            $suggestion_only->{"managedby"} ||= C4::Context->userenv->{number};
        }

        my $otherreason = $input->param('other_reason');
        if ($suggestion_only->{reason} eq 'other' && $otherreason) {
            $suggestion_only->{reason} = $otherreason;
        }

        if ( $suggestion_only->{'suggestionid'} > 0 ) {

            $suggestion_only->{lastmodificationdate} = dt_from_string;
            $suggestion_only->{lastmodificationby}   = C4::Context->userenv->{number};
            $suggestion_only->{branchcode} = undef
              if exists $suggestion_only->{branchcode}
              && $suggestion_only->{branchcode} eq "";

            &ModSuggestion($suggestion_only);

            if ( $notify ) {
                my $patron = Koha::Patrons->find( $suggestion_only->{managedby} );
                my $email_address = $patron->notice_email_address;
                if ($patron->notice_email_address) {

                    my $letter = C4::Letters::GetPreparedLetter(
                        module      => 'suggestions',
                        letter_code => 'NOTIFY_MANAGER',
                        branchcode  => $patron->branchcode,
                        lang        => $patron->lang,
                        tables      => {
                            suggestions => $suggestion_only->{suggestionid},
                            branches    => $patron->branchcode,
                            borrowers   => $patron->borrowernumber,
                        },
                    );
                    C4::Letters::EnqueueLetter(
                        {
                            letter                 => $letter,
                            borrowernumber         => $patron->borrowernumber,
                            message_transport_type => 'email'
                        }
                    );
                }
            }
        } else {
            ###FIXME:Search here if suggestion already exists.
            my $suggestions= Koha::Suggestions->search_limited( $suggestion_only );
            if ( $suggestions->count ) {
                #some suggestion are answering the request Donot Add
                my @messages;
                while ( my $suggestion = $suggestions->next ) {
                    push @messages, { type => 'error', code => 'already_exists', id => $suggestion->suggestionid };
                }
                $template->param( messages => \@messages );
            }
            else {
                ## Adding some informations related to suggestion
                Koha::Suggestion->new($suggestion_only)->store();
            }
            # empty fields, to avoid filter in "SearchSuggestion"
        }
        map{delete $$suggestion_ref{$_} unless $_ eq 'branchcode' } keys %$suggestion_ref;
        $op = 'else';

        if( $redirect eq 'purchase_suggestions' ) {
            print $input->redirect("/cgi-bin/koha/members/purchase-suggestions.pl?borrowernumber=$borrowernumber");
        }
    }
}
elsif ($op=~/add/) {
    #Adds suggestion
    Init($suggestion_ref);
    $op ='save';
}
elsif ($op=~/edit/) {
    #Edit suggestion
    output_and_exit_if_error($input, $cookie, $template, { check => 'csrf_token' });
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
elsif ($op eq "update_status" ) {
    output_and_exit_if_error($input, $cookie, $template, { check => 'csrf_token' });
    my $suggestion;
    # set accepted/rejected/managed informations if applicable
    # ie= if the librarian has chosen some action on the suggestions
    my $STATUS      = $input->param('STATUS');
    my $accepted_by = $input->param('acceptedby');
    if ( $STATUS eq "ACCEPTED" ) {
        $suggestion = {
            accepteddate => dt_from_string,
            acceptedby => C4::Context->userenv->{number},
        };
    }
    elsif ( $STATUS eq "REJECTED" ) {
        $suggestion = {
            rejecteddate => dt_from_string,
            rejectedby   => C4::Context->userenv->{number},
        };
    }
    if ($STATUS) {
        $suggestion->{manageddate} = dt_from_string;
        $suggestion->{managedby}   = C4::Context->userenv->{number};
        $suggestion->{STATUS}      = $STATUS;
    }
    if ( my $reason = $input->param("reason") ) {
        if ( $reason eq "other" ) {
            $reason = $input->param("other_reason");
        }
        $suggestion->{reason} = $reason;
    }

    foreach my $suggestionid (@editsuggestions) {
        next unless $suggestionid;
        $suggestion->{suggestionid} = $suggestionid;
        &ModSuggestion($suggestion);
    }
    redirect_with_params($input);
}elsif ($op eq "delete" ) {
    output_and_exit_if_error($input, $cookie, $template, { check => 'csrf_token' });
    foreach my $delete_field (@editsuggestions) {
        &DelSuggestion( $borrowernumber, $delete_field,'intranet' );
    }
    redirect_with_params($input);
}
elsif ($op eq "archive" ) {
    Koha::Suggestions->find($_)->update({ archived => 1 }) for @editsuggestions;

    redirect_with_params($input);
}
elsif ($op eq "unarchive" ) {
    Koha::Suggestions->find($_)->update({ archived => 0 }) for @editsuggestions;

    redirect_with_params($input);
}
elsif ( $op eq 'update_itemtype' ) {
    my $new_itemtype = $input->param('suggestion_itemtype');
    foreach my $suggestionid (@editsuggestions) {
        next unless $suggestionid;
        &ModSuggestion({ suggestionid => $suggestionid, itemtype => $new_itemtype });
    }
    redirect_with_params($input);
}
elsif ( $op eq 'update_manager' ) {
    my $managedby = $input->param('suggestion_managedby');
    foreach my $suggestionid (@editsuggestions) {
        next unless $suggestionid;
        &ModSuggestion({ suggestionid => $suggestionid, managedby => $managedby });
    }
    redirect_with_params($input);
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

    # Hack to not modify GetDistinctValues for this specific case
    if (   $displayby eq 'branchcode'
        && C4::Context->preference('IndependentBranches')
        && not C4::Context->IsSuperLibrarian )
    {
        @criteria_dv = ( C4::Context->userenv->{'branch'} );
    }
    # Pending tab first
    if ( $displayby eq 'STATUS' ) {
        @criteria_dv = grep { $_ ne 'ASKED' } @criteria_dv;
        unshift @criteria_dv, 'ASKED';
    }

    unless ( exists $suggestion_ref->{branchcode} ) {
        $suggestion_ref->{branchcode} = C4::Context->userenv->{'branch'};
    }

    my @allsuggestions;
    foreach my $criteriumvalue ( @criteria_dv ) {
        my $search_params = {%$suggestion_ref};

        next
          if $search_params->{STATUS}
          && $displayby eq 'STATUS'
          && $criteriumvalue ne $search_params->{STATUS};

        # By default, display suggestions from current working branch
        my $definedvalue = defined $$suggestion_ref{$displayby} && $$suggestion_ref{$displayby} ne "";

        next if ( $definedvalue && $$suggestion_ref{$displayby} ne $criteriumvalue ) and ($displayby ne 'branchcode' && $branchfilter ne '__ANY__' );

        $search_params->{$displayby} = $criteriumvalue;

        # filter on date fields
        foreach my $field (qw( suggesteddate manageddate accepteddate )) {
            my $from    = delete $search_params->{"${field}_from"};
            my $to      = delete $search_params->{"${field}_to"};

            my $from_dt = $from && eval { dt_from_string($from) };
            my $to_dt   = $to && eval { dt_from_string($to) };

            if ( $from_dt || $to_dt ) {
                my $dtf = Koha::Database->new->schema->storage->datetime_parser;
                if ( $from_dt && $to_dt ) {
                    $search_params->{$field} = { -between => [ $dtf->format_date($from_dt), $dtf->format_date($to_dt) ] };
                } elsif ( $from_dt ) {
                    $search_params->{$field} = { '>=' => $dtf->format_date($from_dt) };
                } elsif ( $to_dt ) {
                    $search_params->{$field} = { '<=' => $dtf->format_date($to_dt) };
                }
            }
        }
        if ( $search_params->{budgetid} && $search_params->{budgetid} eq '__NONE__' ) {
            $search_params->{budgetid} = [undef, '' ];
        }
        for my $f (qw (branchcode budgetid)) {
            delete $search_params->{$f}
              if $search_params->{$f} eq '__ANY__'
              || $search_params->{$f} eq '';
        }

        $search_params->{archived} = 0 if !$filter_archived;
        my @suggestions = Koha::Suggestions->search_limited($search_params)->as_list;

        push @allsuggestions,
          {
            "suggestiontype"      => $criteriumvalue || "suggest",
            "suggestiontypelabel" => GetCriteriumDesc( $criteriumvalue, $displayby ) || "",
            'suggestions'         => \@suggestions,
            'reasonsloop'         => $reasonsloop,
          }
          if scalar @suggestions > 0;

        delete $$suggestion_ref{$displayby} unless $definedvalue;
    }

    $template->param(
        "displayby"=> $displayby,
        "notabs"=> $displayby eq "",
        suggestions       => \@allsuggestions,
    );
}

$template->param(
    "${_}_patron" => scalar Koha::Patrons->find( $suggestion_ref->{$_} ) )
  for qw(managedby suggestedby acceptedby lastmodificationby);

$template->param(
    %$suggestion_ref,
    filter_archived => $filter_archived,
    "op"             =>$op,
);

if(defined($returnsuggested) and $returnsuggested ne "noone")
{
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=".$returnsuggested."#suggestions");
}

$template->param(
    branchfilter => $branchfilter,
);

$template->param( returnsuggestedby => $returnsuggestedby );

my $patron_reason_loop = GetAuthorisedValues("OPAC_SUG");
$template->param(patron_reason_loop=>$patron_reason_loop);

# Budgets for filtering
my $budgets = GetBudgets;
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

# Budgets for suggestion add or edition
my $sugg_budget_loop = [];
my $sugg_budgets     = GetBudgetHierarchy();
foreach my $r ( @{$sugg_budgets} ) {
    next unless ( CanUserUseBudget( $borrowernumber, $r, $userflags ) );
    my $selected = ( $$suggestion_ref{budgetid} && $r->{budget_id} eq $$suggestion_ref{budgetid} ) ? 1 : 0;
    push @{$sugg_budget_loop},
      {
        b_id     => $r->{budget_id},
        b_txt    => $r->{budget_name},
        b_active => $r->{budget_period_active},
        selected => $selected,
      };
}
@{$sugg_budget_loop} = sort { uc( $a->{b_txt} ) cmp uc( $b->{b_txt} ) } @{$sugg_budget_loop};
$template->param( sugg_budgets => $sugg_budget_loop);

if( $suggestion_ref->{STATUS} ) {
    $template->param(
        "statusselected_".$suggestion_ref->{STATUS} => 1,
        selected_status => $suggestion_ref->{STATUS}, # We need template var selected_status in the second part of the template where template var suggestion.STATUS is out of scope
    );
}

my $currencies = Koha::Acquisition::Currencies->search;
$template->param(
    currencies   => $currencies,
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

my $csrf_token = Koha::Token->new->generate_csrf(
    {
        session_id => scalar $input->cookie('CGISESSID'),
    }
);

$template->param(
    %hashlists,
    borrowernumber     => ( $input->param('borrowernumber') // undef ),
    SuggestionStatuses => GetAuthorisedValues('SUGGEST_STATUS'),
    csrf_token         => $csrf_token,
);
output_html_with_http_headers $input, $cookie, $template->output;

sub redirect_with_params {
    my ( $input ) = @_;
    my $params = '';
    foreach my $key (
        qw(
        displayby branchcode title author isbn publishercode copyrightdate
        collectiontitle suggestedby suggesteddate_from suggesteddate_to
        manageddate_from manageddate_to accepteddate_from
        accepteddate_to budgetid filter_archived
        )
      )
    {
        $params .= $key . '=' . uri_escape(scalar $input->param($key)) . '&'
          if defined($input->param($key));
    }
    print $input->redirect("/cgi-bin/koha/suggestion/suggestion.pl?$params");
}
