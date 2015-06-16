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

    if ( exists $ENV{"LOG4PERL_CONF"} and $ENV{'LOG4PERL_CONF'} and -s $ENV{"LOG4PERL_CONF"} ) {
        # Check for web server level configuration first
        Log::Log4perl->init_once( $ENV{"LOG4PERL_CONF"} );
    }
    elsif ( C4::Context->config("log4perl_conf") ) {
        # If no web server level config exists, look in the koha conf file for one
        Log::Log4perl->init_once( C4::Context->config("log4perl_conf") );
    } else {
        my $logdir = C4::Context->config("logdir");
        my $conf = qq(
            log4perl.logger.intranet = WARN, INTRANET
            log4perl.appender.INTRANET=Log::Log4perl::Appender::File
            log4perl.appender.INTRANET.filename=$logdir/intranet-error.log
            log4perl.appender.INTRANET.mode=append
            log4perl.appender.INTRANET.layout=PatternLayout
            log4perl.appender.INTRANET.layout.ConversionPattern=[%d] [%p] %m %l %n

            log4perl.logger.opac = WARN, OPAC
            log4perl.appender.OPAC=Log::Log4perl::Appender::File
            log4perl.appender.OPAC.filename=$logdir/opac-error.log
            log4perl.appender.OPAC.mode=append
            log4perl.appender.OPAC.layout=PatternLayout
            log4perl.appender.OPAC.layout.ConversionPattern=[%d] [%p] %m %l %n
        );
        Log::Log4perl->init_once(\$conf);
    }
}

=head2 get

    Returns a log4perl object.
    Category and interface parameter are optional.
    Normally, the category should follow the current package and the interface
    should be set correctly via C4::Context.

=cut

sub get {
    my ( $class, $category, $interface ) = @_;
    $interface ||= C4::Context->interface();
    $category = caller if !$category;
    return Log::Log4perl->get_logger( $interface. '.'. $category );
}

=head1 AUTHOR

Kyle M Hall, E<lt>kyle@bywatersolutions.comE<gt>

=cut

1;

__END__
