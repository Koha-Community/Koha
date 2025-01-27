use Modern::Perl;

return {
    bug_number  => "34657",
    description => "Update MARC frameworks to use renamed UNIMARC plugin (unimarc_field_123defg.pl)",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE `marc_subfield_structure` SET `value_builder` = 'unimarc_field_123defg.pl' WHERE (`value_builder` = 'unimarc_field_123d.pl' OR `value_builder` = 'unimarc_field_123e.pl' OR `value_builder` = 'unimarc_field_123f.pl' OR `value_builder` = 'unimarc_field_123g.pl' );
        }
        );

        say $out
            "Update complete: MARC subfields which were configured to use unimarc_field123d.pl, unimarc_field123e.pl, unimarc_field123f.pl, or unimarc_field123g.pl will now use unimarc_field123defg.pl";

    },
};
