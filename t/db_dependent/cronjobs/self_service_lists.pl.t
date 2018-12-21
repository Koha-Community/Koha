use Modern::Perl '2015';
use utf8;
use English;
use Carp::Always;

use Storable;

use Test::Most tests => 5;
use File::Temp;
use File::Slurp;

use C4::Context;
use C4::SelfServiceLists;
use C4::SelfService::BlockManager;
use C4::Encryption::Configuration;

use Koha::Database;
my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

ok(C4::Context->set_preference('EncryptionConfiguration', "passphrase: 1234\ncipher-algorithm: AES-256"),
   "Given the syspref 'EncryptionConfiguration' is properly configured");
ok(C4::Context->set_preference('SSRules', "Permission: 1\nMaxFines: 1\n AgeLimit:1\nBranchBlock: 1\n"),
   "Given the syspref 'SSRules' is properly configured");

subtest "Scenario: C4::SelfServiceLists::export()", sub {
    plan tests => 6;

    ok(my $borrowers = [
        {borrowernumber => 1, not_exported => 5, HasSelfServicePermission => 1, BranchSpecificBlocks => [{branchcode => 'CPL', expirationdate => '2018-01-01T15:15:15'}, {branchcode => 'IPT', expirationdate => '2018-02-02T16:16:16'}]},
        {borrowernumber => 2, not_exported => 6, HasSelfServicePermission => 0, BranchSpecificBlocks => undef},
        {borrowernumber => 3, not_exported => 7, HasSelfServicePermission => 1, BranchSpecificBlocks => undef},
    ],  "Given a bunch of borrowers with self service permission");

    subtest ".csv export", sub {
        plan tests => 3;

        ok(my $filePath = C4::SelfServiceLists::export(Storable::dclone($borrowers), ['not_exported'], 'csv'),
            "When the borrowers are exported as 'csv'");
        like($filePath, qr/\.csv$/,
             "Then a file is exported with the proper file suffix");
        like(File::Slurp::read_file($filePath), qr/^
                borrowernumber,not_exported,HasSelfServicePermission,BranchSpecificBlocks\n
                1,5,1,\[CPL:IPT\]\n
                2,6,0,\[\]\n
                3,7,1,\[\]\n
            /sx,
            "And the exported file has proper contents");
    };
    subtest ".csv export, subset of columns", sub {
        plan tests => 2;

        ok(my $filePath = C4::SelfServiceLists::export(Storable::dclone($borrowers), undef, 'csv'),
            "When the borrowers are exported as 'csv'");
        like(File::Slurp::read_file($filePath), qr/^
                borrowernumber,HasSelfServicePermission,BranchSpecificBlocks\n
                1,1,\[CPL:IPT\]\n
                2,0,\[\]\n
                3,1,\[\]\n
            /sx,
            "And the exported file has proper contents");
    };
    subtest ".yml export", sub {
        plan tests => 4;

        ok(my $filePath = C4::SelfServiceLists::export(Storable::dclone($borrowers), ['not_exported'], 'yml'),
            "When the borrowers are exported as 'yml'");
        like($filePath, qr/\.yml$/,
             "Then a file is exported with the proper file suffix");
        ok(my $yaml = YAML::XS::LoadFile($filePath),
             "And is a valid .yaml-file");
        cmp_deeply($yaml, $borrowers,
             "And the exported contents are as expected");
    };
    subtest ".yml export, subset of columns", sub {
        plan tests => 2;

        ok(my $filePath = C4::SelfServiceLists::export(Storable::dclone($borrowers), [], 'yml'),
            "When the borrowers are exported as 'yml'");
        unlike(File::Slurp::read_file($filePath), qr/\n  not_exported: 5\n/s,
            "And the excluded column is missing");
    };
    subtest "Mikro-Väylä .xml export", sub {
        plan tests => 3;

        ok(my $filePath = C4::SelfServiceLists::export($borrowers, ['borrowernumber','HasSelfServicePermission'], 'mv-xml'),
            "When the borrowers are exported as 'mv-xml'");
        like($filePath, qr/\.xml$/,
             "Then a file is exported with the proper file suffix");
        like(File::Slurp::read_file($filePath), qr!<patronid_pac>1</patronid_pac>\n\s+<type_pac>1</type_pac>\n!s,
            "And the exported file has proper contents");
    };
};

