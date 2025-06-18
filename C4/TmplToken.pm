package C4::TmplToken;

# Copyright Tamil 2011
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

use strict;
use warnings;
use C4::TmplTokenType;

=head1 NAME

TmplToken.pm - Object representing a scanner token for .tmpl files

=head1 DESCRIPTION

This is a class representing a token scanned from an HTML::Template .tmpl file.

=cut

=head2 new

Missing POD for new.

=cut

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = {};
    bless $self, $class;
    ( $self->{'_string'}, $self->{'_type'}, $self->{'_lc'}, $self->{'_path'} ) = @_;
    return $self;
}

=head2 string

Missing POD for string.

=cut

sub string {
    my $this = shift;
    return $this->{'_string'};
}

=head2 type

Missing POD for type.

=cut

sub type {
    my $this = shift;
    return $this->{'_type'};
}

=head2 pathname

Missing POD for pathname.

=cut

sub pathname {
    my $this = shift;
    return $this->{'_path'};
}

=head2 line_number

Missing POD for line_number.

=cut

sub line_number {
    my $this = shift;
    return $this->{'_lc'};
}

=head2 attributes

Missing POD for attributes.

=cut

sub attributes {
    my $this = shift;
    return $this->{'_attr'};
}

=head2 set_attributes

Missing POD for set_attributes.

=cut

sub set_attributes {
    my $this = shift;
    $this->{'_attr'} = ref $_[0] eq 'HASH' ? $_[0] : \@_;
    return $this;
}

# only meaningful for TEXT_PARAMETRIZED tokens

=head2 children

Missing POD for children.

=cut

sub children {
    my $this = shift;
    return $this->{'_kids'};
}

# only meaningful for TEXT_PARAMETRIZED tokens

=head2 set_children

Missing POD for set_children.

=cut

sub set_children {
    my $this = shift;
    $this->{'_kids'} = ref $_[0] eq 'ARRAY' ? $_[0] : \@_;
    return $this;
}

# only meaningful for TEXT_PARAMETRIZED tokens
# FIXME: DIRECTIVE is not necessarily TMPL_VAR !!

=head2 parameters_and_fields

Missing POD for parameters_and_fields.

=cut

sub parameters_and_fields {
    my $this = shift;
    return map {
        $_->type == C4::TmplTokenType::DIRECTIVE() ? $_
            : (    $_->type == C4::TmplTokenType::TAG
                && $_->string =~ /^<input\b/is ) ? $_
            : ()
    } @{ $this->{'_kids'} };
}

# only meaningful for TEXT_PARAMETRIZED tokens

=head2 anchors

Missing POD for anchors.

=cut

sub anchors {
    my $this = shift;
    return map { $_->type == C4::TmplTokenType::TAG && $_->string =~ /^<a\b/is ? $_ : () } @{ $this->{'_kids'} };
}

# only meaningful for TEXT_PARAMETRIZED tokens

=head2 form

Missing POD for form.

=cut

sub form {
    my $this = shift;
    return $this->{'_form'};
}

# only meaningful for TEXT_PARAMETRIZED tokens

=head2 set_form

Missing POD for set_form.

=cut

sub set_form {
    my $this = shift;
    $this->{'_form'} = $_[0];
    return $this;
}

=head2 has_js_data

Missing POD for has_js_data.

=cut

sub has_js_data {
    my $this = shift;
    return defined $this->{'_js_data'} && ref( $this->{'_js_data'} ) eq 'ARRAY';
}

=head2 js_data

Missing POD for js_data.

=cut

sub js_data {
    my $this = shift;
    return $this->{'_js_data'};
}

=head2 set_js_data

Missing POD for set_js_data.

=cut

sub set_js_data {
    my $this = shift;
    $this->{'_js_data'} = $_[0];
    return $this;
}

# predefined tests

=head2 tag_p

Missing POD for tag_p.

=cut

sub tag_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::TAG;
}

=head2 cdata_p

Missing POD for cdata_p.

=cut

sub cdata_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::CDATA;
}

=head2 text_p

Missing POD for text_p.

=cut

sub text_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::TEXT;
}

=head2 text_parametrized_p

Missing POD for text_parametrized_p.

=cut

sub text_parametrized_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::TEXT_PARAMETRIZED;
}

=head2 directive_p

Missing POD for directive_p.

=cut

sub directive_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::DIRECTIVE;
}

###############################################################################

1;
