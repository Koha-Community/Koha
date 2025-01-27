use Modern::Perl;

return {
    bug_number  => "24387",
    description => "Rename opac_news with additional_contents",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        if ( TableExists('opac_news') ) {
            $dbh->do(
                q|
                ALTER TABLE opac_news RENAME additional_contents
            |
            );
        }

        if ( foreign_key_exists( 'additional_contents', 'opac_news_branchcode_ibfk' ) ) {

            $dbh->do(
                q|
                ALTER TABLE additional_contents
                DROP KEY borrowernumber_fk,
                DROP KEY opac_news_branchcode_ibfk,
                DROP FOREIGN KEY borrowernumber_fk,
                DROP FOREIGN KEY opac_news_branchcode_ibfk
            |
            );

            $dbh->do(
                q|
                ALTER TABLE additional_contents
                ADD CONSTRAINT  additional_contents_borrowernumber_fk
                    FOREIGN KEY (borrowernumber)
                    REFERENCES borrowers (borrowernumber) ON DELETE SET NULL ON UPDATE CASCADE
            |
            );

            $dbh->do(
                q|
                ALTER TABLE additional_contents
                ADD CONSTRAINT  additional_contents_branchcode_ibfk
                    FOREIGN KEY (branchcode)
                    REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
            |
            );
        }

        $dbh->do(
            q|
            UPDATE letter
            SET content = REGEXP_REPLACE(content, '<<\\\\s*opac_news\.', '<<additional_contents.')
        |
        );
        $dbh->do(
            q|
            UPDATE letter
            SET content = REGEXP_REPLACE(content, '\\\\[%\\\\s*opac_news\.', '[% additional_contents.')
        |
        );

        $dbh->do(
            q|
            UPDATE systempreferences
            SET variable="AdditionalContentsEditor"
            WHERE variable="NewsToolEditor"
        |
        );

        $dbh->do(
            q|
            UPDATE permissions
            SET code="edit_additional_contents"
            WHERE code="edit_news"
        |
        );

        unless ( column_exists( 'additional_contents', 'category' ) ) {
            $dbh->do(
                q|
                ALTER TABLE additional_contents
                ADD COLUMN `category` VARCHAR(20) NOT NULL COMMENT 'category for the additional content'
                AFTER `idnew`
            |
            );
        }
        unless ( column_exists( 'additional_contents', 'location' ) ) {
            $dbh->do(
                q|
                ALTER TABLE additional_contents
                ADD COLUMN `location` VARCHAR(255) NOT NULL COMMENT 'location of the additional content'
                AFTER `category`
            |
            );
        }

        unless ( column_exists( 'additional_contents', 'code' ) ) {
            $dbh->do(
                q|
                ALTER TABLE additional_contents
                ADD COLUMN `code` VARCHAR(100) NOT NULL COMMENT 'code to group content per lang'
                AFTER `category`
            |
            );
        }

        my $contents = $dbh->selectall_arrayref( q|SELECT * FROM additional_contents|, { Slice => {} } );
        for my $c (@$contents) {
            my ( $category, $location, $new_lang );
            if ( $c->{lang} eq '' ) {
                $category = 'news';
                $location = 'staff_and_opac';
                $new_lang = 'default';
            } elsif ( $c->{lang} eq 'koha' ) {
                $category = 'news';
                $location = 'staff_only';
                $new_lang = 'default';
            } elsif ( $c->{lang} eq 'slip' ) {
                $category = 'news';
                $location = 'slip';
                $new_lang = 'default';
            } elsif ( $c->{lang} =~ m|_| ) {
                ( $location, $new_lang ) = split '_', $c->{lang};
                $category = 'html_customizations';
            } else {
                $category = 'news';
                $location = 'opac_only';
                $new_lang = $c->{lang};
            }

            die "There is something wrong here, we didn't find a valid category for idnew=" . $c->{idnew}
                unless $category;

            # Now this is getting weird
            # We are adding an extra news with the same code when the lang is not "default" (/"en")

            my $sth_update = $dbh->prepare(
                q|
                UPDATE additional_contents
                SET category=?, location=?, lang=?
                WHERE idnew=?
            |
            );

            my $parent_idnew;
            if ( $new_lang ne 'default' ) {
                $dbh->do(
                    q|
                    INSERT INTO additional_contents(category, code, location, branchcode, title, content, lang, published_on, updated_on, expirationdate, number, borrowernumber)
                    VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                |, undef, $category, 'tmp_code', $location, $c->{branchcode}, $c->{title}, '', 'default',
                    $c->{published_on}, $c->{updated_on}, $c->{expirationdate}, $c->{number}, $c->{borrowernumber}
                );

                $parent_idnew = $dbh->last_insert_id( undef, undef, 'additional_contents', undef );
            }
            $sth_update->execute( $category, $location, $new_lang, $c->{idnew} );

            my $idnew = $parent_idnew || $c->{idnew};
            my $code =
                ( grep { $_ eq $location } qw( staff_and_opac staff_only opac_only slip ) )
                ? "${location}_$idnew"
                : "News_$idnew";
            $dbh->do( q|UPDATE additional_contents SET code=? WHERE idnew = ?|, undef, $code, $parent_idnew )
                if $parent_idnew;
            $dbh->do( q|UPDATE additional_contents SET code=? WHERE idnew = ?|, undef, $code, $c->{idnew} );
        }

        $dbh->do(
            q|
            ALTER TABLE additional_contents
            ADD UNIQUE KEY additional_contents_uniq (`category`,`code`,`branchcode`,`lang`)
        |
        );

    },
    }