subtest "Scenario: C4::SelfServiceLists::extract()", sub {
    plan tests => 8;

    ok(my $data = C4::SelfServiceLists::extract(10),
      "When simple columns are extracted");
    is(ref($data), 'ARRAY', "Then extract() returns an ARRAYRef");
    ok($data->[2]->{borrowernumber}, "And entries have the column 'borrowernumber' extracted by default");
    ok($data->[2]->{cardnumber},     "And entries have the requested column 'cardnumber'");
    ok($data->[2]->{userid},         "And entries have the requested column 'userid'");
    ok(defined($data->[2]->{HasSelfServicePermission}), "And entries have the self service permission value");
    ok(exists($data->[2]->{BranchSpecificBlocks}), "And entries have the branch specific blocks-list value");

    subtest("Scenario: extract branch-specific self-service blocks", sub {
        plan tests => 11;

        my $blocks = [{
                borrowernumber => $data->[2]->{borrowernumber},
                branchcode     => 'CPL',
                created_by     => $data->[0]->{borrowernumber},
            },{
                borrowernumber => $data->[2]->{borrowernumber},
                branchcode     => 'IPT',
                created_by     => $data->[0]->{borrowernumber},
        }];
        ok(my $block = C4::SelfService::BlockManager::storeBlock( C4::SelfService::BlockManager::createBlock($blocks->[0]) ),
            "Given a simple block");
        ok($block = C4::SelfService::BlockManager::storeBlock( C4::SelfService::BlockManager::createBlock($blocks->[1]) ),
            "Given another simple block");

        ok(my $data = C4::SelfServiceLists::extract(10),
            "When simple columns are extracted");
        is(ref($data), 'ARRAY', "Then extract() returns an ARRAYRef");
        ok($data->[2]->{borrowernumber}, "And entries have the column 'borrowernumber' extracted by default");
        ok($data->[2]->{cardnumber},     "And entries have the requested column 'cardnumber'");
        ok($data->[2]->{userid},         "And entries have the requested column 'userid'");
        ok(defined($data->[2]->{HasSelfServicePermission}), "And entries have the self service permission value");
        cmp_deeply($data->[2]->{BranchSpecificBlocks}->[0], isa('C4::SelfService::Block'), "And 1st self-service block is found");
        cmp_deeply($data->[2]->{BranchSpecificBlocks}->[1], isa('C4::SelfService::Block'), "And 2nd self-service block is found");
        ok(! $data->[1]->{BranchSpecificBlocks}, "And self-service blocks are not found from where they shouldn't be");
    });
};

subtest "Scenario: Execute a full list extraction pipeline", sub {
    plan tests => 7;

    my $tempDir = File::Temp::tempdir(CLEANUP => 1);
    my $file = "$tempDir/file";
    ok($tempDir, "Given an export target file '$file'");

    ok(my $argv = {
        file => $file,
        type => 'csv',
        encrypt => "passphrase: password\ncipher-algorithm: algorithm",
        selectors => ['cardnumber'],
        limit => 10,
    },"And a bad cipher algorithm");

    throws_ok( sub { C4::SelfServiceLists::run($argv) }, qr/gpg: selected cipher algorithm is invalid/,
      "Then the encryption fails, due to an unknown algorithm");

    ok($argv->{encrypt} = "passphrase: password\ncipher-algorithm: AES-256",
      "Given a known good cipher algorithm");
    $argv->{limit} = 1000;

    my $startTime = time;
    lives_ok( sub { C4::SelfServiceLists::run($argv) },
      "When the self-service list is generated");
    my $endTime = time; my $duration = $endTime - $startTime;

    my $contents = File::Slurp::read_file("$file.csv.gpg") or die "Failed to slurp file '$file.csv.gpg': $!";
    like($contents, qr/\d+/,
      "Then the contents of the export are as expected.");

    ok($duration <= 7, "Runtime ${duration}s for 1000 borrowers is less than 11 seconds");
};

$schema->storage->txn_rollback;

done_testing();
