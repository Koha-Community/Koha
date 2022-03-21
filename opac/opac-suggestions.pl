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
use Encode;
use C4::Auth qw( get_template_and_user );
use C4::Members;
use C4::Koha qw( GetAuthorisedValues );
use C4::Output qw( output_html_with_http_headers );
use C4::Suggestions qw(
    DelSuggestion
    MarcRecordFromNewSuggestion
    NewSuggestion
    SearchSuggestion
);
use C4::Koha qw( GetAuthorisedValues );
use C4::Scrubber;
use C4::Search qw( FindDuplicate );

use Koha::AuthorisedValues;
use Koha::Libraries;
use Koha::Patrons;

use Koha::DateUtils qw( dt_from_string output_pref );

my $input           = CGI->new;
my $op              = $input->param('op') || 'else';
my $biblionumber    = $input->param('biblionumber');
my $negcaptcha      = $input->param('negcap');
my $suggested_by_anyone = $input->param('suggested_by_anyone') || 0;
my $title_filter    = $input->param('title_filter');
my $need_confirm    = 0;

my $suggestion = {
    biblionumber    => scalar $input->param('biblionumber'),
    title           => scalar $input->param('title'),
    author          => scalar $input->param('author'),
    copyrightdate   => scalar $input->param('copyrightdate'),
    isbn            => scalar $input->param('isbn'),
    publishercode   => scalar $input->param('publishercode'),
    collectiontitle => scalar $input->param('collectiontitle'),
    place           => scalar $input->param('place'),
    quantity        => scalar $input->param('quantity'),
    itemtype        => scalar $input->param('itemtype'),
    branchcode      => scalar $input->param('branchcode'),
    patronreason    => scalar $input->param('patronreason'),
    note            => scalar $input->param('note'),
};

# If a spambot accidentally populates the 'negcap' field in the sugesstions form, then silently skip and return.
if ($negcaptcha ) {
    print $input->redirect("/cgi-bin/koha/opac-suggestions.pl");
    exit;
}

#If suggestions are turned off we redirect to 404 error. This will also redirect guest suggestions
if ( ! C4::Context->preference('suggestion') ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie, @messages );
my $deleted = $input->param('deleted');
my $submitted = $input->param('submitted');

