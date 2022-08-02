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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;
use Koha::Exceptions;
use Koha::AdditionalContent;

use base qw(Koha::Objects);

=head1 NAME

Koha::AdditionalContents - Koha Additional content object set class

=head1 API

=head2 Class Methods

=cut

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

=cut

sub search_for_display {
    my ( $self, $params ) = @_;

    my $search_params;
    $search_params->{location} = $params->{location};
    $search_params->{branchcode} = $params->{library_id} ? [ $params->{library_id}, undef ] : undef;
    $search_params->{published_on} = { '<=' => \'CAST(NOW() AS DATE)' };
    $search_params->{-or} = [ expirationdate => { '>=' => \'CAST(NOW() AS DATE)' },
                              expirationdate => undef ];
    $search_params->{category} = $params->{category} if $params->{category};

    if ( $params->{lang} ) {
        # FIXME I am failing to translate the following query
        # SELECT   a1.category,   a1.code,   COALESCE(a2.title, a1.title)
        # FROM additional_contents a1
        # LEFT JOIN additional_contents a2 on a1.code=a2.code AND a2.lang="es-ES"
        # WHERE a1.lang = 'default';

        # So we are retrieving the code with a translated content, then the other ones
        my $translated_contents =
          $self->SUPER::search( { %$search_params, lang => $params->{lang} } );
        my $default_contents = $self->SUPER::search(
            {
                %$search_params,
                lang => 'default',
                code =>
                  { '-not_in' => [ $translated_contents->get_column('code') ] }
            }
        );

        return $self->SUPER::search(
            {
                idnew => [
                    $translated_contents->get_column('idnew'),
                    $default_contents->get_column('idnew')
                ]
            },
            { order_by => 'number' }
        );
    }

    return $self->SUPER::search({%$search_params, lang => 'default'}, { order_by => 'number'});
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
