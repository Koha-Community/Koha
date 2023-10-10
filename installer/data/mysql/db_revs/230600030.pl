use Modern::Perl;

return {
    bug_number  => 28688,
    description => "Add notice MEMBERSHIP_RENEWED",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`)
VALUES ( 'members', 'MEMBERSHIP_RENEWED', '', 'Account renewal', 0, 'Account renewal', "[%- USE Price -%]\nDear [% borrower.title %] [% borrower.firstname %] [% borrower.surname %],\n\nYour library account has been renewed. The new expiry date is: [% borrower.dateexpiry %].\n\n[% IF borrower.category.enrolmentfee > 0 %]An enrollment fee of [% borrower.category.enrolmentfee | $Price with_symbol => 1 %] has been applied.\n\n[% END %]Thank you,\n\nYour library,\n\n[% branch.branchname %]", 'email', 'default' )
        }
        );
    },
};
