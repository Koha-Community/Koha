use Modern::Perl;

return {
    bug_number  => "28489",
    description => "Modify sessions.a_session from longtext to longblob",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do('DELETE FROM sessions');
        $dbh->do('ALTER TABLE sessions MODIFY a_session LONGBLOB NOT NULL');
    },
    }
