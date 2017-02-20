#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use Getopt::Long;
use Fcntl qw(:flock);
use File::Temp qw/ tempdir /;
use File::Path;
use C4::Biblio;
use C4::AuthoritiesMarc;
use C4::Items;
use Koha::RecordProcessor;
use Koha::Caches;
use XML::LibXML;

use constant LOCK_FILENAME => 'rebuild..LCK';

# script that checks zebradir structure & create directories & mandatory files if needed
#
#

$|=1; # flushes output
# If the cron job starts us in an unreadable dir, we will break without
# this.
chdir $ENV{HOME} if (!(-r '.'));
my $daemon_mode;
my $daemon_sleep = 5;
my $directory;
my $nosanitize;
my $skip_export;
my $keep_export;
my $skip_index;
my $reset;
my $biblios;
my $authorities;
my $as_xml;
my $noshadow;
my $want_help;
my $process_zebraqueue;
my $process_zebraqueue_skip_deletes;
my $do_not_clear_zebraqueue;
my $length;
my $where;
my $offset;
my $run_as_root;
my $run_user = (getpwuid($<))[0];
my $wait_for_lock = 0;
my $use_flock;
my $table = 'biblioitems';
my $is_memcached = Koha::Caches->get_instance->memcached_cache;

my $verbose_logging = 0;
my $zebraidx_log_opt = " -v none,fatal,warn ";
my $result = GetOptions(
    'daemon'        => \$daemon_mode,
    'sleep:i'       => \$daemon_sleep,
    'd:s'           => \$directory,
    'r|reset'       => \$reset,
    's'             => \$skip_export,
    'k'             => \$keep_export,
    'I|skip-index'  => \$skip_index,
    'nosanitize'    => \$nosanitize,
    'b'             => \$biblios,
    'w'             => \$noshadow,
    'a'             => \$authorities,
    'h|help'        => \$want_help,
    'x'             => \$as_xml,
    'y'             => \$do_not_clear_zebraqueue,
    'z'             => \$process_zebraqueue,
    'skip-deletes'  => \$process_zebraqueue_skip_deletes,
    'where:s'       => \$where,
    'length:i'      => \$length,
    'offset:i'      => \$offset,
    'v+'            => \$verbose_logging,
    'run-as-root'   => \$run_as_root,
    'wait-for-lock' => \$wait_for_lock,
    't|table:s'     => \$table,
);

if (not $result or $want_help) {
    print_usage();
    exit 0;
}

if ( $as_xml ) {
    warn "Warning: You passed -x which is already the default and is now deprecated\n";
    undef $as_xml; # Should not be used later
}

if( not defined $run_as_root and $run_user eq 'root') {
    my $msg = "Warning: You are running this script as the user 'root'.\n";
    $msg   .= "If this is intentional you must explicitly specify this using the -run-as-root switch\n";
    $msg   .= "Please do '$0 --help' to see usage.\n";
    die $msg;
}

if ($process_zebraqueue and ($skip_export or $reset)) {
    my $msg = "Cannot specify -r or -s if -z is specified\n";
    $msg   .= "Please do '$0 --help' to see usage.\n";
    die $msg;
}

if ($process_zebraqueue and $do_not_clear_zebraqueue) {
    my $msg = "Cannot specify both -y and -z\n";
    $msg   .= "Please do '$0 --help' to see usage.\n";
    die $msg;
}

if ($daemon_mode) {
    # incompatible flags handled above: help, reset, and do_not_clear_zebraqueue
    if ($skip_export or $keep_export or $skip_index or
          $where or $length or $offset) {
        my $msg = "Cannot specify -s, -k, -I, -where, -length, or -offset with -daemon.\n";
        $msg   .= "Please do '$0 --help' to see usage.\n";
        die $msg;
    }
    unless ($is_memcached) {
        warn "Warning: script running in daemon mode, without recommended caching system (memcached).\n";
    }
    $authorities = 1;
    $biblios = 1;
    $process_zebraqueue = 1;
}

