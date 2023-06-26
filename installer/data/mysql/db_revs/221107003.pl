use Modern::Perl;

return {
    bug_number => "34029",
    description => "Extend datatypes in biblioitems and deletedbiblioitems tables to avoid import errors",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE `biblioitems`
            MODIFY COLUMN `place` text DEFAULT NULL COMMENT 'publication place (MARC21 260$a and 264$a)'
        });
        say $out "Updated biblioitems.place to text";
        $dbh->do(q{
            ALTER TABLE `deletedbiblioitems`
            MODIFY COLUMN `place` text DEFAULT NULL COMMENT 'publication place (MARC21 260$a and 264$a)'
        });
        say $out "Updated deletedbiblioitems.place to text";

        $dbh->do(q{
            ALTER TABLE `biblioitems`
            MODIFY COLUMN `publishercode` text DEFAULT NULL COMMENT 'publisher (MARC21 260$b and 264$b)'
        });
        say $out "Updated biblioitems.publishercode to text";
        $dbh->do(q{
            ALTER TABLE `deletedbiblioitems`
            MODIFY COLUMN `publishercode` text DEFAULT NULL COMMENT 'publisher (MARC21 260$b and 264$b)'
        });
        say $out "Updated deletedbiblioitems.publishercode to text";

        $dbh->do(q{
            ALTER TABLE `biblioitems`
            MODIFY COLUMN `size` text DEFAULT NULL COMMENT 'material size (MARC21 300$c)'
        });
        say $out "Updated biblioitems.size to text";
        $dbh->do(q{
            ALTER TABLE `deletedbiblioitems`
            MODIFY COLUMN `size` text DEFAULT NULL COMMENT 'material size (MARC21 300$c)'
        });
        say $out "Updated deletedbiblioitems.size to text";

        $dbh->do(q{
            ALTER TABLE `biblioitems`
            MODIFY COLUMN `pages` text DEFAULT NULL COMMENT 'number of pages (MARC21 300$a)'
        });
        say $out "Updated biblioitems.pages to text";
        $dbh->do(q{
            ALTER TABLE `deletedbiblioitems`
            MODIFY COLUMN `pages` text DEFAULT NULL COMMENT 'number of pages (MARC21 300$a)'
        });
        say $out "Updated deletedbiblioitems.pages to text";

        $dbh->do(q{
            ALTER TABLE `biblioitems`
            MODIFY COLUMN `illus` text DEFAULT NULL COMMENT 'illustrations (MARC21 300$b)'
        });
        say $out "Updated biblioitems.illus to text";
        $dbh->do(q{
            ALTER TABLE `deletedbiblioitems`
            MODIFY COLUMN `illus` text DEFAULT NULL COMMENT 'illustrations (MARC21 300$b)'
        });
        say $out "Updated deletedbiblioitems.illus to text";

    },
};
