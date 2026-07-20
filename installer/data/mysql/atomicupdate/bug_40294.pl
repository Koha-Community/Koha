use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40294",
    description => "Add print notices for account expiry, if not defined",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $expiry_notice_content = 'Dear [% borrower.firstname %] [% borrower.surname %],

Your library card will expire soon, on:

[% borrower.dateexpiry %]

Thank you,

[% branch.branchname %]';

        # Add print letter template for account expiry notice, if one is not already defined
        my $result = $dbh->do(
            q{
                INSERT IGNORE INTO letter(module, code, name, is_html, title, content, message_transport_type, lang)
                VALUES (
                    'members',
                    'MEMBERSHIP_EXPIRY',
                    'Account expiration',
                    0,
                    'Account expiration',
                    ?,
                    'print',
                    'default'
                )
            },
            undef,
            $expiry_notice_content
        );

        if ( $result == 1 ) {
            say_success( $out, "Added default print notice template for MEMBERSHIP_EXPIRY" );
        } else {
            say_info( $out, "Print notice template MEMBERSHIP_EXPIRY already exists - no changes required" );
        }

        my $renewal_notice_content = '[%- USE Price -%]
Dear [% borrower.title %] [% borrower.firstname %] [% borrower.surname %],

Your library account has been renewed. The new expiry date is: [% borrower.dateexpiry %].
[% IF borrower.category.enrolmentfee > 0 %]\nAn enrollment fee of [% borrower.category.enrolmentfee | $Price with_symbol => 1 %] has been applied.\n[% END %]
Thank you,

Your library,

[% branch.branchname %]';

        # Add print letter template for account renewal notice, if one is not already defined
        $result = $dbh->do(
            q{
                INSERT IGNORE INTO letter(module, code, name, is_html, title, content, message_transport_type, lang)
                VALUES (
                    'members',
                    'MEMBERSHIP_RENEWED',
                    'Account renewal',
                    0,
                    'Account renewal',
                    ?,
                    'print',
                    'default'
                )
            },
            undef,
            $renewal_notice_content
        );

        if ( $result == 1 ) {
            say_success( $out, "Added default print notice template for MEMBERSHIP_RENEWAL" );
        } else {
            say_info( $out, "Print notice template MEMBERSHIP_RENEWAL already exists - no changes required" );
        }

    },
};
