use Modern::Perl;

return {
    bug_number => "30226",
    description => "Add the system preference AllowSetAutomaticRenewal",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Add system preference AllowSetAutomaticRenewal
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` ) VALUES('AllowSetAutomaticRenewal', '1', '|yes|no', 'Allow or Prevent staff from flagging items for autorenewal on the checkout page', 'YesNo')
        });
        # Finished adding system preference AllowSetAutomaticRenewal
        say $out "Added system preference AllowSetAutomaticRenewal";
    },
};
