package t::lib::WebDriverFactory;

# Copyright 2015 Open Source Freedom Fighters
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

use Modern::Perl;

use Koha::Exception::VersionMismatch;
use Koha::Exception::UnknownProgramState;

=head NAME t::lib::WebDriverFactory

=head SYNOPSIS

This Factory is responsible for creating all WebTesters/WebDrivers supported by Koha.

=cut

=head getUserAgentDrivers

    my ($phantomjs)      = t::lib::WebDriverFactory::getUserAgentDrivers('phantomjs');
    my ($phantomjs, $ff) = t::lib::WebDriverFactory::getUserAgentDrivers(['phantomjs', 'firefox']);
    my ($firefox)        = t::lib::WebDriverFactory::getUserAgentDrivers({firefox => { version => '39.0', platform => 'LINUX' }});
    my ($ff1, $ff2)      = t::lib::WebDriverFactory::getUserAgentDrivers({firefox1 => { version => '39.0', platform => 'LINUX' },
                                                                          firefox2 => { version => '38.0', platform => 'WINDOWS' }, #yuck...
                                                                        });

Test Driver factory-method to get various web-userAgents.
This is a direct wrapper for Selenium::Remote::Driver->new(), check the valid parameters from it's perldoc.

Default configuration:
{
    javascript       => 1,     #Javascript is enabled Selenium::Remote::Driver-based UserAgents.
    accept_ssl_certs => 1,     #Accept self-signed ssl-certificates
    default_finder   => 'css', #Use css as the default HTML element finder instead of xpath.
                               #css is selected because Test::Mojo uses it and it is generally more widely used.
}

Valid userAgent names:
    'phantomjs',  is a headless browser which can be ran as standalone without an installed
                  GUI( like X-server ), this is recommended for test servers.
                  See Selenium::PhantomJS for installation instructions.
    'firefox',    launches a Firefox-instance to run the automated tests.
                  See Selenium::Firefox for installation instructions.
    'mojolicious' is the Test::Mojo-test userAgent used to test Mojolicious framework routes.
                  Is installed with the Mojolicius framework.
                  No accepted configuration parameters at this time.
                  You can give the 'version', but we default to the only version we currently have, 'V1'.

@PARAM1 String, the name of the userAgent requested with default config, eg. 'selenium' or 'firefox'
@RETURNS List of, the requested Selenium::Remote::Driver-implementation, eg. Selenium::PhantomJS
@OR
@PARAM1 ARRAYRef, names of the userAgents requested with default config
@RETURNS List of, the requested Selenium::Remote::Driver-implementations
@OR
@PARAM1 HASHRef, names of the userAgents requested as HASH keys, keys must start with
                 the desired userAgent-implementation name and be suffixed with an identifier
                 so the keys don't conflict with each other.
                 UserAgent keys correspond to HASHRefs of extra configuration parameters for
                 Selenium::Remote::Driver->new()
@RETURNS List of, the requested Selenium::Remote::Driver-implementations

@THROWS Koha::Exception::UnknownProgramState, see _getTestMojoDriver()
@THROWS Koha::Exception::VersionMismatch, see _getTestMojoDriver()
=cut

sub getUserAgentDrivers {
    my ($requestedUserAgents) = @_;

    my $requestedUserAgentNames;
    if( ref($requestedUserAgents) eq 'HASH' ) {
        $requestedUserAgentNames = [keys(%$requestedUserAgents)];
    }
    elsif ( ref($requestedUserAgents) eq 'ARRAY' ) {
        $requestedUserAgentNames = $requestedUserAgents;
    }
    else {
        $requestedUserAgentNames = [$requestedUserAgents];
    }

    ##Collect the user agents requested for.
    #Find out if the $requestedUserAgents-parameters contain a configuration
    #HASH for all/some of the requested user agents, and merge that over the
    #default configuration values for each user agent.
    #For some reason the Selenium constructors want HASHes in List-context?
    my @userAgents;
    foreach my $reqUAName (@$requestedUserAgentNames) {
        my $reqUAConf = $requestedUserAgents->{$reqUAName} if ref($requestedUserAgents) eq 'HASH';

        if ($reqUAName =~ /^phantomjs/) {
            require Selenium::PhantomJS;
            my $defaultConf = {
                                javascript         => 1,
                                accept_ssl_certs   => 1,
                                default_finder     => 'css',
            };
            @$defaultConf{keys %$reqUAConf} = values %$reqUAConf if ref($reqUAConf) eq 'HASH';

            my @hashInListContext = %$defaultConf;
            push @userAgents, Selenium::PhantomJS->new(@hashInListContext);
        }
        elsif ($reqUAName =~ /^firefox/) {
            require Selenium::Firefox;
            my $defaultConf = {
                                javascript         => 1,
                                accept_ssl_certs   => 1,
                                default_finder     => 'css',
            };
            @$defaultConf{keys %$reqUAConf} = values %$reqUAConf if ref($reqUAConf) eq 'HASH';

            my @hashInListContext = %$defaultConf;
            push @userAgents, Selenium::Firefox->new(@hashInListContext);
        }
        elsif ($reqUAName =~ /^mojolicious/) {
            my $defaultConf = {
                                version => 'V1',
            };
            @$defaultConf{keys %$reqUAConf} = values %$reqUAConf if ref($reqUAConf) eq 'HASH';

            push @userAgents, _getTestMojoDriver($defaultConf);
        }
    }

    return @userAgents;
}

=head _getTestMojoDriver

@THROWS Koha::Exception::UnknownProgramState, if Test::Mojo doesn't die out of failure, but we get no Test Driver.
@THROWS Koha::Exception::VersionMismatch, if we try to get an unsupported API version test driver.
=cut
sub _getTestMojoDriver {
    require Test::Mojo;
    my ($config) = @_;

    if ((uc($config->{version}) eq 'V1') || not(exists($config->{version}))) { #Default to V1
        $ENV{MOJO_LOGFILES} = $ENV{MOJO_LOGFILES} || undef;
        $ENV{MOJO_CONFIG} = $ENV{MOJO_CONFIG} || undef;
        my $mojoDriver = Test::Mojo->new('Koha::REST::V1');
        $mojoDriver->ua->inactivity_timeout(40);
        $mojoDriver->ua->max_connections(0);
        return $mojoDriver if $mojoDriver;
        Koha::Exception::UnknownProgramState->throw(error => "WebDriverFactory::_getTestMojoDriver():> Unexpected exception.");
    }
    else {
        Koha::Exception::VersionMismatch->throw(error => "WebDriverFactory::_getTestMojoDriver():> Unknown version, supported version 'V1'");
    }
}

1; #Make the compiler happy!
