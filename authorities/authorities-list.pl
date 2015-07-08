#!/usr/bin/perl
use strict;
use warnings;
use C4::Context;
use C4::AuthoritiesMarc;
use utf8;
use open qw[ :std :encoding(utf8) ];
use Koha::SearchEngine;
use Koha::SearchEngine::Search;

my $dbh=C4::Context->dbh;
my $datatypes_query = $dbh->prepare(<<ENDSQL);
SELECT authtypecode,authtypetext,auth_tag_to_report from auth_types;
ENDSQL
$datatypes_query->execute;
my $datatypes=$datatypes_query->fetchall_arrayref({});
my %authtypes;
map { $authtypes{$_->{'authtypecode'}}={"tag"=> $_->{'auth_tag_to_report'}, "lib"=> $_->{'authtypetext'}};} @$datatypes;
my $data_query = $dbh->prepare(<<ENDSQL);
SELECT authid, authtypecode from auth_header
ENDSQL
$data_query->execute;
my $dataauthorities=$data_query->fetchall_arrayref({});
foreach my $authority (@$dataauthorities){
  my $marcauthority=GetAuthority($authority->{'authid'});
  my $query;
  $query= "an=".$authority->{'authid'};
  # search for biblios mapped
  my $searcher = Koha::SearchEngine::Search->new({index => $Koha::SearchEngine::BIBLIOS_INDEX});
  my ($err,undef,$used) = $searcher->simple_search_compat($query,0,1);
  if (defined $err) {
      $used = 0;
  }
  if ($marcauthority && $marcauthority->field($authtypes{$authority->{'authtypecode'}}->{'tag'})){
    print qq("),$marcauthority->field($authtypes{$authority->{'authtypecode'}}->{"tag"})->as_string(),qq(";),qq($authority->{'authid'};"),$authtypes{$authority->{'authtypecode'}}->{'lib'},qq(";$used\n);
  }
}
