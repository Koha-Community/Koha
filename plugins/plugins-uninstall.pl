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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Archive::Extract;
use CGI qw ( -utf8 );

use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output;
use C4::Members;
use Koha::Plugins::Handler;

die("Koha plugins are disabled!") unless C4::Context->config("enable_plugins");

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "plugins/plugins-upload.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { plugins => 'manage' },
    }
);

my $class = $input->param('class');

if ($class) {
    Koha::Plugins::Handler->delete( { class => $class } );
}

print $input->redirect("/cgi-bin/koha/plugins/plugins-home.pl");
