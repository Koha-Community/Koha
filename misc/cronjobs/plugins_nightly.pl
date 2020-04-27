#!/usr/bin/perl

use Modern::Perl;

use Koha::Logger;
use Koha::Script -cron;

cronlogaction();

my $logger = Koha::Logger->get();
if ( C4::Context->config("enable_plugins") ) {
    my @plugins = Koha::Plugins->new->GetPlugins(
        {
            method => 'cronjob_nightly',
        }
    );

    foreach my $plugin (@plugins) {
        try {
            $plugin->cronjob_nightly();
        }
        catch {
            warn "$_";
            $logger->warn("$_");
        };
    }
}

=head1 NAME

plugins_nightly.pl - Run nightly tasks specified by plugins

=head1 SYNOPSIS

plugins_nightly.pl

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut
