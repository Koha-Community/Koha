use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "28915",
    description => "Increase from_subfield to allow two characters",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{ALTER TABLE marc_modification_template_actions MODIFY from_subfield VARCHAR(2)});

        # Print useful stuff here
        # tables
        say $out "Modifying marc_modification_template_actions.from_subfield to VARCHAR(2)";

        # Other information
        say_success( $out, "Modified marc_modification_template_actions.from_subfield to VARCHAR(2)" );

    },
};
