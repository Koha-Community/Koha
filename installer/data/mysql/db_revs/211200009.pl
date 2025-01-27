use Modern::Perl;

return {
    bug_number  => 29336,
    description => "Resize authorised value category fields to 32 chars",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my @sql_statements = (
            q|ALTER TABLE additional_fields CHANGE authorised_value_category authorised_value_category varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ''|,
            q|ALTER TABLE auth_subfield_structure CHANGE authorised_value authorised_value varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL|,
            q|ALTER TABLE auth_tag_structure CHANGE authorised_value authorised_value varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL|,
            q|ALTER TABLE club_template_enrollment_fields CHANGE authorised_value_category authorised_value_category varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL|,
            q|ALTER TABLE club_template_fields CHANGE authorised_value_category authorised_value_category varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL|,
            q|ALTER TABLE marc_tag_structure CHANGE authorised_value authorised_value varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL|,
        );
        foreach my $sql (@sql_statements) {
            $dbh->do($sql);
        }
    },
    }
