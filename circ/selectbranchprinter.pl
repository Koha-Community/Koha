#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use C4::Context;
use C4::Output;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Print;  # GetPrinters
use C4::Koha;
use C4::Branch; # GetBranches GetBranchesLoop

# this will be the script that chooses branch and printer settings....

my $query = CGI->new();

my ( $template, $borrowernumber, $cookie ) = get_template_and_user({
    template_name   => "circ/selectbranchprinter.tt",
    query           => $query,
    type            => "intranet",
    debug           => 1,
    authnotrequired => 0,
    flagsrequired   => { catalogue => 1, },
});

my $sessionID = $query->cookie("CGISESSID");
my $session = get_session($sessionID);

# try to get the branch and printer settings from http, fallback to userenv
my $branches = GetBranches();
my $printers = GetPrinters();
my $branch   = $query->param('branch' );
my $printer  = $query->param('printer');
# fallbacks for $branch and $printer after possible session updates

my $userenv_branch  = C4::Context->userenv->{'branch'}        || '';
my $userenv_printer = C4::Context->userenv->{'branchprinter'} || '';
my @updated;

# $session lddines here are doing the updating
if ($branch and $branches->{$branch}) {
    if (! $userenv_branch or $userenv_branch ne $branch ) {
        my $branchname = GetBranchName($branch);
        $template->param(LoginBranchname => $branchname);   # update template for new branch
        $template->param(LoginBranchcode => $branch);       # update template for new branch
        $session->param('branchname', $branchname);         # update sesssion in DB
        $session->param('branch', $branch);                 # update sesssion in DB
        push @updated, {
            updated_branch => 1,
                old_branch => $userenv_branch,
        };
    } # else branch the same, no update
} else {
    $branch = $userenv_branch;  # fallback value
}

# FIXME: branchprinter is not retained by session.  This feature was not adequately
# ported from Koha 2.2.3 where it had been a separate cookie.
# So this needs to be fixed for Koha 3 or removed outright.
#   --atz (w/ info from chris cormack)

if ($printer) {
    if (! $userenv_printer or $userenv_printer ne $printer ) {
        $session->param('branchprinter', $printer);         # update sesssion in DB
        $template->param('new_printer', $printer);          # update template
        push @updated, {
            updated_printer => 1,
                old_printer => $userenv_printer,
        };
    } # else printer is the same, no update
} else {
    $printer = $userenv_printer;  # fallback value
}

$template->param(updated => \@updated) if (scalar @updated);

unless ($branches->{$branch}) {
    $branch = (keys %$branches)[0];  # if branch didn't really exist, then replace it w/ one that does
}

my @printkeys = sort keys %$printers;
if (scalar(@printkeys) == 1 or not $printers->{$printer}) {
    $printer = $printkeys[0];   # if printer didn't really exist, or there is only 1 anyway, then replace it w/ one that does
}

my @printerloop;
foreach ( @printkeys ) {
    next unless ($_); # skip printer if blank.
    push @printerloop, {
        selected => ( $_ eq $printer ),
        name     => $printers->{$_}->{'printername'},
        value    => $_,
    };
}

my @recycle_loop;
foreach ($query->param()) {
    $_ or next;                   # disclude blanks
    $_ eq "branch"     and next;  # disclude branch
    $_ eq "printer"    and next;  # disclude printer
    $_ eq "oldreferer" and next;  # disclude oldreferer
    push @recycle_loop, {
        param => $_,
        value => $query->param($_),
    };
}

my $referer =  $query->param('oldreferer') || $ENV{HTTP_REFERER};
$referer =~ /selectbranchprinter\.pl/ and undef $referer;   # avoid sending them back to this same page.

if (scalar @updated and not scalar @recycle_loop) {
    # we updated something, and there were no extra params to POST: quick redirect
    print $query->redirect($referer || '/cgi-bin/koha/circ/circulation.pl');
}

$template->param(
    referer     => $referer,
    printerloop => \@printerloop,
    branchloop  => GetBranchesLoop($branch),
    recycle_loop=> \@recycle_loop,
);

output_html_with_http_headers $query, $cookie, $template->output;
