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
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
use warnings;
use C4::TmplTokenType;

=head1 NAME

TmplToken.pm - Object representing a scanner token for .tmpl files

=head1 DESCRIPTION

This is a class representing a token scanned from an HTML::Template .tmpl file.

=cut

our $VERSION = 3.07.00.049;


sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    ($self->{'_string'}, $self->{'_type'}, $self->{'_lc'}, $self->{'_path'}) = @_;
    return $self;
}

sub string {
    my $this = shift;
    return $this->{'_string'}
}

sub type {
    my $this = shift;
    return $this->{'_type'}
}

sub pathname {
    my $this = shift;
    return $this->{'_path'}
}

sub line_number {
    my $this = shift;
    return $this->{'_lc'}
}

sub attributes {
    my $this = shift;
    return $this->{'_attr'};
}

sub set_attributes {
    my $this = shift;
    $this->{'_attr'} = ref $_[0] eq 'HASH'? $_[0]: \@_;
    return $this;
}

# only meaningful for TEXT_PARAMETRIZED tokens
sub children {
    my $this = shift;
    return $this->{'_kids'};
}

# only meaningful for TEXT_PARAMETRIZED tokens
sub set_children {
    my $this = shift;
    $this->{'_kids'} = ref $_[0] eq 'ARRAY'? $_[0]: \@_;
    return $this;
}

# only meaningful for TEXT_PARAMETRIZED tokens
# FIXME: DIRECTIVE is not necessarily TMPL_VAR !!
sub parameters_and_fields {
    my $this = shift;
    return map { $_->type == C4::TmplTokenType::DIRECTIVE? $_:
		($_->type == C4::TmplTokenType::TAG
			&& $_->string =~ /^<input\b/is)? $_: ()}
	    @{$this->{'_kids'}};
}

# only meaningful for TEXT_PARAMETRIZED tokens
sub anchors {
    my $this = shift;
    return map { $_->type == C4::TmplTokenType::TAG && $_->string =~ /^<a\b/is? $_: ()} @{$this->{'_kids'}};
}

# only meaningful for TEXT_PARAMETRIZED tokens
sub form {
    my $this = shift;
    return $this->{'_form'};
}

# only meaningful for TEXT_PARAMETRIZED tokens
sub set_form {
    my $this = shift;
    $this->{'_form'} = $_[0];
    return $this;
}

sub has_js_data {
    my $this = shift;
    return defined $this->{'_js_data'} && ref($this->{'_js_data'}) eq 'ARRAY';
}

sub js_data {
    my $this = shift;
    return $this->{'_js_data'};
}

sub set_js_data {
    my $this = shift;
    $this->{'_js_data'} = $_[0];
    return $this;
}

# predefined tests

sub tag_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::TAG;
}

sub cdata_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::CDATA;
}

sub text_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::TEXT;
}

sub text_parametrized_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::TEXT_PARAMETRIZED;
}

sub directive_p {
    my $this = shift;
    return $this->type == C4::TmplTokenType::DIRECTIVE;
}

###############################################################################

1;
