use strict;
use warnings;

package HTML::FromANSI::Tiny::Bootstrap;

use parent qw(HTML::FromANSI::Tiny);

=head1 NAME

HTML::FromANSI::Tiny::Bootstrap - Convert ANSI colored text to HTML with Bootstrap classes

=head1 DESCRIPTION

HTML::FromANSI::Tiny::Bootstrap is a module that extends HTML::FromANSI::Tiny to convert ANSI colored text to HTML with Bootstrap classes. It provides a mapping between ANSI color attributes and Bootstrap classes.

=cut

our %ATTR_TO_CLASS = (
    black      => 'text-primary',
    red        => 'text-danger',
    green      => 'text-success',
    yellow     => 'text-warning',
    blue       => 'text-info',
    magenta    => '',
    cyan       => '',
    white      => 'text-muted',
    on_black   => 'bg-primary',
    on_red     => 'bg-danger',
    on_green   => 'bg-success',
    on_yellow  => 'bg-warning',
    on_blue    => 'bg-info',
    on_magenta => '',
    on_cyan    => '',
    on_white   => '',
);

=head1 METHODS

=head2 attr_to_class($attr)

Converts an ANSI color attribute to the corresponding Bootstrap class.

=cut

sub attr_to_class {
    $ATTR_TO_CLASS{ $_[1] } || $_[1];
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
