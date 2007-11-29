#!/usr/bin/perl

use lib '/usr/local/opus-dev/intranet/modules';
use C4::Context("/etc/koha-opus-dev.conf");

use strict;
use CGI;
use C4::Labels;
use C4::Auth;
use C4::Output;
use C4::Context;
use HTML::Template::Pro;

use Data::Dumper;

# get the printing settings
my $conf_data = get_label_options();
my $cgi       = new CGI;

my $papertype = $conf_data->{'papertype'};
warn $papertype;

if ( $papertype eq "Gaylord8511" ) {
    warn "GAY";
    print $cgi->redirect("/cgi-bin/koha/barcodes/label-print-pdf.pl");
}
elsif ( $papertype eq "OPUS-Dot Matrix" ) {
    warn "OPUS labes";
    print $cgi->redirect("/cgi-bin/koha/barcodes/label-print-opus-pdf.pl");
}

