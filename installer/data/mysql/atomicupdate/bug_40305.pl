use Modern::Perl;

return {
    bug_number  => "40305",
    description => "Fix 'collected' vs 'tendered' variables in notice templates",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Templates that can receive 'tendered' and 'change' variables via substitute parameters
        # Based on analysis of pos/pay.pl, pos/printreceipt.pl, and members/paycollect.pl
        my @affected_templates = ( 'RECEIPT', 'ACCOUNT_CREDIT' );

        # Replace 'collected' with 'tendered' in all affected templates
        # Handle various spacing and formatting variations
        my @patterns = (
            [ '[% collected',        '[% tendered' ],
            [ '[%collected',         '[%tendered' ],
            [ '[%  collected',       '[%  tendered' ],
            [ '[%\t+collected',      '[%\t+tendered' ],
            [ 'collected | $Price',  'tendered | $Price' ],
            [ 'collected|$Price',    'tendered|$Price' ],
            [ 'collected | \$Price', 'tendered | \$Price' ],
            [ 'collected|\$Price',   'tendered|\$Price' ],
        );

        my $total_updated = 0;

        foreach my $template_code (@affected_templates) {
            my $template_updated = 0;

            foreach my $pattern (@patterns) {
                my ( $old, $new ) = @$pattern;

                my $sth = $dbh->prepare(
                    "UPDATE letter SET content = REPLACE(content, ?, ?) WHERE code = ? AND content LIKE ?");

                my $affected = $sth->execute( $old, $new, $template_code, "%$old%" );
                if ( $affected && $affected > 0 ) {
                    $template_updated += $affected;
                }
            }

            # Additional cleanup - handle any remaining 'collected' references
            # This covers edge cases where 'collected' might appear in other contexts
            my $cleanup_sth = $dbh->prepare(
                "UPDATE letter SET content = REPLACE(content, 'collected', 'tendered')
                 WHERE code = ? AND content LIKE '%collected%'
                 AND content NOT LIKE '%tendered%'"
            );
            my $cleanup_affected = $cleanup_sth->execute($template_code);
            if ( $cleanup_affected && $cleanup_affected > 0 ) {
                $template_updated += $cleanup_affected;
            }

            if ( $template_updated > 0 ) {
                say $out
                    "Updated $template_updated $template_code notice templates to use 'tendered' instead of 'collected'";
                $total_updated += $template_updated;
            }
        }

        if ( $total_updated == 0 ) {
            say $out "No templates needed updating for 'collected' to 'tendered' conversion";
        }

        # Verify the fix worked for all affected templates
        my $remaining_total = 0;
        foreach my $template_code (@affected_templates) {
            my $remaining_sth =
                $dbh->prepare("SELECT COUNT(*) FROM letter WHERE code = ? AND content LIKE '%collected%'");
            $remaining_sth->execute($template_code);
            my ($remaining) = $remaining_sth->fetchrow_array();

            if ( $remaining > 0 ) {
                say $out
                    "Warning: $remaining $template_code templates still contain 'collected' references - manual review may be needed";
                $remaining_total += $remaining;
            }
        }

        if ( $remaining_total == 0 ) {
            say $out "Successfully converted all 'collected' references to 'tendered' in payment notice templates";
        }
    },
};
