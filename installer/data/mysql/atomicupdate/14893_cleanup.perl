# This perl snippet is run from within updatedatabase.pl
# Remove all temporary files from the obsolete koha_upload
# Bug 14893 replaces /tmp/koha_upload by /tmp/[db_name]_upload
# Permanent storage is not affected

use File::Path qw[remove_tree]; # perl core module
use File::Spec;

my $dbh= C4::Context->dbh;
$dbh->do(q|
    DELETE FROM uploaded_files
    WHERE COALESCE(permanent,0)=0 AND dir='koha_upload'
|);

my $tmp= File::Spec->tmpdir.'/koha_upload';
remove_tree( $tmp ) if -d $tmp;
