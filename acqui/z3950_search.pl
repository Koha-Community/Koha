#!/usr/bin/perl

# This is a completely new Z3950 clients search using async ZOOM -TG 02/11/06
# Copyright 2000-2002 Katipo Communications
# Copyright 2010 Catalyst IT
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

use warnings;
use strict;
use CGI;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Breeding;
use C4::Koha;
use C4::Bookseller qw/ GetBookSellerFromId /;

my $input           = new CGI;
my $dbh             = C4::Context->dbh;
my $biblionumber    = $input->param('biblionumber')||0;
my $frameworkcode   = $input->param('frameworkcode')||'';
my $title           = $input->param('title');
my $author          = $input->param('author');
my $isbn            = $input->param('isbn');
my $issn            = $input->param('issn');
my $lccn            = $input->param('lccn');
my $lccall          = $input->param('lccall');
my $subject         = $input->param('subject');
my $dewey           = $input->param('dewey');
my $controlnumber   = $input->param('controlnumber');
my $op              = $input->param('op')||'';
my $booksellerid    = $input->param('booksellerid');
my $basketno        = $input->param('basketno');
my $page            = $input->param('current_page') || 1;
$page               = $input->param('goto_page') if $input->param('changepage_goto');

# get framework list
my $frameworks = getframeworks;
my @frameworkcodeloop;
foreach my $thisframeworkcode ( keys %$frameworks ) {
    my %row = (
        value         => $thisframeworkcode,
        frameworktext => $frameworks->{$thisframeworkcode}->{'frameworktext'},
    );
    if ( $row{'value'} eq $frameworkcode){
        $row{'active'} = 'true';
    }
    push @frameworkcodeloop, \%row;
}

my $vendor = GetBookSellerFromId($booksellerid);

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/z3950_search.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { acquisition => 'order_manage' },
    }
);
$template->param(
        frameworkcode => $frameworkcode,
        frameworkcodeloop => \@frameworkcodeloop,
        booksellerid => $booksellerid,
        basketno     => $basketno,
        name         => $vendor->{'name'},
        isbn         => $isbn,
        issn         => $issn,
        lccn         => $lccn,
        lccall       => $lccall,
        title        => $title,
        author       => $author,
        controlnumber=> $controlnumber,
        biblionumber => $biblionumber,
        dewey        => $dewey,
        subject      => $subject,
);

if ( $op ne "do_search" ) {
    my $sth = $dbh->prepare("select id,host,name,checked from z3950servers  order by host");
    $sth->execute();
    my $serverloop = $sth->fetchall_arrayref( {} );
    $template->param(
        serverloop   => $serverloop,
        opsearch     => "search",
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my @id = $input->param('id');
if (@id==0) {
    $template->param( emptyserverlist => 1 );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my $pars= {
        random => $input->param('random') || rand(1000000000),
        biblionumber => $biblionumber,
        page => $page,
        id => \@id,
        isbn => $isbn,
        title => $title,
        author => $author,
        dewey => $dewey,
        subject => $subject,
        lccall => $lccall,
        controlnumber => $controlnumber,
        stdid => 0,
        srchany => 0,
};
Z3950Search($pars, $template);
output_html_with_http_headers $input, $cookie, $template->output;