if (not $biblios and not $authorities) {
    my $msg = "Must specify -b or -a to reindex bibs or authorities\n";
    $msg   .= "Please do '$0 --help' to see usage.\n";
    die $msg;
}

our @tables_allowed_for_select = ( 'biblioitems', 'items', 'biblio' );
unless ( grep { /^$table$/ } @tables_allowed_for_select ) {
    die "Cannot specify -t|--table with value '$table'. Only "
      . ( join ', ', @tables_allowed_for_select )
      . " are allowed.";
}


#  -v is for verbose, which seems backwards here because of how logging is set
#    on the CLI of zebraidx.  It works this way.  The default is to not log much
if ($verbose_logging >= 2) {
    $zebraidx_log_opt = '-v none,fatal,warn,all';
}

my $use_tempdir = 0;
unless ($directory) {
    $use_tempdir = 1;
    $directory = tempdir(CLEANUP => ($keep_export ? 0 : 1));
}


my $biblioserverdir = C4::Context->zebraconfig('biblioserver')->{directory};
my $authorityserverdir = C4::Context->zebraconfig('authorityserver')->{directory};

my $kohadir = C4::Context->config('intranetdir');

my ($biblionumbertagfield,$biblionumbertagsubfield) = C4::Biblio::GetMarcFromKohaField("biblio.biblionumber","");
my ($biblioitemnumbertagfield,$biblioitemnumbertagsubfield) = C4::Biblio::GetMarcFromKohaField("biblioitems.biblioitemnumber","");

my $marcxml_open = q{<?xml version="1.0" encoding="UTF-8"?>
<collection xmlns="http://www.loc.gov/MARC21/slim">
};

my $marcxml_close = q{
</collection>
};

# Protect again simultaneous update of the zebra index by using a lock file.
# Create our own lock directory if it is missing. This should be created
# by koha-zebra-ctl.sh or at system installation. If the desired directory
# does not exist and cannot be created, we fall back on /tmp - which will
# always work.

my ($lockfile, $LockFH);
foreach (
    C4::Context->config("zebra_lockdir"),
    '/var/lock/zebra_' . C4::Context->config('database'),
    '/tmp/zebra_' . C4::Context->config('database')
) {
    #we try three possibilities (we really want to lock :)
    next if !$_;
    ($LockFH, $lockfile) = _create_lockfile($_.'/rebuild');
    last if defined $LockFH;
}
if( !defined $LockFH ) {
    print "WARNING: Could not create lock file $lockfile: $!\n";
    print "Please check your koha-conf.xml for ZEBRA_LOCKDIR.\n";
    print "Verify file permissions for it too.\n";
    $use_flock = 0; # we disable file locking now and will continue
                    # without it
                    # note that this mimics old behavior (before we used
                    # the lockfile)
};

if ( $verbose_logging ) {
    print "Zebra configuration information\n";
    print "================================\n";
    print "Zebra biblio directory      = $biblioserverdir\n";
    print "Zebra authorities directory = $authorityserverdir\n";
    print "Koha directory              = $kohadir\n";
    print "Lockfile                    = $lockfile\n" if $lockfile;
    print "BIBLIONUMBER in :     $biblionumbertagfield\$$biblionumbertagsubfield\n";
    print "BIBLIOITEMNUMBER in : $biblioitemnumbertagfield\$$biblioitemnumbertagsubfield\n";
    print "================================\n";
}

my $tester = XML::LibXML->new();
my $dbh;

