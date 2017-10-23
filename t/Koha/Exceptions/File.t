use Modern::Perl;
use Test::More;

use Try::Tiny;
use File::Basename;

use Koha::Exceptions::File;

#file diagnostics are more throughly tested in t/Koha/File.t
subtest "Catch File-exception and inspect diagnostics", \&getDiagnostics;
sub getDiagnostics {
    my $file = $ENV{KOHA_PATH}.'/kohaversion.pl';
    my $parentDir = File::Basename::dirname($file);
    try {
        Koha::Exceptions::File->throw(error => "error", path => $file);
        ok(0, "??Why no throw exception??");
    } catch { my $e = $_;
        ok($e->isa('Koha::Exceptions::File'), "Given the expected exception");
        like($e->stat, qr/^\w+/, "Then the file diagnostics look legit");
    };

    $file = $ENV{KOHA_PATH}.'/koha-aversion.pl';
    try {
        Koha::Exceptions::File->throw(error => "error", path => $file);
        ok(0, "??Why no throw exception??");
    } catch { my $e = $_;
        ok($e->isa('Koha::Exceptions::File'), "Given the expected exception");
        like($e->stat, qr/^\w+/, "Then the file diagnostics look legit");
        like($e->stat, qr/FILE NOT EXISTS/, "And file doesn't exist");
        like($e->stat, qr/Parent directory '$parentDir' permissions/, "And parent directory diagnostics delivered");
    };
}


done_testing;
