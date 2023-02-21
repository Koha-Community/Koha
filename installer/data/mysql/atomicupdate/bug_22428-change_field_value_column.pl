use Modern::Perl;

return {
    bug_number => "22428",
    description => "Changes the datatype of the field value column to text to stop input being cut short",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            ALTER TABLE marc_modification_template_actions MODIFY COLUMN field_value text;
        });

        say $out "Amended dataype of column field_value in table marc_modification_template_actions.";
    },
};
