package C4::TmplToken;

use strict;
#use warnings; FIXME - Bug 2505
use C4::TmplTokenType;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

###############################################################################

=head1 NAME

TmplToken.pm - Object representing a scanner token for .tmpl files

=head1 DESCRIPTION

This is a class representing a token scanned from an HTML::Template .tmpl file.

=cut

###############################################################################

$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT_OK = qw();

###############################################################################

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