# The main work is done here by calling do_one_pass().  We have added locking
# avoid race conditions between full rebuilds and incremental updates either from
# daemon mode or periodic invocation from cron.  The race can lead to an updated
# record being overwritten by a rebuild if the update is applied after the export
# by the rebuild and before the rebuild finishes (more likely to affect large
# catalogs).
#
# We have chosen to exit immediately by default if we cannot obtain the lock
# to prevent the potential for a infinite backlog from cron invocations, but an
# option (wait-for-lock) is provided to let the program wait for the lock.
# See http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11078 for details.
if ($daemon_mode) {
    while (1) {
        # For incremental updates, skip the update if the updates are locked
        if (_flock($LockFH, LOCK_EX|LOCK_NB)) {
            eval {
                $dbh = C4::Context->dbh;
                if( zebraqueue_not_empty() ) {
                    Koha::Caches->flush_L1_caches() if $is_memcached;
                    do_one_pass();
                }
            };
            if ($@ && $verbose_logging) {
                warn "Warning : $@\n";
            }
            _flock($LockFH, LOCK_UN);
        }
        sleep $daemon_sleep;
    }
} else {
    # all one-off invocations
    my $lock_mode = ($wait_for_lock) ? LOCK_EX : LOCK_EX|LOCK_NB;
    if (_flock($LockFH, $lock_mode)) {
        $dbh = C4::Context->dbh;
        do_one_pass();
        _flock($LockFH, LOCK_UN);
    } else {
        print "Skipping rebuild/update because flock failed on $lockfile: $!\n";
    }
}


if ( $verbose_logging ) {
    print "====================\n";
    print "CLEANING\n";
    print "====================\n";
}
if ($keep_export) {
    print "NOTHING cleaned : the export $directory has been kept.\n";
    print "You can re-run this script with the -s ";
    if ($use_tempdir) {
        print " and -d $directory parameters";
    } else {
        print "parameter";
    }
    print "\n";
    print "if you just want to rebuild zebra after changing zebra config files\n";
} else {
    unless ($use_tempdir) {
        # if we're using a temporary directory
        # created by File::Temp, it will be removed
        # automatically.
        rmtree($directory, 0, 1);
        print "directory $directory deleted\n";
    }
}

sub do_one_pass {
    if ($authorities) {
        index_records('authority', $directory, $skip_export, $skip_index, $process_zebraqueue, $nosanitize, $do_not_clear_zebraqueue, $verbose_logging, $zebraidx_log_opt, $authorityserverdir);
    } else {
        print "skipping authorities\n" if ( $verbose_logging );
    }

    if ($biblios) {
        index_records('biblio', $directory, $skip_export, $skip_index, $process_zebraqueue, $nosanitize, $do_not_clear_zebraqueue, $verbose_logging, $zebraidx_log_opt, $biblioserverdir);
    } else {
        print "skipping biblios\n" if ( $verbose_logging );
    }
}

# Check the zebra update queue and return true if there are records to process
# This routine will handle each of -ab, -a, or -b, but in practice we force
# -ab when in daemon mode.
sub zebraqueue_not_empty {
    my $where_str;

    if ($authorities && $biblios) {
        $where_str = 'done = 0;';
    } elsif ($biblios) {
        $where_str = 'server = "biblioserver" AND done = 0;';
    } else {
        $where_str = 'server = "authorityserver" AND done = 0;';
    }
    my $query =
        $dbh->prepare('SELECT COUNT(*) FROM zebraqueue WHERE ' . $where_str );

    $query->execute;
    my $count = $query->fetchrow_arrayref->[0];
    print "queued records: $count\n" if $verbose_logging > 0;
    return $count > 0;
}

# This checks to see if the zebra directories exist under the provided path.
# If they don't, then zebra is likely to spit the dummy. This returns true
# if the directories had to be created, false otherwise.
sub check_zebra_dirs {
    my ($base) = shift() . '/';
    my $needed_repairing = 0;
    my @dirs = ( '', 'key', 'register', 'shadow', 'tmp' );
    foreach my $dir (@dirs) {
        my $bdir = $base . $dir;
        if (! -d $bdir) {
            $needed_repairing = 1;
            mkdir $bdir || die "Unable to create '$bdir': $!\n";
            print "$0: needed to create '$bdir'\n";
        }
    }
    return $needed_repairing;
}   # ----------  end of subroutine check_zebra_dirs  ----------

