use Modern::Perl;

return {
    bug_number  => "27595",
    description => "Add system preference PlaceHoldsOnOrdersFromSuggestions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('PlaceHoldsOnOrdersFromSuggestions','0',NULL,'If ON, enables generation of holds when orders are placed from suggestions','YesNo')
        }
        );
        say $out "Added new system preference 'PlaceHoldsOnOrdersFromSuggestions'";
    },
};
