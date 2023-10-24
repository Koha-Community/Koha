use Modern::Perl;

return {
    bug_number  => "31383",
    description => "Split the additional_contents table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( TableExists('additional_contents_localizations') ) {
            $dbh->do(
                q{
                ALTER TABLE additional_contents
                CHANGE COLUMN idnew `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for the additional content category'
            }
            );
            say $out "Renamed additional_contents.idnew with 'id'";

            $dbh->do(
                q{
                CREATE TABLE `additional_contents_localizations` (
                    `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'unique identifier for the additional content',
                    `additional_content_id` int(10) unsigned NOT NULL COMMENT 'link to the additional content',
                    `title` varchar(250) NOT NULL DEFAULT '' COMMENT 'title of the additional content',
                    `content` mediumtext NOT NULL COMMENT 'the body of your additional content',
                    `lang` varchar(50) NOT NULL DEFAULT '' COMMENT 'lang',
                    `updated_on` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'last modification',
                    PRIMARY KEY (`id`),
                    UNIQUE KEY `additional_contents_localizations_uniq` (`additional_content_id`,`lang`),
                    CONSTRAINT `additional_contents_localizations_ibfk1` FOREIGN KEY (`additional_content_id`) REFERENCES `additional_contents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say $out "Added new table 'additional_contents_localizations'";

            my $contents = $dbh->selectall_arrayref(
                q{SELECT MIN(id) AS id, category, code, branchcode FROM additional_contents GROUP BY category, code, branchcode},
                { Slice => {} }
            );
            my $sth_insert = $dbh->prepare(
                q{
                INSERT INTO additional_contents_localizations(additional_content_id, title, content, lang, updated_on)
                VALUES(?, ?, ?, ?, ?)
            }
            );
            for my $content (@$contents) {
                my $q = q{
                    SELECT title, content, lang, branchcode, updated_on
                    FROM additional_contents
                    WHERE category=? AND code=? AND
                };
                $q .= defined $content->{branchcode} ? " branchcode = ?" : " branchcode IS NULL";
                my $translated_contents = $dbh->selectall_arrayref(
                    $q, { Slice => {} }, $content->{category}, $content->{code},
                    defined $content->{branchcode} ? $content->{branchcode} : ()
                );
                for my $translated_content (@$translated_contents) {
                    $sth_insert->execute(
                        $content->{id}, $translated_content->{title}, $translated_content->{content},
                        $translated_content->{lang}, $translated_content->{updated_on}
                    );
                }

                # Delete duplicates
                $q = q{
                    DELETE FROM additional_contents
                    WHERE category=? AND code=? AND id<>? AND
                };
                $q .= defined $content->{branchcode} ? " branchcode = ?" : " branchcode IS NULL";
                $dbh->do( $q, undef, $content->{category}, $content->{code}, $content->{id}, $content->{branchcode} );
            }
            $dbh->do(
                q{
                ALTER TABLE additional_contents
                DROP INDEX additional_contents_uniq
            }
            );
            $dbh->do(
                q{
                ALTER TABLE additional_contents
                ADD UNIQUE KEY `additional_contents_uniq` (`category`,`code`,`branchcode`)
            }
            );
            $dbh->do(
                q{
                ALTER TABLE additional_contents
                DROP COLUMN title,
                DROP COLUMN content,
                DROP COLUMN lang
            }
            );
            say $out "Removed 'title', 'content', 'lang' columns from additional_contents";
        }

        my $notice_templates = $dbh->selectall_arrayref(
            q{
            SELECT id, module, code, content
            FROM letter
            WHERE content LIKE "%<news>%"
        }, { Slice => {} }
        );
        for my $template (@$notice_templates) {
            my $new_content = $template->{content};
            $new_content =~ s|<news>|[% FOR content IN additional_contents %]|g;
            $new_content =~ s|</news>|[% END %]|g;
            $new_content =~ s{<<\s*additional_contents\.title\s*>>}{[% content.title | html %]}g;
            $new_content =~ s{<<\s*additional_contents\.content\s*>>}{[% content.content | html %]}g;
            $new_content =~ s{<<\s*additional_contents\.published_on\s*>>}{[% content.published_on | \$KohaDates %]}g;
            $dbh->do(
                q{
                UPDATE letter
                SET content = ?
                WHERE id = ?
            }, undef, $new_content, $template->{id}
            );

            say $out "Adjusted notice template '" . $template->{code} . "'";
        }

        $notice_templates = $dbh->selectall_arrayref(
            q{
            SELECT id, code
            FROM letter
            WHERE content LIKE "%<<additional_content%" OR content LIKE "%<< additional_content%"
        }, { Slice => {} }
        );

        if (@$notice_templates) {
            say $out "WARNING - Some notice templates need manual adjustments!";
            for my $template (@$notice_templates) {
                say $out sprintf "\t %s (id=%s)", $template->{code}, $template->{id};
            }
        }

    },
};
