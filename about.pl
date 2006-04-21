#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
use C4::Database;
use C4::Output;  # contains gettemplate
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Context;
use CGI;
use LWP::Simple;
use XML::Simple;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "about.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $kohaVersion = C4::Context->config("kohaversion");
my $osVersion = `uname -a`;
my $perlVersion = $];
my $mysqlVersion = `mysql -V`;
my $apacheVersion =  `httpd -v`;
$apacheVersion =  `httpd2 -v` unless $apacheVersion;
my $zebraVersion = `zebraidx -V`;
# $apacheVersion =  (`/usr/sbin/apache2 -V`)[0];

$template->param(
					kohaVersion => $kohaVersion,
					osVersion          => $osVersion,
					perlVersion        => $perlVersion,
					mysqlVersion       => $mysqlVersion,
					apacheVersion      => $apacheVersion,
                                        zebraVersion       => $zebraVersion,
		);

my @component_names =
    qw/MARC::File::XML   MARC::Charset     Class::Accessor
       LWP::Simple       XML::Simple       Net::Z3950
       Event             Net::LDAP         PDF::API2
       Mail::Sendmail    MARC::Record      Digest::MD5
       HTML::Template    DBD::mysql        Date::Manip
       DBI               Smart::Comments   Net::Z3950::ZOOM
       Date::Calc
      /;

my @components = ();

foreach my $component (sort @component_names) {
    my $version;
    if (eval "require $component") {
        $version = $component->VERSION;
        if ($version eq '' ) {
            $version = 'unknown';
        }
    }
    else {
        $version = 'module is missing';
    }

    push (
        @components,
        {
            name    => $component,
            version => $version,
        }
    );
}

$template->param(
    components => \@components
);

output_html_with_http_headers $query, $cookie, $template->output;
