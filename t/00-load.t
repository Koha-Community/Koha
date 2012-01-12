# This script is called by the pre-commit git hook to test modules compile

use strict;
use warnings;
use Test::More;
use File::Spec;
use File::Find;

my $lib = File::Spec->rel2abs('C4');
find({
    bydepth => 1,
    no_chdir => 1,
    wanted => sub {
        my $m = $_;
	    return unless $m =~ s/[.]pm$//;
	    $m =~ s{^.*/C4/}{C4/};	
	    $m =~ s{/}{::}g;
	    return if $m =~ /Auth_with_ldap/; # Dont test this, it will fail on use
	    return if $m =~ /Cache/; # Cache modules are a WIP, add the tests back when we are using them more
	    return if $m =~ /SIP/; # SIP modules will not load clean
	    return if $m =~ /C4::VirtualShelves$/; # Requires a DB
	    return if $m =~ /C4::Auth$/; # DB
	    return if $m =~ /C4::Tags$/; # DB
	    return if $m =~ /C4::Service/; # DB
	    return if $m =~ /C4::Auth_with_cas/; # DB
	    return if $m =~ /C4::BackgroundJob/; # DB
	    return if $m =~ /C4::UploadedFile/; # DB
	    return if $m =~ /C4::Record/; # DB
	    return if $m =~ /C4::Reports::Guided/; # DB
	    return if $m =~ /C4::Serials/; # DB
	    return if $m =~ /C4::VirtualShelves::Page/; # DB
        use_ok($m) || BAIL_OUT("***** PROBLEMS LOADING FILE '$m'");
    },
}, $lib);

$lib = File::Spec->rel2abs('Koha');
find(
    {
        bydepth  => 1,
        no_chdir => 1,
        wanted   => sub {
            my $m = $_;
            return unless $m =~ s/[.]pm$//;
            $m =~ s{^.*/Koha/}{Koha/};
            $m =~ s{/}{::}g;
            use_ok($m) || BAIL_OUT("***** PROBLEMS LOADING FILE '$m'");
        },
    },
    $lib
);


done_testing();
