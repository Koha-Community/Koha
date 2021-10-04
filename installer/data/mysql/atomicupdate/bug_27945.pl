use Modern::Perl;

return {
    bug_number  => "27945",
    description => "Add max_daily_article_requests circulation rule",
    up          => sub {
        my ($args) = @_;
        my ($dbh)  = @$args{qw(dbh)};

        # Do you stuffs here
        $dbh->do(q{
            INSERT IGNORE INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value)
            VALUES (NULL, NULL, NULL, 'max_daily_article_requests', NULL);
        });
    },
  }