sub index_records {
    my ($record_type, $directory, $skip_export, $skip_index, $process_zebraqueue, $nosanitize, $do_not_clear_zebraqueue, $verbose_logging, $zebraidx_log_opt, $server_dir) = @_;

    my $num_records_exported = 0;
    my $records_deleted = {};
    my $need_reset = check_zebra_dirs($server_dir);
    if ($need_reset) {
        print "$0: found broken zebra server directories: forcing a rebuild\n";
        $reset = 1;
    }
    if ($skip_export && $verbose_logging) {
        print "====================\n";
        print "SKIPPING $record_type export\n";
        print "====================\n";
    } else {
        if ( $verbose_logging ) {
            print "====================\n";
            print "exporting $record_type\n";
            print "====================\n";
        }
        mkdir "$directory" unless (-d $directory);
        mkdir "$directory/$record_type" unless (-d "$directory/$record_type");
        if ($process_zebraqueue) {
            my $entries;

            unless ( $process_zebraqueue_skip_deletes ) {
                $entries = select_zebraqueue_records($record_type, 'deleted');
                mkdir "$directory/del_$record_type" unless (-d "$directory/del_$record_type");
                $records_deleted = generate_deleted_marc_records($record_type, $entries, "$directory/del_$record_type");
                mark_zebraqueue_batch_done($entries);
            }

            $entries = select_zebraqueue_records($record_type, 'updated');
            mkdir "$directory/upd_$record_type" unless (-d "$directory/upd_$record_type");
            $num_records_exported = export_marc_records_from_list($record_type,$entries, "$directory/upd_$record_type", $records_deleted);
            mark_zebraqueue_batch_done($entries);

        } else {
            my $sth = select_all_records($record_type);
            $num_records_exported = export_marc_records_from_sth($record_type, $sth, "$directory/$record_type", $nosanitize);
            unless ($do_not_clear_zebraqueue) {
                mark_all_zebraqueue_done($record_type);
            }
        }
    }

    #
    # and reindexing everything
    #
    if ($skip_index) {
        if ($verbose_logging) {
            print "====================\n";
            print "SKIPPING $record_type indexing\n";
            print "====================\n";
        }
    } else {
        if ( $verbose_logging ) {
            print "====================\n";
            print "REINDEXING zebra\n";
            print "====================\n";
        }
        my $record_fmt = 'marcxml';
        if ($process_zebraqueue) {
            do_indexing($record_type, 'adelete', "$directory/del_$record_type", $reset, $noshadow, $record_fmt, $zebraidx_log_opt)
                if %$records_deleted;
            do_indexing($record_type, 'update', "$directory/upd_$record_type", $reset, $noshadow, $record_fmt, $zebraidx_log_opt)
                if $num_records_exported;
        } else {
            do_indexing($record_type, 'update', "$directory/$record_type", $reset, $noshadow, $record_fmt, $zebraidx_log_opt)
                if ($num_records_exported or $skip_export);
        }
    }
}


