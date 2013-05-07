#!/usr/bin/perl

# This is a completely new Z3950 clients search using async ZOOM -TG 02/11/06
# Copyright 2000-2002 Katipo Communications
#
# This is a new Z3950 authority search using the current Z3950 bibliographic search as a model 07/05/2013
# Parts Copyright 2013 Prosentient Systems
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
use CGI qw / -utf8 /;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Breeding;
use C4::Koha;

my $input        = new CGI;
my $dbh          = C4::Context->dbh;
my $error         = $input->param('error');
my $nameany     = $input->param('nameany');
my $authorany     = $input->param('authorany');
my $authorcorp     = $input->param('authorcorp');
my $authorpersonal     = $input->param('authorpersonal');
my $authormeetingcon     = $input->param('authormeetingcon');
my $title         = $input->param('title');
my $uniformtitle         = $input->param('uniformtitle');
my $subject       = $input->param('subject');
my $subjectsubdiv       = $input->param('subjectsubdiv');
my $srchany       = $input->param('srchany');
my $op            = $input->param('op')||'';
my $page            = $input->param('current_page') || 1;
$page = $input->param('goto_page') if $input->param('changepage_goto');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "cataloguing/z3950_auth_search.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
});

$template->param(
    nameany    => $nameany,
    authorany    => $authorany,
    authorcorp    => $authorcorp,
    authorpersonal    => $authorpersonal,
    authormeetingcon    => $authormeetingcon,
    title        => $title,
    uniformtitle      => $uniformtitle,
    subject      => $subject,
    subjectsubdiv   => $subjectsubdiv,
    srchany      => $srchany,
);

if ( $op ne "do_search" ) {
    my $sth = $dbh->prepare("SELECT id,host,name,checked FROM z3950servers WHERE recordtype = 'authority' ORDER BY rank, name");
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
if ( @id==0 ) {
        # empty server list -> report and exit
        $template->param( emptyserverlist => 1 );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
}

my $pars= {
        random => $input->param('random') || rand(1000000000),
        page => $page,
        id => \@id,
        nameany => $nameany,
        authorany => $authorany,
        authorcorp => $authorcorp,
        authorpersonal => $authorpersonal,
        authormeetingcon => $authormeetingcon,
        title => $title,
        uniformtitle => $uniformtitle,
        subject => $subject,
        subjectsubdiv => $subjectsubdiv,
        srchany => $srchany,
};
Z3950SearchAuth($pars, $template);
output_html_with_http_headers $input, $cookie, $template->output;
