use Modern::Perl;

return {
    bug_number  => "28534",
    description => "Set pending_offline_operations INNoDB rather than MyISAM",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('pending_offline_operations') ) {
            $dbh->do(
                q{
                CREATE TABLE `pending_offline_operations` (
                `operationid` int(11) NOT NULL AUTO_INCREMENT,
                `userid` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
                `branchcode` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
                `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `action` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
                `barcode` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                `cardnumber` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                `amount` decimal(28,6) DEFAULT NULL,
                PRIMARY KEY (`operationid`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );
        } else {
            $dbh->do(
                q{
                ALTER TABLE pending_offline_operations ENGINE = 'InnoDB';
            }
            );
        }
    },
    }
