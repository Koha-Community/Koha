package Koha::Logger;

# Copyright 2015 ByWater Solutions
# kyle@bywatersolutions.com
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::Log

=head1 SYNOPSIS

  use Koha::Log;

=head1 FUNCTIONS

=cut

use Modern::Perl;

use Log::Log4perl;
use Carp;

use C4::Context;

BEGIN {
    Log::Log4perl->wrapper_register(__PACKAGE__);

    my $conf;
    if ( exists $ENV{"LOG4PERL_CONF"} and $ENV{'LOG4PERL_CONF'} and -s $ENV{"LOG4PERL_CONF"} ) {

        # Check for web server level configuration first
        $conf = $ENV{"LOG4PERL_CONF"};
    }
    else {
        # If no web server level config exists, look in the koha conf file for one
        $conf = C4::Context->config("log4perl_conf");
    }

    Log::Log4perl->init_once($conf);
}

sub get {
    my ( $class, $category, $interface ) = @_;

    croak("No category passed in!") unless $category;

    $interface ||= C4::Context->interface();

    return Log::Log4perl->get_logger("$interface.$category");
}

=head1 AUTHOR

Kyle M Hall, E<lt>kyle@bywatersolutions.comE<gt>

=cut

1;

__END__
