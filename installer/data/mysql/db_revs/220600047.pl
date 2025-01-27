use Modern::Perl;

return {
    bug_number  => "30025",
    description => "Split and rename BiblioAddsAuthorities system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my $biblio_adds_authorities = C4::Context->preference('BiblioAddsAuthorities');

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences
            ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('RequireChoosingExistingAuthority',?,NULL,'Require selecting existing authority entry in controlled fields during cataloging.','YesNo'),
            ('AutoLinkBiblios',?,NULL,'If enabled, link biblio to authorities on creation and edit','YesNo')
        }, undef, ( $biblio_adds_authorities eq '1' ? '0' : '1', $biblio_adds_authorities )
        );
        say $out "Added new system preference 'RequireChoosingExistingAuthority'";
        say $out "Added new system preference 'AutoLinkBiblios'";
        $dbh->do(q{DELETE FROM systempreferences WHERE variable="BiblioAddsAuthorities";});
        say $out "Removed system preference 'BiblioAddsAuthorities'";
    },
};
