use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "30955",
    description => "Move existing list notices to new lists category",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{ UPDATE IGNORE letter SET module = 'lists' WHERE code = 'SHARE_ACCEPT'; });
        say_success( $out, "Moved SHARE_ACCEPT notice to lists module" );

        $dbh->do(q{ UPDATE IGNORE letter SET module = 'lists' WHERE code = 'SHARE_INVITE'; });
        say_success( $out, "Moved SHARE_INVITE notice to lists module" );

        $dbh->do(q{ UPDATE IGNORE letter SET module = 'lists' WHERE code = 'LIST'; });
        say_success( $out, "Moved LIST notice to lists module" );
    },
};
