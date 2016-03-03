package C4::Labels::Template;

use strict;
use warnings;

use base qw(C4::Creators::Template);

use autouse 'Data::Dumper' => qw(Dumper);

BEGIN {
}

use constant TEMPLATE_TABLE => 'creator_templates';

__PACKAGE__ =~ m/^C4::(.+)::.+$/;
my $me = $1;

sub new {
    my $self = shift;
    push @_, "creator", $me;
    return $self->SUPER::new(@_);
}

sub retrieve {
    my $self = shift;
    push @_, "table_name", TEMPLATE_TABLE, "creator", $me;
    return $self->SUPER::retrieve(@_);
}

sub delete {
    my $self = shift;
    push @_, "table_name", TEMPLATE_TABLE, "creator", $me;
    return $self->SUPER::delete(@_);
}

sub save {
    my $self = shift;
    push @_, "table_name", TEMPLATE_TABLE, "creator", $me;
    return $self->SUPER::save(@_);
}

1;
