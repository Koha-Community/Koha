package Koha::AdditionalContents;

# Copyright ByWater Solutions 2015
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Array::Utils qw( array_minus );

use Koha::Database;
use Koha::Exceptions;
use Koha::AdditionalContent;
use Koha::AdditionalContentsLocalizations;

use base qw(Koha::Objects);

=head1 NAME

Koha::AdditionalContents - Koha Additional content object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_public_query_search_params

    my $public_query_search_params = $self->get_public_query_search_params($params);

=cut

sub get_public_query_search_params {
    my ($params) = @_;

    my $search_params;
    $search_params->{'additional_content.id'} = $params->{id} if $params->{id};
    $search_params->{location}                = $params->{location};
    $search_params->{branchcode}              = $params->{library_id} ? [ $params->{library_id}, undef ] : undef;
    $search_params->{published_on}   = { '<=' => \'CAST(NOW() AS DATE)' }                   unless $params->{id};
    $search_params->{expirationdate} = [ '-or', { '>=' => \'CAST(NOW() AS DATE)' }, undef ] unless $params->{id};
    $search_params->{category}       = $params->{category} if $params->{category};

    return $search_params;
}

=head3 search_for_display

my $contents = Koha::AdditionalContents->search_for_display({
    category => 'news', # news or html_customizations
    location => 'slip',
    lang => 'es-ES',
    library_id => $branchcode
})

Return Koha::AdditionalContents set for display to user

You can limit the results by location, language and library by optional params

library_id should be valid branchcode of defined library

location is one of this:
- slip - for ISSUESLIP notice
- staff_only - for intranet
- opac_only - for OPAC
- staff_and_opac - for intranet and online catalogue
- OpacNavRight - Right column in the online catalogue
- opacheader
- OpacCustomSearch
- OpacMainUserBlock
- opaccredits
- OpacLoginInstructions
- OpacSuggestionInstructions
- ArticleRequestsDisclaimerText
- CookieConsentBar
- CookieConsentPopup

=cut

sub search_for_display {
    my ( $self, $params ) = @_;
    my $lang = $params->{lang} || q{};

    # If lang is not default, we will search for entries matching $lang but fallback to default if $lang is not found
    # Then we need a subquery count in where clause; DBIx::Class/SQL::Abstract does not support it, fallback to literal SQL
    my $subquery =
        qq|(SELECT COUNT(*) FROM additional_contents_localizations WHERE lang='$lang' AND additional_content_id=me.additional_content_id)=0|;

    my $search_params = get_public_query_search_params($params);
    $search_params->{lang} = 'default' if !$lang || $lang eq 'default';
    $search_params->{-or} = [ { 'lang' => $lang }, '-and' => [ 'lang', 'default', \$subquery ] ]
        if !$search_params->{lang};

    my $attribs = { prefetch => 'additional_content', order_by => 'additional_content.number' };
    return Koha::AdditionalContentsLocalizations->search( $search_params, $attribs );
}

=head3 find_best_match

    Koha::AdditionalContents->find_best_match({
        category => , location => , lang => , library_id =>
    });

    When choosing the best match, a match on lang and library is preferred.
    Next a match on library and default lang. Then match on All libs and lang.
    Finally a match with All libs and default lang.

=cut

sub find_best_match {
    my ( $self, $params ) = @_;
    my $library_id = $params->{library_id};
    my $lang       = $params->{lang};

    my $contents = $self->SUPER::search(
        {
            category   => $params->{category},
            location   => $params->{location},
            branchcode => [ $library_id, undef ],
        }
    );

    my $rs = Koha::AdditionalContentsLocalizations->search(
        {
            additional_content_id => [ $contents->get_column('id') ],
            lang                  => [ $lang, 'default' ],
        }
    );

    # Pick the best
    my ( $alt1, $alt2, $alt3 );
    while ( my $rec = $rs->next ) {
        return $rec
            if $library_id && $rec->branchcode && $rec->branchcode eq $library_id && $lang && $rec->lang eq $lang;
        $alt1 = $rec if !$alt1 && $library_id && $rec->branchcode && $rec->branchcode eq $library_id;
        $alt2 = $rec if !$alt2 && $lang && $rec->lang eq $lang;
        $alt3 = $rec if !$alt3;
    }
    return $alt1 // $alt2 // $alt3;
}

=head3 get_html_customizations_options

    Koha::AdditionalContents->get_html_customizations_options('opac');

=cut

sub get_html_customizations_options {
    my ($interface) = @_;

    if ( $interface eq 'opac' ) {
        return [
            'OpacNavRight',                  'opacheader',       'OpacCustomSearch', 'OpacMainUserBlock', 'opaccredits',
            'OpacLoginInstructions',         'OpacNav',          'OpacNavBottom',     'OpacSuggestionInstructions',
            'ArticleRequestsDisclaimerText', 'OpacMoreSearches', 'OpacMySummaryNote', 'OpacLibraryInfo',
            'OpacMaintenanceNotice',         'OPACResultsSidebar',   'OpacSuppressionMessage', 'SCOMainUserBlock',
            'SelfCheckInMainUserBlock',      'SelfCheckHelpMessage', 'CatalogConcernHelp',     'CatalogConcernTemplate',
            'CookieConsentBar',              'CookieConsentPopup',   'PatronSelfRegistrationAdditionalInstructions',
            'ILLModuleCopyrightClearance'
        ];
    }

    if ( $interface eq 'staff' ) {
        return [
            'IntranetmainUserblock', 'StaffReportsHome',     'RoutingListNote', 'StaffAcquisitionsHome',
            'StaffAuthoritiesHome',  'StaffCataloguingHome', 'StaffListsHome',  'StaffLoginInstructions',
            'StaffPatronsHome',      'StaffPOSHome',         'StaffSerialsHome'
        ];
    }

    return [];

}

=head3 _type

=cut

sub _type {
    return 'AdditionalContent';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::AdditionalContent';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
