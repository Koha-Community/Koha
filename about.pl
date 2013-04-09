#!/usr/bin/perl

# Copyright Pat Eyler 2003
# Copyright Biblibre 2006
# Parts Copyright Liblime 2008
# Parts Copyright Chris Nighswonger 2010
#
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use LWP::Simple;
use XML::Simple;
use Config;

use C4::Output;
use C4::Auth;
use C4::Context;
use C4::Installer;

#use Smart::Comments '####';

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "about.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $kohaVersion   = C4::Context::KOHAVERSION;
my $osVersion     = `uname -a`;
my $perl_path = $^X;
if ($^O ne 'VMS') {
    $perl_path .= $Config{_exe} unless $perl_path =~ m/$Config{_exe}$/i;
}
my $perlVersion   = $];
my $mysqlVersion  = `mysql -V`;
my $apacheVersion = `httpd -v 2> /dev/null`;
$apacheVersion = `httpd2 -v 2> /dev/null` unless $apacheVersion;
$apacheVersion = (`/usr/sbin/apache2 -V`)[0] unless $apacheVersion;
my $zebraVersion = `zebraidx -V`;

# Additional system information for warnings
my $prefAutoCreateAuthorities = C4::Context->preference('AutoCreateAuthorities');
my $prefBiblioAddsAuthorities = C4::Context->preference('BiblioAddsAuthorities');
my $warnPrefBiblioAddsAuthorities = ( $prefAutoCreateAuthorities && ( !$prefBiblioAddsAuthorities) );

my $prefEasyAnalyticalRecords  = C4::Context->preference('EasyAnalyticalRecords');
my $prefUseControlNumber  = C4::Context->preference('UseControlNumber');
my $warnPrefEasyAnalyticalRecords  = ( $prefEasyAnalyticalRecords  && $prefUseControlNumber );
my $warnPrefAnonymousPatron = (
    C4::Context->preference('OPACPrivacy')
        and not C4::Context->preference('AnonymousPatron')
);

my $errZebraConnection = C4::Context->Zconn("biblioserver",0)->errcode();

my $warnIsRootUser   = (! $loggedinuser);

$template->param(
    kohaVersion   => $kohaVersion,
    osVersion     => $osVersion,
    perlPath      => $perl_path,
    perlVersion   => $perlVersion,
    perlIncPath   => [ map { perlinc => $_ }, @INC ],
    mysqlVersion  => $mysqlVersion,
    apacheVersion => $apacheVersion,
    zebraVersion  => $zebraVersion,
    prefBiblioAddsAuthorities => $prefBiblioAddsAuthorities,
    prefAutoCreateAuthorities => $prefAutoCreateAuthorities,
    warnPrefBiblioAddsAuthorities => $warnPrefBiblioAddsAuthorities,
    warnPrefEasyAnalyticalRecords  => $warnPrefEasyAnalyticalRecords,
    warnPrefAnonymousPatron => $warnPrefAnonymousPatron,
    errZebraConnection => $errZebraConnection,
    warnIsRootUser => $warnIsRootUser,
);

my @components = ();

my $perl_modules = C4::Installer::PerlModules->new;
$perl_modules->version_info;

my @pm_types = qw(missing_pm upgrade_pm current_pm);

foreach my $pm_type(@pm_types) {
    my $modules = $perl_modules->get_attr($pm_type);
    foreach (@$modules) {
        my ($module, $stats) = each %$_;
        push(
            @components,
            {
                name    => $module,
                version => $stats->{'cur_ver'},
                missing => ($pm_type eq 'missing_pm' ? 1 : 0),
                upgrade => ($pm_type eq 'upgrade_pm' ? 1 : 0),
                current => ($pm_type eq 'current_pm' ? 1 : 0),
                require => $stats->{'required'},
            }
        );
    }
}

@components = sort {$a->{'name'} cmp $b->{'name'}} @components;

my $counter=0;
my $row = [];
my $table = [];
foreach (@components) {
    push (@$row, $_);
    unless (++$counter % 4) {
        push (@$table, {row => $row});
        $row = [];
    }
}
# Processing the last line (if there are any modules left)
if (scalar(@$row) > 0) {
    # Extending $row to the table size
    $$row[3] = '';
    # Pushing the last line
    push (@$table, {row => $row});
}
## ## $table

$template->param( table => $table );


## ------------------------------------------
## Koha time line code

#get file location
my $dir = C4::Context->config('intranetdir');
open( my $file, "<", "$dir" . "/docs/history.txt" );
my $i = 0;

my @rows2 = ();
my $row2  = [];

my @lines = <$file>;
close($file);

shift @lines; #remove header row

foreach (@lines) {
    my ( $date, $desc, $tag ) = split(/\t/);
    if(!$desc && $date=~ /(?<=\d{4})\s+/) {
        ($date, $desc)= ($`, $');
    }
    push(
        @rows2,
        {
            date => $date,
            desc => $desc,
        }
    );
}

my $table2 = [];
#foreach my $row2 (@rows2) {
foreach  (@rows2) {
    push (@$row2, $_);
    push( @$table2, { row2 => $row2 } );
    $row2 = [];
}

$template->param( table2 => $table2 );

output_html_with_http_headers $query, $cookie, $template->output;
