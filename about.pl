#!/usr/bin/perl
 
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;

use C4::Output;    # contains gettemplate
use C4::Auth;
use C4::Context;
use CGI;
use LWP::Simple;
use XML::Simple;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "about.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1 },
        debug           => 1,
    }
);

my $kohaVersion   = C4::Context->config("kohaversion");
my $osVersion     = `uname -a`;
my $perlVersion   = $];
my $mysqlVersion  = `mysql -V`;
my $apacheVersion = `httpd -v`;
$apacheVersion = `httpd2 -v` unless $apacheVersion;
my $zebraVersion = `zebraidx -V`;

# $apacheVersion =  (`/usr/sbin/apache2 -V`)[0];

$template->param(
    kohaVersion   => $kohaVersion,
    osVersion     => $osVersion,
    perlVersion   => $perlVersion,
    mysqlVersion  => $mysqlVersion,
    apacheVersion => $apacheVersion,
    zebraVersion  => $zebraVersion,
);
my @component_names =
    qw/MARC::File::XML   MARC::Charset     Class::Accessor
       LWP::Simple       XML::Simple       Net::Z3950
       Event             Net::LDAP         PDF::API2
       Mail::Sendmail    MARC::Record      Digest::MD5
       HTML::Template    DBD::mysql        Date::Manip
       DBI               Net::Z3950::ZOOM
       Date::Calc
      /;

my @components = ();

foreach my $component ( sort @component_names ) {
    my $version;
    if ( eval "require $component" ) {
        $version = $component->VERSION;
        if ( $version eq '' ) {
            $version = 'unknown';
        }
    }
    else {
        $version = 'module is missing';
    }

    push(
        @components,
        {
            name    => $component,
            version => $version,
        }
    );
}

$template->param( components => \@components );

output_html_with_http_headers $query, $cookie, $template->output;
