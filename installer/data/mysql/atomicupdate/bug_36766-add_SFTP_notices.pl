use Modern::Perl;

return {
    bug_number  => "36766",
    description => "Add command-line utility to SFTP a file to a remote server",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO letter
            (module,code,branchcode,name,is_html,title,content,message_transport_type,lang)
            VALUES
            ('commandline', 'SFTP_FAILURE', '', 'File SFTP failed', 0, 'The SFTP by sftp_file.pl failed', 'SFTP upload failed:\n\n<<sftp_status>>', 'email', 'default'),
            ('commandline', 'SFTP_SUCCESS', '', 'File SFTP success', 0, 'The SFTP by sftp_file.pl was successful', 'SFTP upload succeeded', 'email', 'default')
        }
        );

        say $out "Added new sample notices 'SFTP_FAILURE' and 'SFTP_SUCCESS'";
    },
};
