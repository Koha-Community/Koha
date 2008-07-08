#!/usr/bin/perl

# Copyright 2007 Liblime Ltd
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use C4::Output;
use C4::Auth;
use CGI;

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}

our $input = new CGI;

my $type    = $input->param('type');
my $referer = $input->param('referer');
my $oldreferer = $referer;
my $help    = $input->param('help');
my $error;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "help/edithelp.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {
            catalogue        => 1,
            circulate        => 1,
            parameters       => 1,
            borrowers        => 1,
            permissions      => 1,
            reserveforothers => 1,
            borrow           => 1,
            reserveforself   => 1,
            editcatalogue    => 1,
            updatecharges    => 1,
        },
        debug => 1,
    }
);

sub _get_filepath ($;$) {
    my $referer = shift;
    $referer =~ /.*koha\/(.+)\.pl.*/;
    my $from   = "help/$1.tmpl";
    my $htdocs = C4::Context->config('intrahtdocs');
	my ($theme, $lang);
	# This split behavior was part of the old script.  I'm not sure why.  -atz
	if (@_) {
		($theme, $lang) = themelanguage( $htdocs, $from, "intranet", $input );
	} else {
		$theme = C4::Context->preference('template');
   		$lang  = C4::Context->preference('language') || 'en';
	}
	$debug and print STDERR "help filepath: $htdocs/$theme/$lang/modules/$from";
	return "$htdocs/$theme/$lang/modules/$from";
}

if ( $type eq 'addnew' ) {
    $type = 'create';
}
elsif ( $type eq 'create' || $type eq 'save' ) {
	my $file = _get_filepath($referer);
	unless (open (OUTFILE, ">$file")) {$error = "Cannot write file: '$file'";} else {
        #open (OUTFILE, ">$file") or die "Cannot write file: '$file'";	# unlikely death, since we just checked
        # file is open write to it
        print OUTFILE "<!-- TMPL_INCLUDE NAME=\"help-top.inc\" -->\n";
		print OUTFILE ($type eq 'create') ? "<div class=\"main\">\n$help\n</div>" : $help;
        print OUTFILE "\n<!-- TMPL_INCLUDE NAME=\"help-bottom.inc\" -->\n";
        close OUTFILE;
		print $input->redirect("/cgi-bin/koha/help.pl?url=$oldreferer");
    }
    
}
elsif ( $type eq 'modify' ) {
    # open file load data, kill include calls, pass data to the template
	my $file = _get_filepath($referer, 1);	# 2nd argument triggers themelanguage call
	if (! -r $file) {
		$error = "Cannot read file: '$file'.";
	} else {
		(-w $file) or $error = 
			"WARNING: You will not be able save, because your webserver cannot write to '$file'. Contact your admin about help file permissions.";
    	open (INFILE, $file) or die "Cannot read file '$file'";		# unlikely death, since we just checked
		my $help = '';
		while ( my $inp = <INFILE> ) {
			unless ( $inp =~ /TMPL\_INCLUDE/ ) {
				$help .= $inp;
			}
		}
		close INFILE;
    	$template->param( 'help' => $help );
		$type = 'save';
	}
}

$template->param(
    'referer' => $referer,
    'type'    => $type,
);
($error) and $template->param('error' => $error);
output_html_with_http_headers $input, "", $template->output;
