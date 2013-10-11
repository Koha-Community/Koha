#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::Deep;

use C4::Context;
BEGIN {
    use_ok('C4::Csv');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do('DELETE FROM export_format');

my $sth = $dbh->prepare(q{
    INSERT INTO export_format (profile, description, content, type)
    VALUES (?, ?, ?, ?)
});
$sth->execute('MARC', 'MARC profile', '245$a',          'marc');
$sth->execute('SQL',  'SQL profile',  'borrowers.surname', 'sql');

my $all_profiles = C4::Csv::GetCsvProfiles();
is(@$all_profiles, 2, 'test getting all CSV profiles');

my $sql_profiles = C4::Csv::GetCsvProfiles('sql');
is(@$sql_profiles, 1, 'test getting SQL CSV profiles');
is($sql_profiles->[0]->{profile}, 'SQL', '... and got the right one');
my $marc_profiles = C4::Csv::GetCsvProfiles('marc');
is(@$marc_profiles, 1, 'test getting MARC CSV profiles');
is($marc_profiles->[0]->{profile}, 'MARC', '... and got the right one');

my $id = C4::Csv::GetCsvProfileId('MARC');
my $profile = C4::Csv::GetCsvProfile($id);
is($profile->{profile}, 'MARC', 'retrieved profile by ID');

is(C4::Csv::GetCsvProfile(), undef, 'test getting CSV profile but not supplying ID');

cmp_deeply(
    C4::Csv::GetCsvProfilesLoop(),
    [
        {
            export_format_id   => ignore(),
            profile            => 'MARC',
        },
        {
            export_format_id   => ignore(),
            profile            => 'SQL',
        },
    ],
    'test getting profile loop'
);

cmp_deeply(
    C4::Csv::GetCsvProfilesLoop('marc'),
    [
        {
            export_format_id   => ignore(),
            profile            => 'MARC',
        },
    ],
    'test getting profile loop for one type'
);
