package Koha::AdditionalContent;

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

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;
use Koha::Patrons;
use Koha::AdditionalContentsLocalizations;

use base qw(Koha::Object);

=head1 NAME

Koha::AdditionalContent - Koha Additional content object class

=head1 API

=head2 Class Methods

=cut

=head3 author

    $additional_content->author;

Return the Koha::Patron object for the patron who authored this additional content

=cut

sub author {
    my ($self) = @_;
    my $author_rs = $self->_result->borrowernumber;
    return unless $author_rs;
    return Koha::Patron->_new_from_dbic($author_rs);
}

=head3 is_expired

my $is_expired = $additional_content->is_expired;

Returns 1 if the additional content is expired or 0;

=cut

sub is_expired {
    my ($self) = @_;

    return 0 unless $self->expirationdate;
    return 1 if dt_from_string( $self->expirationdate ) < dt_from_string->truncate( to => 'day' );
    return 0;
}

=head3 library

my $library = $additional_content->library;

Returns Koha::Library object or undef

=cut

sub library {
    my ($self) = @_;

    my $library_rs = $self->_result->branchcode;
    return unless $library_rs;
    return Koha::Library->_new_from_dbic($library_rs);
}

=head3 translated_contents

my $translated_contents = $additional_content->translated_contents;
$additional_content->translated_contents(\@contents)

=cut

sub translated_contents {
    my ( $self, $localizations ) = @_;
    if ($localizations) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->translated_contents->delete;

                for my $localization (@$localizations) {
                    $self->_result->add_to_additional_contents_localizations($localization);
                }
            }
        );
    }

    my $rs = $self->_result->additional_contents_localizations;
    return Koha::AdditionalContentsLocalizations->_new_from_dbic($rs);
}

=head3 default_localization

my $default_content = $additional_content->default_localization;

Return the default content.

=cut

sub default_localization {
    my ($self) = @_;
    my $rs = $self->_result->additional_contents_localizations->find( { lang => 'default' } );
    return Koha::AdditionalContentsLocalization->_new_from_dbic($rs);
}

=head3 translated_content

my $translated_content = $additional_content->translated_content($lang);

Return the translated content for a given language. The default is returned if none exist.

=cut

sub translated_content {
    my ( $self, $lang ) = @_;
    $lang ||= 'default';
    my $content = $self->translated_contents->search(
        { lang     => [ 'default', $lang ] },
        { order_by => { -asc => [ \'lang="default"', 'id' ] } }
    )->next;
    return $content;
}

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [
        'id',         'category',       'code',
        'location',   'branchcode',     'published_on',
        'updated_on', 'expirationdate', 'number',
        'borrowernumber'
    ];
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::AdditionalContent object
on the API.

=cut

sub to_api_mapping {
    return {
        id             => 'additional_content_id',
        category       => 'category',
        code           => 'code',
        location       => 'location',
        branchcode     => 'library_id',
        published_on   => 'published_on',
        updated_on     => 'updated_on',
        expirationdate => 'expirationdate',
        number         => 'number',
        borrowernumber => 'patron_id',
    };
}

=head3 _type

=cut

sub _type {
    return 'AdditionalContent';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
