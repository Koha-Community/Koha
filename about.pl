#!/usr/bin/perl

# Copyright Pat Eyler 2003
# Copyright Biblibre 2006
# Parts Copyright Liblime 2008
# Parts Copyright Chris Nighswonger 2010
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
        template_name   => "about.tt",
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

my $warnNoActiveCurrency = (! defined C4::Budgets->GetCurrency());
my @xml_config_warnings;

my $context = new C4::Context;

if ( ! defined C4::Context->config('zebra_bib_index_mode') ) {
    push @xml_config_warnings, {
        error => 'zebra_bib_index_mode_warn'
    };
    if ($context->{'server'}->{'biblioserver'}->{'config'} !~ /zebra-biblios-dom.cfg/) {
        push @xml_config_warnings, {
            error => 'zebra_bib_mode_seems_grs1'
        };
    }
    else {
        push @xml_config_warnings, {
            error => 'zebra_bib_mode_seems_dom'
        };
    }
} else {
    push @xml_config_warnings, { error => 'zebra_bib_grs_warn' }
        if C4::Context->config('zebra_bib_index_mode') eq 'grs1';
}

if ( (C4::Context->config('zebra_bib_index_mode') eq 'dom') && ($context->{'server'}->{'biblioserver'}->{'config'} !~ /zebra-biblios-dom.cfg/) ) {
    push @xml_config_warnings, {
        error => 'zebra_bib_index_mode_mismatch_warn'
    };
}

if ( (C4::Context->config('zebra_auth_index_mode') eq 'grs1') && ($context->{'server'}->{'biblioserver'}->{'config'} =~ /zebra-biblios-dom.cfg/) ) {
    push @xml_config_warnings, {
        error => 'zebra_bib_index_mode_mismatch_warn'
    };
}

if ( ! defined C4::Context->config('zebra_auth_index_mode') ) {
    push @xml_config_warnings, {
        error => 'zebra_auth_index_mode_warn'
    };
    if ($context->{'server'}->{'authorityserver'}->{'config'} !~ /zebra-authorities-dom.cfg/) {
        push @xml_config_warnings, {
            error => 'zebra_auth_mode_seems_grs1'
        };
    }
    else {
        push @xml_config_warnings, {
            error => 'zebra_auth_mode_seems_dom'
        };
    }
} else {
    push @xml_config_warnings, { error => 'zebra_auth_grs_warn' }
        if C4::Context->config('zebra_auth_index_mode') eq 'grs1';
}

if ( (C4::Context->config('zebra_auth_index_mode') eq 'dom') && ($context->{'server'}->{'authorityserver'}->{'config'} !~ /zebra-authorities-dom.cfg/) ) {
    push @xml_config_warnings, {
        error => 'zebra_auth_index_mode_mismatch_warn'
    };
}

if ( (C4::Context->config('zebra_auth_index_mode') eq 'grs1') && ($context->{'server'}->{'authorityserver'}->{'config'} =~ /zebra-authorities-dom.cfg/) ) {
    push @xml_config_warnings, {
        error => 'zebra_auth_index_mode_mismatch_warn'
    };
}

# Test QueryParser configuration sanity
if ( C4::Context->preference( 'UseQueryParser' ) ) {
    # Get the QueryParser configuration file name
    my $queryparser_file          = C4::Context->config( 'queryparser_config' );
    my $queryparser_fallback_file = '/etc/koha/searchengine/queryparser.yaml';
    # Check QueryParser is functional
    my $QParser = C4::Context->queryparser();
    my $queryparser_error = {};
    if ( ! defined $QParser || ref($QParser) ne 'Koha::QueryParser::Driver::PQF' ) {
        # Error initializing the QueryParser object
        # Get the used queryparser.yaml file path to report the user
        $queryparser_error->{ fallback } = ( defined $queryparser_file ) ? 0 : 1;
        $queryparser_error->{ file }     = ( defined $queryparser_file )
                                                ? $queryparser_file
                                                : $queryparser_fallback_file;
        # Report error data to the template
        $template->param( QueryParserError => $queryparser_error );
    } else {
        # Check for an absent queryparser_config entry in koha-conf.xml
        if ( ! defined $queryparser_file ) {
            # Not an error but a warning for the missing entry in koha-conf-xml
            push @xml_config_warnings, {
                    error => 'queryparser_entry_missing',
                    file  => $queryparser_fallback_file
            };
        }
    }
}

# Test Zebra facets configuration
if ( !defined C4::Context->config('use_zebra_facets') ) {
    push @xml_config_warnings, { error => 'use_zebra_facets_entry_missing' };
} else {
    if ( C4::Context->config('use_zebra_facets') &&
         C4::Context->config('zebra_bib_index_mode') ) {
        # use_zebra_facets works with DOM
        push @xml_config_warnings, {
            error => 'use_zebra_facets_needs_dom'
        } if C4::Context->config('zebra_bib_index_mode') ne 'dom' ;
    }
}

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
    warnNoActiveCurrency => $warnNoActiveCurrency,
    xml_config_warnings => \@xml_config_warnings,
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
                reqversion => $stats->{'min_ver'},
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
my $docdir;
if ( defined C4::Context->config('docdir') ) {
    $docdir = C4::Context->config('docdir');
} else {
    # if no <docdir> is defined in koha-conf.xml, use the default location
    # this is a work-around to stop breakage on upgraded Kohas, bug 8911
    $docdir = C4::Context->config('intranetdir') . '/docs';
}

if ( open( my $file, "<:encoding(UTF-8)", "$docdir" . "/history.txt" ) ) {

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
} else {
    $template->param( timeline_read_error => 1 );
}

output_html_with_http_headers $query, $cookie, $template->output;
