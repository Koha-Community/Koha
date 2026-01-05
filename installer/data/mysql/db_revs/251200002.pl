use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41409",
    description => "Convert streetnumber to tinytext in borrower_modifications",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( TableExists('borrower_modifications') ) {
            if ( column_exists( 'borrower_modifications', 'streetnumber' ) ) {
                $dbh->do(
                    q{
                        ALTER TABLE borrower_modifications CHANGE COLUMN streetnumber streetnumber tinytext DEFAULT NULL COMMENT 'the house number for your patron/borrower''s primary address';
                    }
                );
                say_success(
                    $out,
                    q{Column 'borrower_modifications.streetnumber' changed to tinytext'}
                );
                $dbh->do(
                    q{
                        ALTER TABLE borrower_modifications CHANGE COLUMN B_streetnumber B_streetnumber tinytext DEFAULT NULL COMMENT 'the house number for your patron/borrower''s alternate address';
                    }
                );
                say_success(
                    $out,
                    q{Column 'borrower_modifications.B_streetnumber' changed to tinytext'}
                );
            }
        }
    },
};
