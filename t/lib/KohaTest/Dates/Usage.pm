package KohaTest::Dates::Usage;
use base qw( KohaTest::Dates );

use strict;
use warnings;

use Test::More;

use C4::Dates qw(format_date format_date_in_iso);


my %thash = (
    iso    => [ '2001-01-01',         '1989-09-21',         '1952-01-00' ],
    metric => [ "01-01-2001",         '21-09-1989',         '00-01-1952' ],
    us     => [ "01-01-2001",         '09-21-1989',         '01-00-1952' ],
    sql    => [ '20010101    010101', '19890921    143907', '19520100    000000' ],
);


my @formats = sort keys %thash;

sub check_formats : Test( 10 ) {
    my $self = shift;

    my $syspref = C4::Dates->new->format();
    ok( $syspref, "Your system preference is: $syspref" );

    foreach ( @{ $thash{'iso'} } ) {
        ok( format_date($_), "able to format_date() on $_" );
    }

    foreach ( @{ $thash{$syspref} } ) {
        ok( format_date_in_iso($_), "able to format_date_in_iso() on $_" );
    }
    ok( C4::Dates->today(), "(default) CLASS ->today : " . C4::Dates->today() );
}

sub defaults : Test( 24 ) {
    my $self = shift;

    foreach (@formats) {
        my $pre = sprintf '(%-6s)', $_;
        my $date = C4::Dates->new();
        ok( $date, "$pre Date Creation   : new()" );
        isa_ok( $date, 'C4::Dates' );
        ok( $_ eq $date->format($_),   "$pre format($_)      : " );
        ok( $date->visual(), "$pre visual()" );
        ok( $date->output(), "$pre output()" );
        ok( $date->today(),  "$pre object->today" );

    }
}

sub valid_inputs : Test( 108 ) {
    my $self = shift;

    foreach my $format (@formats) {
        my $pre = sprintf '(%-6s)', $format;
        foreach my $testval ( @{ $thash{$format} } ) {
            my ( $val, $today );
            my $date = C4::Dates->new( $testval, $format );
            ok( $date, "$pre Date Creation   : new('$testval','$format')" );
            isa_ok( $date, 'C4::Dates' );
            ok( $date->regexp, "$pre has regexp()" );
            ok( $val = $date->output(), describe( "$pre output()", $val ) );
            foreach ( grep { !/$format/ } @formats ) {
                ok( $today = $date->output($_), describe( sprintf( "$pre output(%8s)", "'$_'" ), $today ) );
            }
            ok( $today = $date->today(), describe( "$pre object->today", $today ) );
            ok( $val = $date->output(), describe( "$pre output()", $val ) );
        }
    }
}

sub independence_from_class : Test( 1 ) {
    my $self = shift;

    my $in1  = '12/25/1952';                       # us
    my $in2  = '13/01/2001';                       # metric
    my $d1   = C4::Dates->new( $in1, 'us' );
    my $d2   = C4::Dates->new( $in2, 'metric' );
    my $out1 = $d1->output('iso');
    my $out2 = $d2->output('iso');
    ok( $out1 ne $out2, "subsequent constructors get different dataspace ($out1 != $out2)" );

}



sub describe {
    my $front = sprintf( "%-25s", shift );
    my $tail = shift || 'FAILED';
    return "$front : $tail";
}

1;
