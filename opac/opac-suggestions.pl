#!/usr/bin/perl

# This file is part of Koha.
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


use CGI qw ( -utf8 );
use Encode qw( encode );
use C4::Auth;    # get_template_and_user
use C4::Members;
use C4::Koha;
use C4::Output;
use C4::Suggestions;
use C4::Koha;
use C4::Scrubber;

use Koha::AuthorisedValues;
use Koha::Libraries;
use Koha::Patrons;

use Koha::DateUtils qw( dt_from_string );

my $input           = new CGI;
my $op              = $input->param('op');
my $suggestion      = $input->Vars;
my $negcaptcha      = $input->param('negcap');
my $suggested_by_anyone = $input->param('suggested_by_anyone') || 0;

# If a spambot accidentally populates the 'negcap' field in the sugesstions form, then silently skip and return.
if ($negcaptcha ) {
    print $input->redirect("/cgi-bin/koha/opac-suggestions.pl");
    exit;
} else {
    # don't pass 'negcap' column to DB, else DBI::Class will error
    # DBIx::Class::Row::store_column(): No such column 'negcap' on Koha::Schema::Result::Suggestion at  Koha/C4/Suggestions.pm
    delete $suggestion->{negcap};
}

#If suggestions are turned off we redirect to 404 error. This will also redirect guest suggestions
if ( ! C4::Context->preference('suggestion') ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

delete $suggestion->{$_} foreach qw<op suggested_by_anyone>;
$op = 'else' unless $op;

my ( $template, $borrowernumber, $cookie, @messages );
my $deleted = $input->param('deleted');
my $submitted = $input->param('submitted');

if ( C4::Context->preference("AnonSuggestions") or ( C4::Context->preference("OPACViewOthersSuggestions") and $op eq 'else' ) ) {
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-suggestions.tt",
            query           => $input,
            type            => "opac",
            authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        }
    );
}
else {
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-suggestions.tt",
            query           => $input,
            type            => "opac",
            authnotrequired => 0,
        }
    );
}

if ( $op eq 'else' ) {
    if ( C4::Context->preference("OPACViewOthersSuggestions") ) {
        if ( $borrowernumber ) {
            # A logged in user is able to see suggestions from others
            $suggestion->{suggestedby} = $suggested_by_anyone
                ? undef
                : $borrowernumber;
        }
        else {
            # Non logged in user is able to see all suggestions
            $suggestion->{suggestedby} = undef;
        }
    }
    else {
        if ( $borrowernumber ) {
            $suggestion->{suggestedby} = $borrowernumber;
        }
        else {
            $suggestion->{suggestedby} = -1;
        }
    }
} else {
    if ( $borrowernumber ) {
        $suggestion->{suggestedby} = $borrowernumber;
    }
    else {
        $suggestion->{suggestedby} = C4::Context->preference("AnonymousPatron");
    }
}

my $patrons_pending_suggestions_count = 0;
if ( $borrowernumber && C4::Context->preference("MaxOpenSuggestions") ne '' ) {
    $patrons_pending_suggestions_count = scalar @{ SearchSuggestion( { suggestedby => $borrowernumber, STATUS => 'ASKED' } ) } ;
}

my $suggestions_loop = &SearchSuggestion($suggestion);
if ( $op eq "add_confirm" ) {
    if ( C4::Context->preference("MaxOpenSuggestions") ne '' && $patrons_pending_suggestions_count >= C4::Context->preference("MaxOpenSuggestions") ) #only check limit for signed in borrowers
    {
        push @messages, { type => 'error', code => 'too_many' };
    }
    elsif ( @$suggestions_loop >= 1 ) {

        #some suggestion are answering the request Donot Add
        for my $suggestion (@$suggestions_loop) {
            push @messages,
              {
                type => 'error',
                code => 'already_exists',
                id   => $suggestion->{suggestionid}
              };
            last;
        }
    }
    else {
        my $scrubber = C4::Scrubber->new();
        foreach my $suggest ( keys %$suggestion ) {

            # Don't know why the encode is needed for Perl v5.10 here
            $suggestion->{$suggest} = Encode::encode( "utf8",
                $scrubber->scrub( $suggestion->{$suggest} ) );
        }
        $suggestion->{suggesteddate} = dt_from_string;
        $suggestion->{branchcode} = $input->param('branchcode') || C4::Context->userenv->{"branch"};

        &NewSuggestion($suggestion);
        $patrons_pending_suggestions_count++;

        # delete empty fields, to avoid filter in "SearchSuggestion"
        foreach my $field ( qw( title author publishercode copyrightdate place collectiontitle isbn STATUS ) ) {
            delete $suggestion->{$field}; #clear search filters (except borrower related) to show all suggestions after placing a new one
        }
        $suggestions_loop = &SearchSuggestion($suggestion);

        push @messages, { type => 'info', code => 'success_on_inserted' };

    }
    $op = 'else';
}

if ( $op eq "delete_confirm" ) {
    my @delete_field = $input->multi_param("delete_field");
    foreach my $delete_field (@delete_field) {
        &DelSuggestion( $borrowernumber, $delete_field );
    }
    $op = 'else';
    print $input->redirect("/cgi-bin/koha/opac-suggestions.pl?op=else");
    exit;
}

map{
    my $s = $_;
    my $library = Koha::Libraries->find($s->{branchcodesuggestedby});
    $library ? $s->{branchcodesuggestedby} = $library->branchname : ()
} @$suggestions_loop;

foreach my $suggestion(@$suggestions_loop) {
    if($suggestion->{'suggestedby'} == $borrowernumber) {
        $suggestion->{'showcheckbox'} = $borrowernumber;
    } else {
        $suggestion->{'showcheckbox'} = 0;
    }
    if($suggestion->{'patronreason'}){
        my $av = Koha::AuthorisedValues->search({ category => 'OPAC_SUG', authorised_value => $suggestion->{patronreason} });
        $suggestion->{'patronreason'} = $av->count ? $av->next->opac_description : '';
    }
}

my $patron_reason_loop = GetAuthorisedValues("OPAC_SUG");

# Is the person allowed to choose their branch
if ( C4::Context->preference("AllowPurchaseSuggestionBranchChoice") ) {
    my $branchcode = $input->param('branchcode') || q{};

    if ( !$branchcode
        && C4::Context->userenv
        && C4::Context->userenv->{branch} )
    {
        $branchcode = C4::Context->userenv->{branch};
    }

    $template->param( branchcode => $branchcode );
}

my $mandatoryfields = '';
{
    last unless ($op eq 'add');
    my $fldsreq_sp = C4::Context->preference("OPACSuggestionMandatoryFields") || 'title';
    $mandatoryfields = join(', ', (map { '"'.$_.'"'; } sort split(/\s*\,\s*/, $fldsreq_sp)));
}

$template->param(
    %$suggestion,
    suggestions_loop      => $suggestions_loop,
    patron_reason_loop    => $patron_reason_loop,
    "op_$op"              => 1,
    $op                   => 1,
    messages              => \@messages,
    suggestionsview       => 1,
    suggested_by_anyone   => $suggested_by_anyone,
    mandatoryfields       => $mandatoryfields,
    patrons_pending_suggestions_count => $patrons_pending_suggestions_count,
);

output_html_with_http_headers $input, $cookie, $template->output;

