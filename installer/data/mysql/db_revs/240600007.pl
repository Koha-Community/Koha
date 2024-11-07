use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36330",
    description => "Fix typo 'reseve' in COMMENTs for table  course_items",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Update columns, only changing the COMMENT
        $dbh->do(
            q{ ALTER TABLE course_items MODIFY `location` varchar(80) DEFAULT NULL COMMENT 'new shelving location for the item to have while on reserve (optional)' }
        );
        say_success( $out, "Comment for course_items.location was updated." );

        $dbh->do(
            q{ ALTER TABLE course_items MODIFY `enabled` enum('yes','no') NOT NULL DEFAULT 'no' COMMENT 'if at least one enabled course has this item on reserve, this field will be ''yes'', otherwise it will be ''no''' }
        );
        say_success( $out, "Comment for course_items.enabled was updated." );
    },
};
