package Koha::Installer;

use Modern::Perl;

require Koha;
require Koha::Database;
require Koha::Config;

=head1 API

=head2 Class methods

=head3 needs_update

Determines if an update is needed by checking
the database version, the code version, and whether
there are any atomic updates available.

=cut

sub needs_update {
    my $needs_update = 1;
    my $dbh          = Koha::Database::dbh();
    my $sql          = "SELECT value FROM systempreferences WHERE variable = 'Version'";
    my $sth          = $dbh->prepare($sql);
    $sth->execute();
    my $row          = $sth->fetchrow_arrayref();
    my $db_version   = $row->[0];
    my $koha_version = Koha->version;
    my $code_version = TransformToNum($koha_version);

    if ( $db_version == $code_version ) {
        $needs_update = 0;
    }

    #NOTE: We apply atomic updates even when the DB and code versions align
    my $atomic_updates = get_atomic_updates();
    if (@$atomic_updates) {
        $needs_update = 1;
    }

    return $needs_update;
}

=head3 TransformToNum

Transform the Koha version from a 4 parts string
to a number, with just 1 .

=cut

sub TransformToNum {
    my $version = shift;

    # remove the 3 last . to have a Perl number
    $version =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;

    return $version;
}

=head3 get_atomic_updates

Get atomic database updates

=cut

sub get_atomic_updates {
    my @atomic_upate_files;

    my $conf_fname  = Koha::Config->guess_koha_conf;
    my $config      = Koha::Config->get_instance($conf_fname);
    my $intranetdir = $config->{config}->{intranetdir};

    # if there is anything in the atomicupdate, read and execute it.
    my $update_dir = $intranetdir . '/installer/data/mysql/atomicupdate/';
    opendir( my $dirh, $update_dir );
    my @stuff = sort readdir $dirh;
    foreach my $file (@stuff) {
        next if $file !~ /\.(perl|pl)$/;                               #skip other files
        next if $file eq 'skeleton.perl' || $file eq 'skeleton.pl';    # skip the skeleton files

        push @atomic_upate_files, $file;
    }
    return \@atomic_upate_files;
}

1;
