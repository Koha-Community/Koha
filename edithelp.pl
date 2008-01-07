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

my $input = new CGI;

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

if ( $type eq 'addnew' ) {
    $type = 'create';
}
elsif ( $type eq 'create' || $type eq 'save' ) {
    $referer =~ /.*koha\/(.*)\.pl.*/;
    my $from   = "help/$1.tmpl";
    my $htdocs = C4::Context->config('intrahtdocs');
#    my ( $theme, $lang ) = themelanguage( $htdocs, $from, "intranet" );
	my $theme = C4::Context->preference('template');
   	my $lang  = C4::Context->preference('language') || 'en';

    #    if (! -e "$htdocs/$theme/$lang/$from") {
    # doesnt exist
    eval {
        open( OUTFILE, ">$htdocs/$theme/$lang/modules/$from" ) || die "Can't open file";
    };
    if ($@) {
        $error = "Cant open file $htdocs/$theme/$lang/modules/$from";
    }
    else {

        # file is open write to it
        print OUTFILE "<!-- TMPL_INCLUDE name=\"help-top.inc\" -->\n";
		if ($type eq 'create'){
			print OUTFILE "<div class=\"main\">\n";
		}
        print OUTFILE "$help\n";
	    if ($type eq 'create'){
			print OUTFILE "</div>\n";
		}
        print OUTFILE "<!-- TMPL_INCLUDE name=\"help-bottom.inc\" -->\n";
        close OUTFILE;
		print $input->redirect("/cgi-bin/koha/help.pl?url=$oldreferer");
    }


    #   }

}
elsif ( $type eq 'modify' ) {

    # open file load data, kill include calls, pass data to the template
    $referer =~ /.*koha\/(.*)\.pl.*/;
    my $from   = "help/$1.tmpl";
    my $htdocs = C4::Context->config('intrahtdocs');
    my ( $theme, $lang ) = themelanguage( $htdocs, $from, "intranet", $input );
    eval {
        open( INFILE, "$htdocs/$theme/$lang/modules/$from" ) || die "Can't open file";
    };
    if ($@) {
        $error = "Cant open file $htdocs/$theme/$lang/modules/$from";
    }
    my $help;
    while ( my $inp = <INFILE> ) {
        if ( $inp =~ /TMPL\_INCLUDE/ ) {
        }
        else {
            $help .= $inp;
        }
    }
    close INFILE;
    $template->param( 'help' => $help );

    $type = 'save';
}

$template->param(
    'referer' => $referer,
    'type'    => $type,
    'error'   => $error,

);

output_html_with_http_headers $input, "", $template->output;
