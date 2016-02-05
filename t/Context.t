#!/usr/bin/perl

use Modern::Perl;
use DBI;
use Test::More tests => 26;
use Test::MockModule;

BEGIN {
    use_ok('C4::Context');
}

my $context = new Test::MockModule('C4::Context');
my $userenv = {};

$context->mock('userenv', sub {
    return $userenv;
});

local $SIG{__WARN__} = sub { die $_[0] };

eval { C4::Context::IsSuperLibrarian(); };
like ( $@, qr/not defined/, "IsSuperLibrarian logs an error if no userenv is defined" );

$userenv->{flags} = 42;
my $is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if userenv is defined" );
is ( $is_super_librarian, 0, "With flag=42, it is not a super librarian" );

$userenv->{flags} = 421;
$is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if userenv is defined" );
is ( $is_super_librarian, 1, "With flag=1, it is a super librarian" );

$userenv->{flags} = undef;
$is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if \$userenv->{flags} is undefined" );
is ( $is_super_librarian, 0, "With flag=undef, it is not a super librarian" );

$userenv->{flags} = 0;
$is_super_librarian = eval{ C4::Context::IsSuperLibrarian() };
is ( $@, q||, "IsSuperLibrarian does not log an error if \$userenv->{flags} is equal to 0" );
is ( $is_super_librarian, 0, "With flag=0, it is not a super librarian" );

is(C4::Context::db_scheme2dbi('mysql'), 'mysql', 'ask for mysql, get mysql');
is(C4::Context::db_scheme2dbi('Pg'),    'Pg',    'ask for Pg, get Pg');
is(C4::Context::db_scheme2dbi('xxx'),   'mysql', 'ask for unsupported DBMS, get mysql');
is(C4::Context::db_scheme2dbi(),        'mysql', 'ask for nothing, get mysql');

# C4::Context::interface
my $lastwarn;
local $SIG{__WARN__} = sub { $lastwarn = $_[0] };
is(C4::Context->interface, 'opac','interface defaults to opac');
is(C4::Context->interface('foobar'), 'opac', 'interface foobar');
like($lastwarn, qr/invalid interface : 'foobar'/, 'interface warn on foobar');
is(C4::Context->interface, 'opac', 'interface still opac');
is(C4::Context->interface('intranet'), 'intranet', 'interface intranet');
is(C4::Context->interface, 'intranet', 'interface still intranet');
is(C4::Context->interface('foobar'), 'intranet', 'interface foobar again');
is(C4::Context->interface, 'intranet', 'interface still intranet');
is(C4::Context->interface('OPAC'), 'opac', 'interface OPAC uc');
is(C4::Context->interface, 'opac', 'interface still opac');
#Bug 14751
is( C4::Context->interface( 'SiP' ), 'sip', 'interface SiP' );
is( C4::Context->interface( 'COMMANDLINE' ), 'commandline', 'interface commandline uc' );
