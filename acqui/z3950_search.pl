#!/usr/bin/perl

# This is a completely new Z3950 clients search using async ZOOM -TG 02/11/06
# Copyright 2000-2002 Katipo Communications
# Copyright 2010 Catalyst IT
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

use Modern::Perl;
use CGI qw/-utf8/;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Breeding;
use C4::Koha;

use Koha::Acquisition::Booksellers;
use Koha::BiblioFrameworks;

my $input           = new CGI;
my $biblionumber    = $input->param('biblionumber')||0;
my $frameworkcode   = $input->param('frameworkcode') || q{};
my $title           = $input->param('title');
my $author          = $input->param('author');
my $isbn            = $input->param('isbn');
my $issn            = $input->param('issn');
my $lccn            = $input->param('lccn');
my $lccall          = $input->param('lccall');
my $subject         = $input->param('subject');
my $srchany         = $input->param('srchany');
my $stdid           = $input->param('stdid');
my $dewey           = $input->param('dewey');
my $controlnumber   = $input->param('controlnumber');
my $op              = $input->param('op')||'';
my $booksellerid    = $input->param('booksellerid');
my $basketno        = $input->param('basketno');
my $page            = $input->param('current_page') || 1;
$page               = $input->param('goto_page') if $input->param('changepage_goto');

# get framework list
my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] });

my $vendor = Koha::Acquisition::Booksellers->find( $booksellerid );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/z3950_search.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { acquisition => 'order_manage' },
    }
);
$template->param(
        frameworkcode => $frameworkcode,
        frameworks   => $frameworks,
        booksellerid => $booksellerid,
        basketno     => $basketno,
        name         => $vendor->name,
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
        srchany      => $srchany,
        stdid        => $stdid,
);

if ( $op ne "do_search" ) {
    my $schema = Koha::Database->new()->schema();
    my $rs = $schema->resultset('Z3950server')->search(
        {
            recordtype => 'biblio',
            servertype => ['zed', 'sru'],
        },
        {   result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            order_by     => ['rank', 'servername'],
        },
    );
    $template->param(
        serverloop   => [ $rs->all ],
        opsearch     => "search",
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my @id = $input->multi_param('id');
if (@id==0) {
    $template->param( emptyserverlist => 1 );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my $pars= {
        biblionumber => $biblionumber,
        page => $page,
        id => \@id,
        isbn => $isbn,
        issn => $issn,
        title => $title,
        author => $author,
        dewey => $dewey,
        subject => $subject,
        lccall => $lccall,
        controlnumber => $controlnumber,
        stdid => $stdid,
        srchany => $srchany,
};
Z3950Search($pars, $template);
output_html_with_http_headers $input, $cookie, $template->output;
