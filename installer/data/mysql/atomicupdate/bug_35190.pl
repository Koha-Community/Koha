use Modern::Perl;

return {
    bug_number  => "35190",
    description => "Allow null values for authorized_value_category in additional_fields",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Set NULL as the default value
        $dbh->do(
            q{ALTER TABLE additional_fields MODIFY COLUMN authorised_value_category varchar(32) DEFAULT NULL COMMENT 'is an authorised value category'}
        );

        # Update any existing rows
        $dbh->do(q{UPDATE additional_fields SET authorised_value_category=NULL WHERE authorised_value_category=''});

        # tables
        say $out "Altered authorized_value_category in additional_fields to set NULL as the default value";

    },
};
