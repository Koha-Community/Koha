use Modern::Perl;
use Test::More tests => 4;

use_ok( "C4::Utils::DataTables::Members" );

my $patrons = C4::Utils::DataTables::Members::search({
    searchmember => "Doe",
    searchfieldstype => 'standard',
    searchtype => 'contain'
});

isnt( $patrons->{iTotalDisplayRecords}, undef, "The iTotalDisplayRecords key is defined");
isnt( $patrons->{iTotalRecords}, undef, "The iTotalRecords key is defined");
is( ref $patrons->{patrons}, 'ARRAY', "The patrons key is an arrayref");
