package TmplTokenType;

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

###############################################################################

=head1 NAME

TmplTokenType.pm - Types of TmplToken objects

=head1 DESCRIPTION

This is a Java-style "safe enum" singleton class for types of TmplToken objects.

=cut

###############################################################################

$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT_OK = qw(
    &TEXT
    &CDATA
    &TAG
    &DECL
    &PI
    &DIRECTIVE
    &COMMENT
    &UNKNOWN
);

###############################################################################

use vars qw( $_text $_cdata $_tag $_decl $_pi $_directive $_comment $_unknown );

BEGIN {
    my $new = sub {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = {};
	bless $self, $class;
	($self->{'id'}, $self->{'name'}, $self->{'desc'}) = @_;
	return $self;
    };
    $_text	= &$new(0, 'TEXT');
    $_cdata	= &$new(1, 'CDATA');
    $_tag	= &$new(2, 'TAG');
    $_decl	= &$new(3, 'DECL');
    $_pi	= &$new(4, 'PI');
    $_directive	= &$new(5, 'DIRECTIVE');
    $_comment	= &$new(6, 'COMMENT');
    $_unknown	= &$new(7, 'UNKNOWN');
}

sub to_string {
    my $this = shift;
    return $this->{'name'}
}

sub TEXT	() { $_text }
sub CDATA	() { $_cdata }
sub TAG		() { $_tag }
sub DECL	() { $_decl }
sub PI		() { $_pi }
sub DIRECTIVE	() { $_directive }
sub COMMENT	() { $_comment }
sub UNKNOWN	() { $_unknown }

###############################################################################

1;
