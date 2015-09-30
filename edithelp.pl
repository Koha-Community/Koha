#!/usr/bin/perl

# Copyright 2007 Liblime Ltd
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
use C4::Output;
use C4::Templates;
use C4::Auth;
use CGI;
use warnings;

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}

our $input = new CGI;

my $type    = $input->param('type') || '';
my $referer = $input->param('referer') || '';
my $oldreferer = $referer;
my $help    = $input->param('help') || '';
# strip any DOS-newlines that TinyMCE may have sneaked in
$help =~ s/\r//g;
my $error;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "help/edithelp.tt",
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
    $referer =~ /koha\/(.*)\.pl/;
    my $file = $1;
    $file =~ s/[^0-9a-zA-Z_\-\/]*//g;
    my $from = "help/$file.tt";
    my $htdocs = C4::Context->config('intrahtdocs');
    my ($theme, $lang, $availablethemes) = C4::Templates::themelanguage( $htdocs, $from, "intranet", $input );
	$debug and print STDERR "help filepath: $htdocs/$theme/$lang/modules/$from";
	return "$htdocs/$theme/$lang/modules/$from";
}

$type = 'create' if $type eq 'addnew';
if ( $type eq 'create' || $type eq 'save' ) {
	my $file = _get_filepath($referer);
    open my $fh, ">", $file;
    if ( $fh ) {
        # file is open write to it
        print $fh
            " [% INCLUDE 'help-top.inc' %]\n",
		    $type eq 'create' ? "<div class=\"main\">\n$help\n</div>" : $help,
            "\n[% INCLUDE 'help-bottom.inc' %]\n";
        close $fh;
		print $input->redirect("/cgi-bin/koha/help.pl?url=$oldreferer");
    }
    else {
        $error = "Cannot write file: '$file'";
    }
}
elsif ( $type eq 'modify' ) {
    # open file load data, kill include calls, pass data to the template
	my $file = _get_filepath($referer, 1);	# 2nd argument triggers themelanguage call
	if (! -r $file) {
		$error = "Cannot read file: '$file'.";
	} else {
		(-w $file) or $error = 
			"WARNING: You will not be able to save, because your webserver cannot write to '$file'. Contact your admin about help file permissions.";
    	open (my $fh, '<', $file) or die "Cannot read file '$file'";		# unlikely death, since we just checked
		my $help = '';
        while ( <$fh> ) {
            $help .= /\[% INCLUDE .* %\](.*)$/ ? $1 : $_;
		}
		close $fh;
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
