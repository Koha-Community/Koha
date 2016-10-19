#!/usr/bin/perl
package Koha::Vetuma::Logger;

use Sys::Syslog qw(syslog);
use Moose;

sub log{
    my $self = shift;
    my $message = $_[0];
    syslog("LOG_DEBUG", $message);
}

1;
