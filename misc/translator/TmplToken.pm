package TmplToken;

use strict;
use TmplTokenType;
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

###############################################################################

1;
