use Modern::Perl;

return {
    bug_number => '11844',
    description => 'Add column additional_fields.marcfield_mode',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        unless ( column_exists( 'additional_fields', 'marcfield_mode' ) ) {
            $dbh->do(q{
                ALTER TABLE additional_fields
                ADD COLUMN marcfield_mode ENUM('get', 'set') NOT NULL DEFAULT 'get' COMMENT 'mode of operation (get or set) for marcfield' AFTER marcfield
            });
        }
        say $out "Added column 'additional_fields.marcfield";
    },
};
