use Modern::Perl;

return {
    bug_number => "33028",
    description => "Fix wrongly formatted values for monetary values in circulation rules",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        my $rules = $dbh->selectall_arrayref(
            q|SELECT * FROM circulation_rules WHERE rule_name IN ('fine', 'overduefinescap', 'recall_overdue_fine', 'article_request_fee')|,
            { Slice => {} }
        );

        my $query = $dbh->prepare(
            "UPDATE circulation_rules SET rule_value = ? WHERE id = ?");

        my $error;
        for my $rule ( @{$rules} ) {
            my $library = defined($rule->{'branchcode'}) ? $rule->{'branchcode'} : "All";
            my $category = defined($rule->{'categorycode'}) ? $rule->{'categorycode'} : "All";
            my $itemtype = defined($rule->{'itemtype'}) ? $rule->{'itemtype'} : "All";
            if ( !( $rule->{'rule_value'} =~ /^[0-9.]*$/ )) {
                $error .= "Rule ID: $rule->{'id'} ($library-$category-$itemtype) \tRule: $rule->{'rule_name'}\tValue: $rule->{'rule_value'}\n";
            }
        }
        if ( $error ) {
            die("Circulation rules contain invalid monetary values:\n$error\nPlease fix these before you restart the update.");
        }
        say $out "Circulation rules have been validated. All circulation rule values are correctly formatted.";
    },
  };