if ( ( C4::Context->preference("AnonSuggestions") and Koha::Patrons->find( C4::Context->preference("AnonymousPatron") ) ) or ( C4::Context->preference("OPACViewOthersSuggestions") and $op eq 'else' ) ) {
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

if ( $op eq "add_validate" && not $biblionumber ) { # If we are creating the suggestion from an existing record we do not want to search for duplicates
    $op = 'add_confirm';
    my $biblio = MarcRecordFromNewSuggestion($suggestion);
    if ( my ($duplicatebiblionumber, $duplicatetitle) = FindDuplicate($biblio) ) {
        push @messages, { type => 'error', code => 'biblio_exists', id => $duplicatebiblionumber, title => $duplicatetitle };
        $need_confirm = 1;
        $op = 'add';
    }
}

my $patrons_pending_suggestions_count = 0;
my $patrons_total_suggestions_count = 0;
if ( $borrowernumber ){
    if ( C4::Context->preference("MaxTotalSuggestions") ne '' && C4::Context->preference("NumberOfSuggestionDays") ne '' ) {
        my $suggesteddate_from = dt_from_string()->subtract(days=>C4::Context->preference("NumberOfSuggestionDays"));
        $suggesteddate_from = output_pref({ dt => $suggesteddate_from, dateformat => 'iso', dateonly => 1 });
        $patrons_total_suggestions_count = Koha::Suggestions->search({ suggestedby => $borrowernumber, suggesteddate => { '>=' => $suggesteddate_from } })->count;

    }
    if ( C4::Context->preference("MaxOpenSuggestions") ne '' ) {
        $patrons_pending_suggestions_count = Koha::Suggestions->search({ suggestedby => $borrowernumber, STATUS => 'ASKED' } )->count ;
    }
}

if ( $op eq "add_confirm" ) {
    my $suggestions_loop = &SearchSuggestion($suggestion);
    if ( C4::Context->preference("MaxTotalSuggestions") ne '' && $patrons_total_suggestions_count >= C4::Context->preference("MaxTotalSuggestions") )
    {
        push @messages, { type => 'error', code => 'total_suggestions' };
    }
    elsif ( C4::Context->preference("MaxOpenSuggestions") ne '' && $patrons_pending_suggestions_count >= C4::Context->preference("MaxOpenSuggestions") ) #only check limit for signed in borrowers
    {
        push @messages, { type => 'error', code => 'too_many' };
    }
    elsif ( @$suggestions_loop >= 1 ) {

        #some suggestion are answering the request Donot Add
        for my $s (@$suggestions_loop) {
            push @messages,
              {
                type => 'error',
                code => 'already_exists',
                id   => $s->{suggestionid}
              };
            last;
        }
    }
    else {
        for my $f ( split(/\s*\,\s*/, C4::Context->preference("OPACSuggestionUnwantedFields") ) ) {
            delete $suggestion->{$f};
        }

        my $scrubber = C4::Scrubber->new();
        foreach my $suggest ( keys %$suggestion ) {

            # Don't know why the encode is needed for Perl v5.10 here
            $suggestion->{$suggest} = Encode::encode( "utf8",
                $scrubber->scrub( $suggestion->{$suggest} ) );
        }
        $suggestion->{suggesteddate} = dt_from_string;
        $suggestion->{branchcode} = $input->param('branchcode') || C4::Context->userenv->{"branch"};
        $suggestion->{STATUS} = 'ASKED';
        if ( $biblionumber ) {
            my $biblio = Koha::Biblios->find($biblionumber);
            $suggestion->{biblionumber} = $biblio->biblionumber;
            $suggestion->{title} = $biblio->title;
            $suggestion->{author} = $biblio->author;
            $suggestion->{copyrightdate} = $biblio->copyrightdate;
            $suggestion->{isbn} = $biblio->biblioitem->isbn;
            $suggestion->{publishercode} = $biblio->biblioitem->publishercode;
            $suggestion->{collectiontitle} = $biblio->biblioitem->collectiontitle;
            $suggestion->{place} = $biblio->biblioitem->place;
        }

        &NewSuggestion($suggestion);
        $patrons_pending_suggestions_count++;
        $patrons_total_suggestions_count++;

        # delete empty fields, to avoid filter in "SearchSuggestion"
        foreach my $field ( qw( title author publishercode copyrightdate place collectiontitle isbn STATUS ) ) {
            delete $suggestion->{$field}; #clear search filters (except borrower related) to show all suggestions after placing a new one
        }
        $suggestions_loop = &SearchSuggestion($suggestion);

        push @messages, { type => 'info', code => 'success_on_inserted' };

    }
    $op = 'else';
}

my $suggestions_loop = &SearchSuggestion(
    {
        suggestedby => $suggestion->{suggestedby},
        title       => $title_filter,
    }
);
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

my $patron_reason_loop = GetAuthorisedValues("OPAC_SUG", "opac");

my @mandatoryfields;
if ( $op eq 'add' ) {
    my $fldsreq_sp = C4::Context->preference("OPACSuggestionMandatoryFields") || 'title';
    @mandatoryfields = sort split(/\s*\,\s*/, $fldsreq_sp);
    foreach (@mandatoryfields) {
        $template->param( $_."_required" => 1);
    }
    if ( $biblionumber ) {
        my $biblio = Koha::Biblios->find($biblionumber);
        $suggestion = {
            biblionumber    => $biblio->biblionumber,
            title           => $biblio->title,
            author          => $biblio->author,
            copyrightdate   => $biblio->copyrightdate,
            isbn            => $biblio->biblioitem->isbn,
            publishercode   => $biblio->biblioitem->publishercode,
            collectiontitle => $biblio->biblioitem->collectiontitle,
            place           => $biblio->biblioitem->place,
        };
    }
}

my @unwantedfields;
{
    last unless ($op eq 'add');
    my $fldsreq_sp = C4::Context->preference("OPACSuggestionUnwantedFields");
    @unwantedfields = sort split(/\s*\,\s*/, $fldsreq_sp);
    foreach (@unwantedfields) {
        $template->param( $_."_hidden" => 1);
    }
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
    title_filter          => $title_filter,
    patrons_pending_suggestions_count => $patrons_pending_suggestions_count,
    need_confirm => $need_confirm,
    patrons_total_suggestions_count => $patrons_total_suggestions_count,
);

output_html_with_http_headers $input, $cookie, $template->output, undef, { force_no_caching => 1 };

