#!/usr/bin/perl

use Modern::Perl;
use C4::SocialData;

my $results = C4::SocialData::get_report;

say "==== Social Data report ====";
say "Matched : (" . scalar( @{ $results->{with} } ) . ")";
say "biblionumber = $_->{biblionumber},\toriginal = $_->{original},\tisbn = $_->{isbn}" for @{ $results->{with} };

say "No Match : (" . scalar( @{ $results->{without} } ) . ")";
say "biblionumber = $_->{biblionumber},\toriginal = $_->{original},\tisbn = $_->{isbn}" for @{ $results->{without} };

say "Without ISBN : (" . scalar( @{ $results->{no_isbn} } ) . ")";
say "biblionumber = $_->{biblionumber}" for @{ $results->{no_isbn} };
