use Modern::Perl;

return {
    bug_number  => "22435",
    description => "Update existing offsets",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        # Remove foreign key for offset types
        if ( foreign_key_exists( 'account_offsets', 'account_offsets_ibfk_t' ) ) {
            $dbh->do("ALTER TABLE account_offsets DROP FOREIGN KEY account_offsets_ibfk_t");
        }

        # Drop account_offset_types table
        $dbh->do("DROP TABLE IF EXISTS account_offset_types");

        # Update offset_types to 'CREATE' where appropriate
        $dbh->do(
            "UPDATE account_offsets SET type = 'CREATE' WHERE type != 'OVERDUE_INCREASE' AND type != 'OVERDUE_DECREASE' AND ( debit_id IS NULL OR credit_id IS NULL)"
        );
        $dbh->do("UPDATE account_offsets SET amount = ABS(amount) WHERE type = 'CREATE'");

        # Update offset_types to 'APPLY' where appropriate
        $dbh->do(
            "UPDATE account_offsets SET type = 'APPLY' WHERE type != 'OVERDUE_INCREASE' AND type != 'OVERDUE_DECREASE' AND type != 'CREATE' AND type != 'VOID'"
        );

        # Update table to ENUM
        $dbh->do(
            q{
                ALTER TABLE
                    `account_offsets`
                MODIFY COLUMN
                    `type` enum(
                        'CREATE',
                        'APPLY',
                        'VOID',
                        'OVERDUE_INCREASE',
                        'OVERDUE_DECREASE'
                    ) NOT NULL
                AFTER `debit_id`
              }
        );
    },
    }
