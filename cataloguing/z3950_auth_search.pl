#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 Prosentient Systems
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw / -utf8 /;

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use C4::Breeding qw( Z3950Search Z3950SearchAuth );
use MARC::Record;
use Koha::Authorities;
use Koha::Authority::Types;
use C4::AuthoritiesMarc qw( GetAuthority );

my $input        = CGI->new;
my $dbh          = C4::Context->dbh;
my $error         = $input->param('error');
my $authid  = $input->param('authid') || 0;
my $op            = $input->param('op')||'';

my $record         = GetAuthority($authid);
my $marc_flavour = C4::Context->preference('marcflavour');
my $authfields_mapping = {
    'authorpersonal'   => $marc_flavour eq 'MARC21' ? '100' : '200',
    'authorcorp'       => $marc_flavour eq 'MARC21' ? '110' : '210',
    'authormeetingcon' => $marc_flavour eq 'MARC21' ? '111' : '210',
    'uniformtitle'     => $marc_flavour eq 'MARC21' ? '130' : '230',
    'subject'          => $marc_flavour eq 'MARC21' ? '150' : '250',
};

my $nameany          = $input->param('nameany');
my $authorany        = $input->param('authorany');
my $title            = $input->param('title');
my $authorpersonal   = $input->param('authorpersonal');
my $authormeetingcon = $input->param('authormeetingcon');
my $uniformtitle     = $input->param('uniformtitle');
my $subject          = $input->param('subject');
my $authorcorp       = $input->param('authorcorp');
my $subjectsubdiv    = $input->param('subjectsubdiv');
my $srchany          = $input->param('srchany');

# If replacing an existing record we want to initially populate the form with record info,
# however, we want to use entered inputs when searching
if ( $record && $op ne 'do_search' ) {
    $authorcorp ||=
      $record->subfield( $authfields_mapping->{'authorcorp'}, 'a' );
    $authorpersonal ||=
      $record->subfield( $authfields_mapping->{'authorpersonal'}, 'a' );
    $authormeetingcon ||=
      $record->subfield( $authfields_mapping->{'authormeetingcon'}, 'a' );
    $uniformtitle ||=
      $record->subfield( $authfields_mapping->{'uniformtitle'}, 'a' );
    $subject ||= $record->subfield( $authfields_mapping->{'subject'}, 'a' );
}

my $page            = $input->param('current_page') || 1;
my $index =$input->param('index');
$page = $input->param('goto_page') if $input->param('changepage_goto');
my $controlnumber    = $input->param('controlnumber');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "cataloguing/z3950_auth_search.tt",
        query           => $input,
        type            => "intranet",
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
    authid => $authid,
    controlnumber => $controlnumber,
    index => $index,
);

if ( $op ne "do_search" ) {
    my $sth = $dbh->prepare("SELECT id,host,servername,checked FROM z3950servers WHERE recordtype = 'authority' ORDER BY `rank`, servername");
    $sth->execute();
    my $serverloop = $sth->fetchall_arrayref( {} );
    $template->param(
        serverloop   => $serverloop,
        opsearch     => "search",
        index        => $index,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my @id = $input->multi_param('id');
if ( @id==0 ) {
        # empty server list -> report and exit
        $template->param( emptyserverlist => 1 );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
}

my $pars= {
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
        authid => $authid,
        controlnumber => $controlnumber,
};
Z3950SearchAuth($pars, $template);
output_html_with_http_headers $input, $cookie, $template->output;
