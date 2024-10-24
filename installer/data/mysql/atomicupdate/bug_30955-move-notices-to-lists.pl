use Modern::Perl;

return {
    bug_number  => "30955",
    description => "Move existing list-based notices to new lists category",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do( q{ UPDATE IGNORE letter SET module = 'lists' WHERE code = 'SHARE_ACCEPT'; } );
        say $out "Moved SHARE_ACCEPT notice to lists module";

        $dbh->do( q{ UPDATE IGNORE letter SET module = 'lists' WHERE code = 'SHARE_INVITE'; } );
        say $out "Moved SHARE_INVITE notice to lists module";
    },
};
