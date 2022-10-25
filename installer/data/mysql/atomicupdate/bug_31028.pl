use Modern::Perl;

return {
    bug_number => "31028",
    description => "Add a way to record users concerns about catalog records",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless ( TableExists('tickets') ) {
            $dbh->do(q{
                CREATE TABLE IF NOT EXISTS `tickets` (
                  `id` int(11) NOT NULL auto_increment COMMENT 'primary key',
                  `reporter_id` int(11) NOT NULL DEFAULT 0 COMMENT 'id of the patron who reported the ticket',
                  `reported_date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time this ticket was reported',
                  `title` text NOT NULL COMMENT 'ticket title',
                  `body` text NOT NULL COMMENT 'ticket details',
                  `resolver_id` int(11) DEFAULT NULL COMMENT 'id of the user who resolved the ticket',
                  `resolved_date` datetime DEFAULT NULL COMMENT 'date and time this ticket was resolved',
                  `biblio_id` int(11) DEFAULT NULL COMMENT 'id of biblio linked',
                  PRIMARY KEY(`id`),
                  CONSTRAINT `tickets_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                  CONSTRAINT `tickets_ibfk_2` FOREIGN KEY (`resolver_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                  CONSTRAINT `tickets_ibfk_3` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });

            say $out "Added new table 'tickets'";
        }

        unless ( TableExists('ticket_updates') ) {
            $dbh->do(q{
                CREATE TABLE IF NOT EXISTS `ticket_updates` (
                  `id` int(11) NOT NULL auto_increment COMMENT 'primary key',
                  `ticket_id` int(11) NOT NULL COMMENT 'id of catalog ticket the update relates to',
                  `user_id` int(11) NOT NULL DEFAULT 0 COMMENT 'id of the user who logged the update',
                  `public` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean flag to denote whether this update is public',
                  `date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time this update was logged',
                  `message` text NOT NULL COMMENT 'update message content',
                  PRIMARY KEY(`id`),
                  CONSTRAINT `ticket_updates_ibfk_1` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
                  CONSTRAINT `ticket_updates_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });

            say $out "Added new table 'ticket_updates'";
        }

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
                ('OpacCatalogConcerns', '0', NULL, 'Allow logged in OPAC users to report catalog concerns', 'YesNo')
            }
        );
        say $out "`OpacCatalogConcerns` preference added";

        if ( ( $dbh->selectrow_array('SELECT COUNT(*) FROM additional_contents WHERE location=?', undef, 'CatalogConcernHelp') )[0] == 0 ) { # Check to make idempotent
            $dbh->do(
                q{
                    INSERT INTO additional_contents ( category, code, location, title, content, lang, published_on, expirationdate, number ) VALUES ('html_customizations', 'CatalogConcernHelp_1', 'CatalogConcernHelp', 'Catalog concern help text', 'Please describe your concern clearly and the library will try to deal with it as quickly as possible', 'default', CAST(NOW() AS date), '2099-01-10', 1 )
                }
            );
            say $out "`CatalogConcernHelp` block added to html_customization";
        }

        if ( ( $dbh->selectrow_array('SELECT COUNT(*) FROM additional_contents WHERE location=?', undef, 'CatalogConcernTemplate') )[0] == 0 ) { # Check to make idempotent
            my $cc_template = <<~ 'END_TEMPLATE';
            **Describe the concern**
            A clear and concise description of what the concern is.

            **To Reproduce**
            Steps to reproduce the behavior:
            1. Go to '...'
            2. Click on '....'
            3. Scroll down to '....'
            4. See error

            **Expected behavior**
            A clear and concise description of what you expected to happen.
            END_TEMPLATE

            $dbh->do(
                qq{
                    INSERT INTO additional_contents ( category, code, location, title, content, lang, published_on, expirationdate, number ) VALUES ('html_customizations', 'CatalogConcernTemplate_1', 'CatalogConcernTemplate', 'Catalog concern template text', "$cc_template", 'default', CAST(NOW() AS date), '2099-01-10', 1 )
                }
            );
            say $out "`CatalogConcernTemplate` block added to html_customization";
        }

        $dbh->do(
            q{
                INSERT IGNORE INTO letter(module,code,branchcode,name,is_html,title,content,message_transport_type)
                VALUES ( 'catalog', 'TICKET_ACKNOWLEDGEMENT', '', 'Concern acknowledgement', '1', 'Catalog concern acknowledgement', "Dear [% INCLUDE 'patron-title.inc' patron => ticket.reporter %],\r\n\r\nThankyou for your report concerning [% INCLUDE 'biblio-title.inc' biblio=ticket.biblio link = 0 %].\r\n\r\nYou reported: \r\n[% ticket.body %]\r\n\r\nThankyou", 'email' );
            }
        );
        say $out "Added new notice 'TICKET_ACKNOWLEDGEMENT'";
    }
}
