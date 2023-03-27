#!/usr/bin/perl

# Koha library project  www.koha-community.org

# Copyright 2020 Koha Development Team
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

# standard or CPAN modules used
use CGI qw(:standard -utf8);
use DBI;
use Encode;
use JSON;
use Try::Tiny;

# Koha modules used
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw(get_template_and_user);
use C4::Biblio;
use C4::ImportBatch;
use C4::XSLT ;
use Koha::SearchEngine::Elasticsearch;
use LWP::Simple qw/get/;

my $input= new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
  {
    template_name   => "catalogue/showelastic.tt",
    query           => $input,
    type            => "intranet",
    flagsrequired   => { catalogue => 1  },
    debug           => 1,
  }
);

my $biblionumber = $input->param('id');

my $es = Koha::SearchEngine::Elasticsearch->new({index=>'biblios'});

my $es_record;
my @es_fields;

try {
    $es_record = $es->get_elasticsearch()->get({
        index => $es->index_name,
        type  => 'data',
        id    => $biblionumber,
    });
}
catch{
    warn $_;
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
};

for my $field (sort keys %{$es_record} ){
    push @es_fields, { $field, $es_record->{$field} };
};
$template->param( esrecord => to_json( \@es_fields ) );
output_html_with_http_headers $input, $cookie, $template->output;
