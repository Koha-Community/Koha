use Modern::Perl;

return {
    bug_number  => "29557",
    description => "Add auto_account_expired to AUTO_RENEWALS notice",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my @c = $dbh->do(
            q{
            UPDATE letter
            SET content=REPLACE(content, "[% ELSIF checkout.auto_renew_error == 'too_unseen' %]\r\nThis item must be renewed at the library.\r\n[% END %]", "[% ELSIF checkout.auto_renew_error == 'too_unseen' %]\r\nThis item must be renewed at the library.\r\n[% ELSIF checkout.auto_renew_error == 'auto_account_expired' %]\r\nYour account has expired.\r\n[% END %]")
            WHERE code="AUTO_RENEWALS"
        }
        );
        say $out "Please update your AUTO_RENEWALS notice manually if you have changed or translated it";
    },
    }