sub select_zebraqueue_records {
    my ($record_type, $update_type) = @_;

    my $server = ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';
    my $op = ($update_type eq 'deleted') ? 'recordDelete' : 'specialUpdate';

    my $sth = $dbh->prepare("SELECT id, biblio_auth_number
                             FROM zebraqueue
                             WHERE server = ?
                             AND   operation = ?
                             AND   done = 0
                             ORDER BY id DESC");
    $sth->execute($server, $op);
    my $entries = $sth->fetchall_arrayref({});
}

sub mark_all_zebraqueue_done {
    my ($record_type) = @_;

    my $server = ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';

    my $sth = $dbh->prepare("UPDATE zebraqueue SET done = 1
                             WHERE server = ?
                             AND done = 0");
    $sth->execute($server);
}

sub mark_zebraqueue_batch_done {
    my ($entries) = @_;

    $dbh->{AutoCommit} = 0;
    my $sth = $dbh->prepare("UPDATE zebraqueue SET done = 1 WHERE id = ?");
    $dbh->commit();
    foreach my $id (map { $_->{id} } @$entries) {
        $sth->execute($id);
    }
    $dbh->{AutoCommit} = 1;
}

sub select_all_records {
    my $record_type = shift;
    return ($record_type eq 'biblio') ? select_all_biblios() : select_all_authorities();
}

sub select_all_authorities {
    my $strsth=qq{SELECT authid FROM auth_header};
    $strsth.=qq{ WHERE $where } if ($where);
    $strsth.=qq{ LIMIT $length } if ($length && !$offset);
    $strsth.=qq{ LIMIT $offset,$length } if ($length && $offset);
    my $sth = $dbh->prepare($strsth);
    $sth->execute();
    return $sth;
}

sub select_all_biblios {
    $table = 'biblioitems'
      unless grep { /^$table$/ } @tables_allowed_for_select;
    my $strsth = qq{ SELECT biblionumber FROM $table };
    $strsth.=qq{ WHERE $where } if ($where);
    $strsth.=qq{ LIMIT $length } if ($length && !$offset);
    $strsth.=qq{ LIMIT $offset,$length } if ($offset);
    my $sth = $dbh->prepare($strsth);
    $sth->execute();
    return $sth;
}

sub export_marc_records_from_sth {
    my ($record_type, $sth, $directory, $nosanitize) = @_;

    my $num_exported = 0;
    open my $fh, '>:encoding(UTF-8) ', "$directory/exported_records" or die $!;

    print {$fh} $marcxml_open;

    my $i = 0;
    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber",'');
    while (my ($record_number) = $sth->fetchrow_array) {
        print "." if ( $verbose_logging );
        print "\r$i" unless ($i++ %100 or !$verbose_logging);
        if ( $nosanitize ) {
            my $marcxml = $record_type eq 'biblio'
                          ? GetXmlBiblio( $record_number )
                          : GetAuthorityXML( $record_number );
            if ($record_type eq 'biblio'){
                my @items = GetItemsInfo($record_number);
                if (@items){
                    my $record = MARC::Record->new;
                    $record->encoding('UTF-8');
                    my @itemsrecord;
                    foreach my $item (@items){
                        my $record = Item2Marc($item, $record_number);
                        push @itemsrecord, $record->field($itemtag);
                    }
                    $record->insert_fields_ordered(@itemsrecord);
                    my $itemsxml = $record->as_xml_record();
                    $marcxml =
                        substr($marcxml, 0, length($marcxml)-10) .
                        substr($itemsxml, index($itemsxml, "</leader>\n", 0) + 10);
                }
            }
            # extra test to ensure that result is valid XML; otherwise
            # Zebra won't parse it in DOM mode
            eval {
                my $doc = $tester->parse_string($marcxml);
            };
            if ($@) {
                warn "Error exporting record $record_number ($record_type): $@\n";
                next;
            }
            if ( $marcxml ) {
                $marcxml =~ s!<\?xml version="1.0" encoding="UTF-8"\?>\n!!;
                print {$fh} $marcxml;
                $num_exported++;
            }
            next;
        }
        my ($marc) = get_corrected_marc_record($record_type, $record_number);
        if (defined $marc) {
            eval {
                my $rec = $marc->as_xml_record(C4::Context->preference('marcflavour'));
                eval {
                    my $doc = $tester->parse_string($rec);
                };
                if ($@) {
                    die "invalid XML: $@";
                }
                $rec =~ s!<\?xml version="1.0" encoding="UTF-8"\?>\n!!;
                print {$fh} $rec;
                $num_exported++;
            };
            if ($@) {
                warn "Error exporting record $record_number ($record_type) XML";
                warn "... specific error is $@" if $verbose_logging;
            }
        }
    }
    print "\nRecords exported: $num_exported\n" if ( $verbose_logging );
    print {$fh} $marcxml_close;

    close $fh;
    return $num_exported;
}

sub export_marc_records_from_list {
    my ($record_type, $entries, $directory, $records_deleted) = @_;

    my $num_exported = 0;
    open my $fh, '>:encoding(UTF-8)', "$directory/exported_records" or die $!;

    print {$fh} $marcxml_open;

    my $i = 0;

    # Skip any deleted records. We check for this anyway, but this reduces error spam
    my %found = %$records_deleted;
    foreach my $record_number ( map { $_->{biblio_auth_number} }
                                grep { !$found{ $_->{biblio_auth_number} }++ }
                                @$entries ) {
        print "." if ( $verbose_logging );
        print "\r$i" unless ($i++ %100 or !$verbose_logging);
        my ($marc) = get_corrected_marc_record($record_type, $record_number);
        if (defined $marc) {
            eval {
                my $rec = $marc->as_xml_record(C4::Context->preference('marcflavour'));
                $rec =~ s!<\?xml version="1.0" encoding="UTF-8"\?>\n!!;
                print {$fh} $rec;
                $num_exported++;
            };
            if ($@) {
              warn "Error exporting record $record_number ($record_type) XML";
            }
        }
    }
    print "\nRecords exported: $num_exported\n" if ( $verbose_logging );

    print {$fh} $marcxml_close;

    close $fh;
    return $num_exported;
}

sub generate_deleted_marc_records {

    my ($record_type, $entries, $directory) = @_;

    my $records_deleted = {};
    open my $fh, '>:encoding(UTF-8)', "$directory/exported_records" or die $!;

    print {$fh} $marcxml_open;

    my $i = 0;
    foreach my $record_number (map { $_->{biblio_auth_number} } @$entries ) {
        print "\r$i" unless ($i++ %100 or !$verbose_logging);
        print "." if ( $verbose_logging );

        my $marc = MARC::Record->new();
        if ($record_type eq 'biblio') {
            fix_biblio_ids($marc, $record_number, $record_number);
        } else {
            fix_authority_id($marc, $record_number);
        }
        if (C4::Context->preference("marcflavour") eq "UNIMARC") {
            fix_unimarc_100($marc);
        }

        my $rec = $marc->as_xml_record(C4::Context->preference('marcflavour'));
        # Remove the record's XML header
        $rec =~ s!<\?xml version="1.0" encoding="UTF-8"\?>\n!!;
        print {$fh} $rec;

        $records_deleted->{$record_number} = 1;
    }
    print "\nRecords exported: $i\n" if ( $verbose_logging );

    print {$fh} $marcxml_close;

    close $fh;
    return $records_deleted;
}

sub get_corrected_marc_record {
    my ( $record_type, $record_number ) = @_;

    my $marc = get_raw_marc_record( $record_type, $record_number );

    if ( defined $marc ) {
        fix_leader($marc);
        if ( $record_type eq 'authority' ) {
            fix_authority_id( $marc, $record_number );
        }
        elsif ( $record_type eq 'biblio' ) {

            my @filters;
            push @filters, 'EmbedItemsAvailability';
            push @filters, 'EmbedSeeFromHeadings'
                if C4::Context->preference('IncludeSeeFromInSearches');

            my $normalizer = Koha::RecordProcessor->new( { filters => \@filters } );
            $marc = $normalizer->process($marc);
        }
        if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {
            fix_unimarc_100($marc);
        }
    }

    return $marc;
}

sub get_raw_marc_record {
    my ($record_type, $record_number) = @_;

    my $marc;
    if ($record_type eq 'biblio') {
        eval { $marc = C4::Biblio::GetMarcBiblio({ biblionumber => $record_number, embed_items => 1 }); };
        if ($@ || !$marc) {
            # here we do warn since catching an exception
            # means that the bib was found but failed
            # to be parsed
            warn "error retrieving biblio $record_number";
            return;
        }
    } else {
        eval { $marc = GetAuthority($record_number); };
        if ($@) {
            warn "error retrieving authority $record_number";
            return;
        }
    }
    return $marc;
}

sub fix_leader {
    # FIXME - this routine is suspect
    # It blanks the Leader/00-05 and Leader/12-16 to
    # force them to be recalculated correct when
    # the $marc->as_usmarc() or $marc->as_xml() is called.
    # But why is this necessary?  It would be a serious bug
    # in MARC::Record (definitely) and MARC::File::XML (arguably)
    # if they are emitting incorrect leader values.
    my $marc = shift;

    my $leader = $marc->leader;
    substr($leader,  0, 5) = '     ';
    substr($leader, 10, 7) = '22     ';
    $marc->leader(substr($leader, 0, 24));
}

sub fix_biblio_ids {
    # FIXME - it is essential to ensure that the biblionumber is present,
    #         otherwise, Zebra will choke on the record.  However, this
    #         logic belongs in the relevant C4::Biblio APIs.
    my $marc = shift;
    my $biblionumber = shift;
    my $biblioitemnumber;
    if (@_) {
        $biblioitemnumber = shift;
    } else {
        my $sth = $dbh->prepare(
            "SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
        $sth->execute($biblionumber);
        ($biblioitemnumber) = $sth->fetchrow_array;
        $sth->finish;
        unless ($biblioitemnumber) {
            warn "failed to get biblioitemnumber for biblio $biblionumber";
            return 0;
        }
    }

    # FIXME - this is cheating on two levels
    # 1. C4::Biblio::_koha_marc_update_bib_ids is meant to be an internal function
    # 2. Making sure that the biblionumber and biblioitemnumber are correct and
    #    present in the MARC::Record object ought to be part of GetMarcBiblio.
    #
    # On the other hand, this better for now than what rebuild_zebra.pl used to
    # do, which was duplicate the code for inserting the biblionumber
    # and biblioitemnumber
    C4::Biblio::_koha_marc_update_bib_ids($marc, '', $biblionumber, $biblioitemnumber);

    return 1;
}

sub fix_authority_id {
    # FIXME - as with fix_biblio_ids, the authid must be present
    #         for Zebra's sake.  However, this really belongs
    #         in C4::AuthoritiesMarc.
    my ($marc, $authid) = @_;
    unless ($marc->field('001') and $marc->field('001')->data() eq $authid){
        $marc->delete_field($marc->field('001'));
        $marc->insert_fields_ordered(MARC::Field->new('001',$authid));
    }
}

sub fix_unimarc_100 {
    # FIXME - again, if this is necessary, it belongs in C4::AuthoritiesMarc.
    my $marc = shift;

    my $string;
    my $length_100a = length($marc->subfield( 100, "a" ));
    if (  $length_100a and $length_100a == 36 ) {
        $string = $marc->subfield( 100, "a" );
        my $f100 = $marc->field(100);
        $marc->delete_field($f100);
    }
    else {
        $string = POSIX::strftime( "%Y%m%d", localtime );
        $string =~ s/\-//g;
        $string = sprintf( "%-*s", 35, $string );
    }
    substr( $string, 22, 6, "frey50" );
    $length_100a = length($marc->subfield( 100, "a" ));
    unless ( $length_100a and $length_100a == 36 ) {
        $marc->delete_field($marc->field(100));
        $marc->insert_grouped_field(MARC::Field->new( 100, "", "", "a" => $string ));
    }
}

sub do_indexing {
    my ($record_type, $op, $record_dir, $reset_index, $noshadow, $record_format, $zebraidx_log_opt) = @_;

    my $zebra_server  = ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';
    my $zebra_db_name = ($record_type eq 'biblio') ? 'biblios' : 'authorities';
    my $zebra_config  = C4::Context->zebraconfig($zebra_server)->{'config'};
    my $zebra_db_dir  = C4::Context->zebraconfig($zebra_server)->{'directory'};

    $noshadow //= '';

    if ($noshadow or $reset_index) {
        $noshadow = '-n';
    }

    system("zebraidx -c $zebra_config $zebraidx_log_opt -g $record_format -d $zebra_db_name init") if $reset_index;
    system("zebraidx -c $zebra_config $zebraidx_log_opt $noshadow -g $record_format -d $zebra_db_name $op $record_dir");
    system("zebraidx -c $zebra_config $zebraidx_log_opt -g $record_format -d $zebra_db_name commit") unless $noshadow;
}

sub _flock {
    # test if flock is present; if so, use it; if not, return true
    # op refers to the official flock operations including LOCK_EX,
    # LOCK_UN, etc.
    # combining LOCK_EX with LOCK_NB returns immediately
    my ($fh, $op)= @_;
    if( !defined($use_flock) ) {
        #check if flock is present; if not, you will have a fatal error
        my $lock_acquired = eval { flock($fh, $op) };
        # assuming that $fh and $op are fine(..), an undef $lock_acquired
        # means no flock
        $use_flock = defined($lock_acquired) ? 1 : 0;
        print "Warning: flock could not be used!\n" if $verbose_logging && !$use_flock;
        return 1 if !$use_flock;
        return $lock_acquired;
    } else {
        return 1 if !$use_flock;
        return flock($fh, $op);
    }
}

sub _create_lockfile { #returns undef on failure
    my $dir= shift;
    unless (-d $dir) {
        eval { mkpath($dir, 0, oct(755)) };
        return if $@;
    }
    return if !open my $fh, q{>}, $dir.'/'.LOCK_FILENAME;
    return ( $fh, $dir.'/'.LOCK_FILENAME );
}

sub print_usage {
    print <<_USAGE_;
$0: reindex MARC bibs and/or authorities in Zebra.

Use this batch job to reindex all biblio or authority
records in your Koha database.

Parameters:

    -b                      index bibliographic records

    -a                      index authority records

    -daemon                 Run in daemon mode.  The program will loop checking
                            for entries on the zebraqueue table, processing
                            them incrementally if present, and then sleep
                            for a few seconds before repeating the process
                            Checking the zebraqueue table is done with a cheap
                            SQL query.  This allows for near realtime update of
                            the zebra search index with low system overhead.
                            Use -sleep to control the checking interval.

                            Daemon mode implies -z, -a, -b.  The program will
                            refuse to start if options are present that do not
                            make sense while running as an incremental update
                            daemon (e.g. -r or -offset).

    -sleep 10               Seconds to sleep between checks of the zebraqueue
                            table in daemon mode.  The default is 5 seconds.

    -z                      select only updated and deleted
                            records marked in the zebraqueue
                            table.  Cannot be used with -r
                            or -s.

    --skip-deletes          only select record updates, not record
                            deletions, to avoid potential excessive
                            I/O when zebraidx processes deletions.
                            If this option is used for normal indexing,
                            a cronjob should be set up to run
                            rebuild_zebra.pl -z without --skip-deletes
                            during off hours.
                            Only effective with -z.

    -r                      clear Zebra index before
                            adding records to index. Implies -w.

    -d                      Temporary directory for indexing.
                            If not specified, one is automatically
                            created.  The export directory
                            is automatically deleted unless
                            you supply the -k switch.

    -k                      Do not delete export directory.

    -s                      Skip export.  Used if you have
                            already exported the records
                            in a previous run.

    -nosanitize             export biblio/authority records directly from DB marcxml
                            field without sanitizing records. It speed up
                            dump process but could fail if DB contains badly
                            encoded records. Works only with -x,

    -w                      skip shadow indexing for this batch

    -y                      do NOT clear zebraqueue after indexing; normally,
                            after doing batch indexing, zebraqueue should be
                            marked done for the affected record type(s) so that
                            a running zebraqueue_daemon doesn't try to reindex
                            the same records - specify -y to override this.
                            Cannot be used with -z.

    -v                      increase the amount of logging.  Normally only
                            warnings and errors from the indexing are shown.
                            Use log level 2 (-v -v) to include all Zebra logs.

    --length   1234         how many biblio you want to export
    --offset 1243           offset you want to start to
                                example: --offset 500 --length=500 will result in a LIMIT 500,1000 (exporting 1000 records, starting by the 500th one)
                                note that the numbers are NOT related to biblionumber, that's the intended behaviour.
    --where                 let you specify a WHERE query, like itemtype='BOOK'
                            or something like that

    --run-as-root           explicitily allow script to run as 'root' user

    --wait-for-lock         when not running in daemon mode, the default
                            behavior is to abort a rebuild if the rebuild
                            lock is busy.  This option will cause the program
                            to wait for the lock to free and then continue
                            processing the rebuild request,

    --table                 specify a table (can be items, biblioitems or biblio) to retrieve biblionumber to index.
                            biblioitems is the default value.

    --help or -h            show this message.
_USAGE_
}
