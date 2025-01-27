package Koha::MoreUtils;

use Modern::Perl;

# From  List::MoreUtils v4.0
sub singleton {
    my %seen = ();
    my $k;
    my $seen_undef;
    grep { 1 == ( defined $_ ? $seen{ $k = $_ } : $seen_undef ) }
        grep { defined $_ ? not $seen{ $k = $_ }++ : not $seen_undef++ } @_;
}

1;
