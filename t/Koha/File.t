use Modern::Perl;
use Test::More;

use Koha::File;

subtest "Test file diagnostic", \&getDiagnostics;
sub getDiagnostics {
    _testDiagnostics($ENV{KOHA_PATH}.'/kohaversion.pl',   '-');
    _testDiagnostics($ENV{KOHA_PATH}.'/xt',               'd');
}


done_testing;


sub _testDiagnostics {
    my ($filepath, $expectedFiletype) = @_;
    my @expected = (
        $expectedFiletype,
        sprintf("%04o", ((lstat($filepath))[2] & 07777)), #$expectedPermissions,
        scalar(getpwuid((lstat($filepath))[4])),          #$expectedUser,
        scalar(getgrgid((lstat($filepath))[5])),          #$expectedGroup,
    );

    ok( my $diag = Koha::File::getDiagnostics($filepath),
       "Given file '$filepath' exists and diagnostics received");
    is( $diag->{user},  $expected[2],
       "Then file owner matches");
    is( $diag->{group}, $expected[3],
       "Then file group matches");
    is( $diag->{permissions}, $expected[1],
       "Then file permissions match");
    is( $diag->{filetype}, $expected[0],
       "Then filetype is $expected[0]");

    is(Koha::File::getDiagnosticsString($filepath), sprintf($Koha::File::diagnosticsStringFormat, @expected),
       "Then the diagnostic string matches");
}
