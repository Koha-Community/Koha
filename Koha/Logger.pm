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
}

=head2 get

    Returns a logger object (based on log4perl).
    Category and interface hash parameter are optional.
    Normally, the category should follow the current package and the interface
    should be set correctly via C4::Context.

=cut

sub get {
    my ( $class, $params ) = @_;
    my $interface = $params ? ( $params->{interface} || C4::Context->interface ) : C4::Context->interface;
    my $category = $params ? ( $params->{category} || caller ) : caller;
    my $l4pcat = $interface . '.' . $category;

    my $init = _init();
    my $self = {};
    if ($init) {
        $self->{logger} = Log::Log4perl->get_logger($l4pcat);
        $self->{cat}    = $l4pcat;
        $self->{logs}   = $init if ref $init;
    }
    bless $self, $class;
    return $self;
}

=head1 INTERNALS

=head2 AUTOLOAD

    In order to prevent a crash when log4perl cannot write to Koha logfile,
    we check first before calling log4perl.
    If log4perl would add such a check, this would no longer be needed.

=cut

sub AUTOLOAD {
    my ( $self, $line ) = @_;
    my $method = $Koha::Logger::AUTOLOAD;
    $method =~ s/^Koha::Logger:://;

    if ( !exists $self->{logger} ) {

        #do not use log4perl; no print to stderr
    }
    elsif ( !$self->_recheck_logfile ) {
        warn "Log file not writable for log4perl";
        warn "$method: $line" if $line;
    }
    elsif ( $self->{logger}->can($method) ) {    #use log4perl
        $self->{logger}->$method($line);
        return 1;
    }
    else {                                       # we should not really get here
        warn "ERROR: Unsupported method $method";
    }
    return;
}

=head2 DESTROY

    Dummy destroy to prevent call to AUTOLOAD

=cut

sub DESTROY { }

=head2 _init, _check_conf and _recheck_logfile

=cut

sub _init {
    my $rv;
    if ( exists $ENV{"LOG4PERL_CONF"} and $ENV{'LOG4PERL_CONF'} and -s $ENV{"LOG4PERL_CONF"} ) {

        # Check for web server level configuration first
        # In this case we ASSUME that you correctly arranged logfile
        # permissions. If not, log4perl will crash on you.
        # We will not parse apache files here.
        Log::Log4perl->init_once( $ENV{"LOG4PERL_CONF"} );
    }
    elsif ( C4::Context->config("log4perl_conf") ) {

        # Now look in the koha conf file. We only check the permissions of
        # the default logfiles. For the rest, we again ASSUME that
        # you arranged file permissions.
        my $conf = C4::Context->config("log4perl_conf");
        if ( $rv = _check_conf($conf) ) {
            Log::Log4perl->init_once($conf);
            return $rv;
        }
        else {
            return 0;
        }
    }
    else {
        # This means that you do not use log4perl currently.
        # We will not be forcing it.
        return 0;
    }
    return 1;    # if we make it here, log4perl did not crash :)
}

sub _check_conf {    # check logfiles in log4perl config (at initialization)
    my $file = shift;
    return if !-r $file;
    open my $fh, '<', $file;
    my @lines = <$fh>;
    close $fh;
    my @logs;
    foreach my $l (@lines) {
        if ( $l =~ /(OPAC|INTRANET)\.filename\s*=\s*(.*)\s*$/i ) {

            # we only check the two default logfiles, skipping additional ones
            return if !-w $2;
            push @logs, $1 . ':' . $2;
        }
    }
    return if !@logs;    # we should find one
    return \@logs;
}

sub _recheck_logfile {    # recheck saved logfile when logging message
    my $self = shift;

    return 1 if !exists $self->{logs};    # remember? your own responsibility
    my $opac = $self->{cat} =~ /^OPAC/;
    my $log;
    foreach ( @{ $self->{logs} } ) {
        $log = $_ if $opac && /^OPAC:/ || !$opac && /^INTRANET:/;
        last if $log;
    }
    $log =~ s/^(OPAC|INTRANET)://;
    return -w $log;
}

=head1 AUTHOR

Kyle M Hall, E<lt>kyle@bywatersolutions.comE<gt>
Marcel de Rooy, Rijksmuseum

=cut

1;

__END__
