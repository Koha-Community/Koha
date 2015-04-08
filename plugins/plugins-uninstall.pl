#!/usr/bin/perl
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

use strict;
use warnings;

use Archive::Extract;
use File::Temp;
use File::Copy;
use CGI;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Debug;
use Koha::Plugins::Handler;

die("Koha plugins are disabled!")
  unless C4::Context->preference('UseKohaPlugins');

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "plugins/plugins-upload.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { plugins => 'manage' },
        debug           => 1,
    }
);

my $class = $input->param('class');

Koha::Plugins::Handler->delete( { class => $class } );

print $input->redirect("/cgi-bin/koha/plugins/plugins-home.pl");
