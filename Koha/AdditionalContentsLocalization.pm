package Koha::AdditionalContentsLocalization;

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
use Koha::AdditionalContents;

use base qw(Koha::Object);

=head1 NAME

Koha::AdditionalContentsLocalization - Koha Additional content localization object class

=head1 API

=head2 Class Methods

=cut

=head3 additional_content

    $c->additional_content;

Return the Koha::AdditionalContent for this translated content.

=cut

sub additional_content {
    my ($self) = @_;
    my $rs = $self->_result->additional_content;
    return Koha::AdditionalContent->_new_from_dbic($rs);
}

=head3 author

    $c->author;

Return the author of the content

=cut

sub author {
    my ( $self, @params ) = @_;
    return $self->additional_content->author(@params);
}

=head3 is_expired

    $c->is_expired;

Return $content->is_expired

=cut

sub is_expired {
    my ( $self, @params ) = @_;
    return $self->additional_content->is_expired(@params);
}

=head3 library

    $c->library;

Return the library of the content

=cut

sub library {
    my ( $self, @params ) = @_;
    return $self->additional_content->library(@params);
}

=head3 category

    $c->category;

Return the category of the content

=cut

sub category {
    my ( $self, @params ) = @_;
    return $self->additional_content->category;
}

=head3 code

    $c->code;

Return the code of the content

=cut

sub code {
    my ( $self, @params ) = @_;
    return $self->additional_content->code(@params);
}

=head3 location

    $c->location;

Return the location of the content

=cut

sub location {
    my ( $self, @params ) = @_;
    return $self->additional_content->location(@params);
}

=head3 branchcode

    $c->branchcode;

Return the branchcode of the content

=cut

sub branchcode {
    my ( $self, @params ) = @_;
    return $self->additional_content->branchcode(@params);
}

=head3 published_on

    $c->published_on;

Return the publication date of the content

=cut

sub published_on {
    my ( $self, @params ) = @_;
    return $self->additional_content->published_on(@params);
}

=head3 expirationdate

    $c->expirationdate;

Return the expiration date of the content

=cut

sub expirationdate {
    my ( $self, @params ) = @_;
    return $self->additional_content->expirationdate(@params);
}

=head3 number

    $c->number;

Return the number (order of display) of the content

=cut

sub number {
    my ( $self, @params ) = @_;
    return $self->additional_content->number(@params);
}

=head3 borrowernumber

    $c->borrowernumber;

Return the borrowernumber of the content

=cut

sub borrowernumber {
    my ( $self, @params ) = @_;
    return $self->additional_content->borrowernumber(@params);
}

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [
        'id',      'additional_content_id', 'title',
        'content', 'lang',                  'updated_on',
    ];
}

=head2 Class Methods

=cut

=head3 _type

=cut

sub _type {
    return 'AdditionalContentsLocalization';
}

1;
