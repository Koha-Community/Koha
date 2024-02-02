use Modern::Perl;

return {
    bug_number  => "31791",
    description => "Add the ability to lock record modification",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
            ( 9, 'edit_locked_records', 'Edit locked records');
        }
        );
        say $out "Added new permission 'editcatalogue.edit_locked_records'";

        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
             ( 9, 'set_record_sources', 'Set record source for records');
        }
        );
        say $out "Added new permission 'editcatalogue.set_record_sources'";
    },
};
