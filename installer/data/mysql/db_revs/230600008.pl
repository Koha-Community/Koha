use Modern::Perl;

return {
    bug_number => "33039",
    description => "Add published on template to serial subscriptions table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        if( !column_exists( 'subscription', 'published_on_template' ) ) {
          $dbh->do(q{
              ALTER TABLE subscription
              ADD COLUMN `published_on_template` TEXT DEFAULT NULL COMMENT 'Template Toolkit syntax to generate the default "Published on (text)" field when receiving an issue this serial'
              AFTER `ccode`
          });
        }
    },
};
