#!/usr/bin/perl

# script to test for missing systempreferences
# export KOHA_CONF
# export PERL5LIB
# then ./check_sysprefs.pl path  (if path is blank it will use .)

use strict;
use warnings;

use File::Find;

use C4::Context;

@ARGV = qw(.) unless @ARGV;

sub check_sys_pref {
    my $dbh   = C4::Context->dbh();
    my $query = "SELECT * FROM systempreferences WHERE variable = ?";
    my $sth   = $dbh->prepare($query);
    if ( !-d _ ) {
        my $name = $File::Find::name;
        if ( $name =~ /(\.pl|\.pm)$/ ) {
            open( FILE, "$_" ) || die "cant open $name";
            while ( my $inp = <FILE> ) {
                if ( $inp =~ /C4::Context->preference\((.*?)\)/ ) {
                    my $variable = $1;
                    $variable =~ s /\'|\"//g;
                    $sth->execute($variable);
                    if ( my $data = $sth->fetchrow_hashref() ) {
                        if ( $data->{variable} eq $variable ) {
                            next;
                        }
                    }
                    print
"$name has a reference to $variable, this does not exist in the database\n";
                }
            }
            close FILE;
        }
    }
    $sth->finish();
}

find( \&check_sys_pref, @ARGV );
