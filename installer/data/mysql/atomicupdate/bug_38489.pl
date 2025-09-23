use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "38489",
    description => "Migrate EDI transport configuration to use the new file_transports system",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Check if file_transports table exists (should exist from Bug 39190)
        my $sth = $dbh->prepare("SHOW TABLES LIKE 'file_transports'");
        $sth->execute();
        if ( !$sth->fetchrow_array ) {
            say_failure( $out, "file_transports table not found. Please ensure Bug 39190 is applied first." );
            return;
        }

        # Add file_transport_id column to vendor_edi_accounts
        if ( !column_exists( 'vendor_edi_accounts', 'file_transport_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE vendor_edi_accounts
                ADD COLUMN file_transport_id int(11) DEFAULT NULL AFTER plugin,
                ADD KEY `vendor_edi_accounts_file_transport_id` (`file_transport_id`),
                ADD CONSTRAINT `vendor_edi_accounts_ibfk_file_transport`
                    FOREIGN KEY (`file_transport_id`) REFERENCES `file_transports` (`file_transport_id`)
                    ON DELETE SET NULL ON UPDATE CASCADE
            }
            );
            say_success( $out, "Added file_transport_id column to vendor_edi_accounts table" );
        }

        # Add 'local' to the transport enum in file_transports table
        $dbh->do(
            q{
            ALTER TABLE file_transports
            MODIFY COLUMN transport ENUM('ftp','sftp','local') NOT NULL DEFAULT 'sftp'
        }
        );
        say_success( $out, "Added 'local' transport type to file_transports table" );

        # Migrate existing EDI transport configurations to file_transports
        my $migration_count  = 0;
        my $edi_accounts_sth = $dbh->prepare(
            q{
            SELECT id, description, host, username, password, upload_port, download_port,
                   upload_directory, download_directory, transport
            FROM vendor_edi_accounts
            WHERE file_transport_id IS NULL
              AND host IS NOT NULL
              AND host != ''
        }
        );
        $edi_accounts_sth->execute();

        my $insert_transport_sth = $dbh->prepare(
            q{
            INSERT INTO file_transports (name, host, port, transport, user_name, password,
                                       upload_directory, download_directory, auth_mode, passive, debug)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'password', 1, 0)
        }
        );

        my $update_edi_account_sth = $dbh->prepare(
            q{
            UPDATE vendor_edi_accounts SET file_transport_id = ? WHERE id = ?
        }
        );

        while ( my $row = $edi_accounts_sth->fetchrow_hashref ) {

            # Determine appropriate port (default to SFTP=22, FTP=21, Local=NULL)
            my $port = $row->{upload_port} || $row->{download_port};
            unless ($port) {
                if ( uc( $row->{transport} ) eq 'SFTP' ) {
                    $port = 22;
                } elsif ( uc( $row->{transport} ) eq 'FILE' ) {
                    $port = undef;    # Local transport doesn't use ports
                } else {
                    $port = 21;       # FTP default
                }
            }

            # Map transport type (normalize case and handle FILE -> local)
            my $transport_type = lc( $row->{transport} );
            $transport_type = 'local' if $transport_type eq 'file';
            $transport_type = 'ftp' unless $transport_type =~ /^(sftp|local)$/;

            # Create transport name from EDI account description
            my $transport_name = sprintf( "EDI Transport for %s", $row->{description} );

            # Handle host for local transport
            my $host = $row->{host};
            $host = 'localhost' if $transport_type eq 'local' && !$host;

            # Insert new file transport
            $insert_transport_sth->execute(
                $transport_name,
                $host,
                $port,
                $transport_type,
                $row->{username},
                $row->{password},    # Password is already encrypted in EDI accounts
                $row->{upload_directory},
                $row->{download_directory}
            );

            my $transport_id = $dbh->last_insert_id( undef, undef, 'file_transports', 'file_transport_id' );

            # Update EDI account to reference the new transport
            $update_edi_account_sth->execute( $transport_id, $row->{id} );

            $migration_count++;
        }

        if ( $migration_count > 0 ) {
            say_success(
                $out,
                "Successfully migrated $migration_count EDI transport configurations to file_transports"
            );
        } else {
            say_info( $out, "No EDI transport configurations found to migrate" );
        }

        # Drop the old transport-related columns from vendor_edi_accounts
        my @columns_to_drop =
            qw(host username password upload_port download_port upload_directory download_directory transport);

        for my $column (@columns_to_drop) {
            if ( column_exists( 'vendor_edi_accounts', $column ) ) {
                $dbh->do("ALTER TABLE vendor_edi_accounts DROP COLUMN $column");
                say_success( $out, "Dropped column '$column' from vendor_edi_accounts table" );
            }
        }

        say_success( $out, "EDI transport migration completed successfully" );
    },
};
