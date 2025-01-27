use Modern::Perl;

return {
    bug_number  => "14237",
    description => "Add individual bibliographic records to course reserves",
    up          => sub {
        my ($args) = @_;
        my $dbh    = $args->{dbh};
        my $out    = $args->{out};

        unless ( column_exists( 'course_items', 'biblionumber' ) ) {
            $dbh->do(q{ ALTER TABLE course_items ADD `biblionumber` int(11) AFTER `itemnumber` });

            $dbh->do(
                q{
                UPDATE course_items
                LEFT JOIN items ON items.itemnumber=course_items.itemnumber
                SET course_items.biblionumber=items.biblionumber
                WHERE items.itemnumber IS NOT NULL
            }
            );

            $dbh->do(q{ ALTER TABLE course_items MODIFY COLUMN `biblionumber` INT(11) NOT NULL });

            $dbh->do(
                q{ ALTER TABLE course_items ADD CONSTRAINT `fk_course_items_biblionumber` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE }
            );
            $dbh->do(q{ ALTER TABLE course_items CHANGE `itemnumber` `itemnumber` int(11) DEFAULT NULL });

            say $out "Add course_items.biblionumber column";
            say $out "Add fk_course_items_biblionumber constraint";
            say $out "Change course_items.itemnumber to allow NULL values";
        }
    },
    }
