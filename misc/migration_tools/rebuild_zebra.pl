#!/usr/bin/perl

use strict;

use C4::Context;
use Getopt::Long;
use File::Temp qw/ tempdir /;
use File::Path;
use C4::Biblio;
use C4::AuthoritiesMarc;

# 
# script that checks zebradir structure & create directories & mandatory files if needed
#
#

$|=1; # flushes output

my $directory;
my $skip_export;
my $keep_export;
my $reset;
my $biblios;
my $authorities;
my $noxml;
my $noshadow;
my $do_munge;
my $want_help;
my $as_xml;
my $process_zebraqueue;
my $do_not_clear_zebraqueue;
my $result = GetOptions(
    'd:s'           => \$directory,
    'reset'         => \$reset,
    's'             => \$skip_export,
    'k'             => \$keep_export,
    'b'             => \$biblios,
    'noxml'         => \$noxml,
    'w'             => \$noshadow,
    'munge-config'  => \$do_munge,
    'a'             => \$authorities,
    'h|help'        => \$want_help,
	'x'				=> \$as_xml,
    'y'             => \$do_not_clear_zebraqueue,
    'z'             => \$process_zebraqueue,
);


if (not $result or $want_help) {
    print_usage();
    exit 0;
}

if (not $biblios and not $authorities) {
    my $msg = "Must specify -b or -a to reindex bibs or authorities\n";
    $msg   .= "Please do '$0 --help' to see usage.\n";
    die $msg;
}

if ($authorities and $as_xml) {
    my $msg = "Cannot specify both -a and -x\n";
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

if ($noshadow) {
    $noshadow = ' -n ';
}
my $use_tempdir = 0;
unless ($directory) {
    $use_tempdir = 1;
    $directory = tempdir(CLEANUP => ($keep_export ? 0 : 1));
} 


my $biblioserverdir = C4::Context->zebraconfig('biblioserver')->{directory};
my $authorityserverdir = C4::Context->zebraconfig('authorityserver')->{directory};

my $kohadir = C4::Context->config('intranetdir');
my $dbh = C4::Context->dbh;
my ($biblionumbertagfield,$biblionumbertagsubfield) = &GetMarcFromKohaField("biblio.biblionumber","");
my ($biblioitemnumbertagfield,$biblioitemnumbertagsubfield) = &GetMarcFromKohaField("biblioitems.biblioitemnumber","");

print "Zebra configuration information\n";
print "================================\n";
print "Zebra biblio directory      = $biblioserverdir\n";
print "Zebra authorities directory = $authorityserverdir\n";
print "Koha directory              = $kohadir\n";
print "BIBLIONUMBER in :     $biblionumbertagfield\$$biblionumbertagsubfield\n";
print "BIBLIOITEMNUMBER in : $biblioitemnumbertagfield\$$biblioitemnumbertagsubfield\n";
print "================================\n";

if ($do_munge) {
    munge_config();
}

$dbh->{AutoCommit} = 0; # don't autocommit - want a consistent view of the zebraqueue table

if ($authorities) {
    index_records('authority', $directory, $skip_export, $process_zebraqueue, $as_xml, $noxml, $do_not_clear_zebraqueue);
    $dbh->commit(); # commit changes to zebraqueue, if any
} else {
    print "skipping authorities\n";
}

if ($biblios) {
    index_records('biblio', $directory, $skip_export, $process_zebraqueue, $as_xml, $noxml, $do_not_clear_zebraqueue);
    $dbh->commit(); # commit changes to zebraqueue, if any
} else {
    print "skipping biblios\n";
}


print "====================\n";
print "CLEANING\n";
print "====================\n";
if ($keep_export) {
    print "NOTHING cleaned : the export $directory has been kept.\n";
    print "You can re-run this script with the -s ";
    if ($use_tempdir) {
        print " and -d $directory parameters";
    } else {
        print "parameter";
    }
    print "\n";
    print "if you just want to rebuild zebra after changing the record.abs\n";
    print "or another zebra config file\n";
} else {
    unless ($use_tempdir) {
        # if we're using a temporary directory
        # created by File::Temp, it will be removed
        # automatically.
        rmtree($directory, 0, 1);
        print "directory $directory deleted\n";
    }
}

sub index_records {
    my ($record_type, $directory, $skip_export, $process_zebraqueue, $as_xml, $noxml, $do_not_clear_zebraqueue) = @_;

    my $num_records_exported = 0;
    my $num_records_deleted = 0;
    if ($skip_export) {
        print "====================\n";
        print "SKIPPING $record_type export\n";
        print "====================\n";
    } else {
        print "====================\n";
        print "exporting $record_type\n";
        print "====================\n";
        mkdir "$directory" unless (-d $directory);
        mkdir "$directory/$record_type" unless (-d "$directory/$record_type");
        if ($process_zebraqueue) {
            my $sth = select_zebraqueue_records($record_type, 'deleted');
            mkdir "$directory/del_$record_type" unless (-d "$directory/del_$record_type");
            $num_records_deleted = generate_deleted_marc_records($record_type, $sth, "$directory/del_$record_type", $as_xml);
            mark_zebraqueue_done($record_type, 'deleted');
            $sth = select_zebraqueue_records($record_type, 'updated');
            mkdir "$directory/upd_$record_type" unless (-d "$directory/upd_$record_type");
            $num_records_exported = export_marc_records($record_type, $sth, "$directory/upd_$record_type", $as_xml, $noxml);
            mark_zebraqueue_done($record_type, 'updated');
        } else {
            my $sth = select_all_records($record_type);
            unless ($do_not_clear_zebraqueue) {
                mark_zebraqueue_done($record_type, 'deleted');
                mark_zebraqueue_done($record_type, 'updated');
            }
            $num_records_exported = export_marc_records($record_type, $sth, "$directory/$record_type", $as_xml, $noxml);
        }
    }
    
    #
    # and reindexing everything
    #
    print "====================\n";
    print "REINDEXING zebra\n";
    print "====================\n";
	my $record_fmt = ($as_xml) ? 'marcxml' : 'iso2709' ;
    if ($process_zebraqueue) {
        do_indexing($record_type, 'delete', "$directory/del_$record_type", $reset, $noshadow, $record_fmt) 
            if $num_records_deleted;
        do_indexing($record_type, 'update', "$directory/upd_$record_type", $reset, $noshadow, $record_fmt)
            if $num_records_exported;
    } else {
        do_indexing($record_type, 'update', "$directory/$record_type", $reset, $noshadow, $record_fmt)
            if $num_records_exported;
    }
}

sub select_zebraqueue_records {
    my ($record_type, $update_type) = @_;

    my $server = ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';
    my $op = ($update_type eq 'deleted') ? 'recordDelete' : 'specialUpdate';

    my $sth = $dbh->prepare("SELECT DISTINCT biblio_auth_number 
                             FROM zebraqueue
                             WHERE server = ?
                             AND   operation = ?
                             AND   done = 0");
    $sth->execute($server, $op);
    return $sth;
}

sub mark_zebraqueue_done {
    my ($record_type, $update_type) = @_;

    my $server = ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';
    my $op = ($update_type eq 'deleted') ? 'recordDelete' : 'specialUpdate';

    if ($op eq 'recordDelete') {
        my $sth = $dbh->prepare("UPDATE zebraqueue SET done = 1
                                 WHERE id IN (
                                    SELECT id FROM (
                                        SELECT z1.id
                                        FROM zebraqueue z1
                                        JOIN zebraqueue z2 ON z2.biblio_auth_number = z1.biblio_auth_number
                                        WHERE z1.done = 0
                                        AND   z1.server = ?
                                        AND   z2.done = 0
                                        AND   z2.server = ?
                                        AND   z1.operation = ?
                                    ) d2
                                 )
                                ");
        $sth->execute($server, $server, $op); # if we've deleted a record, any prior specialUpdates are void
    } else {
        my $sth = $dbh->prepare("UPDATE zebraqueue SET done = 1
                                 WHERE server = ?
                                 AND   operation = ?
                                 AND   done = 0");
        $sth->execute($server, $op); 
    }
}

sub select_all_records {
    my $record_type = shift;
    return ($record_type eq 'biblio') ? select_all_biblios() : select_all_authorities();
}

sub select_all_authorities {
    my $sth = $dbh->prepare("SELECT authid FROM auth_header");
    $sth->execute();
    return $sth;
}

sub select_all_biblios {
    my $sth = $dbh->prepare("SELECT biblionumber FROM biblioitems ORDER BY biblionumber");
    $sth->execute();
    return $sth;
}

sub export_marc_records {
    my ($record_type, $sth, $directory, $as_xml, $noxml) = @_;

    my $num_exported = 0;
    open (OUT, ">:utf8 ", "$directory/exported_records") or die $!;
    my $i = 0;
    while (my ($record_number) = $sth->fetchrow_array) {
        print ".";
        print "\r$i" unless ($i++ %100);
        my ($marc) = get_corrected_marc_record($record_type, $record_number, $noxml);
        if (defined $marc) {
            # FIXME - when more than one record is exported and $as_xml is true,
            # the output file is not valid XML - it's just multiple <record> elements
            # strung together with no single root element.  zebraidx doesn't seem
            # to care, though, at least if you're using the GRS-1 filter.  It does
            # care if you're using the DOM filter, which requires valid XML file(s).
            print OUT ($as_xml) ? $marc->as_xml_record() : $marc->as_usmarc();
            $num_exported++;
        }
    }
    print "\nRecords exported: $num_exported\n";
    close OUT;
    return $num_exported;
}

sub generate_deleted_marc_records {
    my ($record_type, $sth, $directory, $as_xml) = @_;

    my $num_exported = 0;
    open (OUT, ">:utf8 ", "$directory/exported_records") or die $!;
    my $i = 0;
    while (my ($record_number) = $sth->fetchrow_array) {
        print "\r$i" unless ($i++ %100);
        print ".";

        my $marc = MARC::Record->new();
        if ($record_type eq 'biblio') {
            fix_biblio_ids($marc, $record_number, $record_number);
        } else {
            fix_authority_id($marc, $record_number);
        }
        if (C4::Context->preference("marcflavour") eq "UNIMARC") {
            fix_unimarc_100($marc);
        }

        print OUT ($as_xml) ? $marc->as_xml_record() : $marc->as_usmarc();
        $num_exported++;
    }
    print "\nRecords exported: $num_exported\n";
    close OUT;
    return $num_exported;
    

}

sub get_corrected_marc_record {
    my ($record_type, $record_number, $noxml) = @_;

    my $marc = get_raw_marc_record($record_type, $record_number, $noxml); 

    if (defined $marc) {
        fix_leader($marc);
        if ($record_type eq 'biblio') {
            my $succeeded = fix_biblio_ids($marc, $record_number);
            return unless $succeeded;
        } else {
            fix_authority_id($marc, $record_number);
        }
        if (C4::Context->preference("marcflavour") eq "UNIMARC") {
            fix_unimarc_100($marc);
        }
    }

    return $marc;
}

sub get_raw_marc_record {
    my ($record_type, $record_number, $noxml) = @_;
  
    my $marc; 
    if ($record_type eq 'biblio') {
        if ($noxml) {
            my $fetch_sth = $dbh->prepare_cached("SELECT marc FROM biblioitems WHERE biblionumber = ?");
            $fetch_sth->execute($record_number);
            if (my ($blob) = $fetch_sth->fetchrow_array) {
                $marc = MARC::Record->new_from_usmarc($blob);
            } else {
                warn "failed to retrieve biblio $record_number";
            }
            $fetch_sth->finish();
        } else {
            eval { $marc = GetMarcBiblio($record_number); };
            if ($@) {
                warn "failed to retrieve biblio $record_number";
                return;
            }
        }
    } else {
        eval { $marc = GetAuthority($record_number); };
        if ($@) {
            warn "failed to retrieve authority $record_number";
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
    if ( length($marc->subfield( 100, "a" )) == 35 ) {
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
    unless ( length($marc->subfield( 100, "a" )) == 35 ) {
        $marc->delete_field($marc->field(100));
        $marc->insert_grouped_field(MARC::Field->new( 100, "", "", "a" => $string ));
    }
}

sub do_indexing {
    my ($record_type, $op, $record_dir, $reset_index, $noshadow, $record_format) = @_;

    my $zebra_server  = ($record_type eq 'biblio') ? 'biblioserver' : 'authorityserver';
    my $zebra_db_name = ($record_type eq 'biblio') ? 'biblios' : 'authorities';
    my $zebra_config  = C4::Context->zebraconfig($zebra_server)->{'config'};
    my $zebra_db_dir  = C4::Context->zebraconfig($zebra_server)->{'directory'};

    system("zebraidx -c $zebra_config -g $record_format -d $zebra_db_name init") if $reset_index;
    system("zebraidx -c $zebra_config $noshadow -g $record_format -d $zebra_db_name $op $record_dir");
    system("zebraidx -c $zebra_config -g $record_format -d $zebra_db_name commit") unless $noshadow;

}

sub print_usage {
    print <<_USAGE_;
$0: reindex MARC bibs and/or authorities in Zebra.

Use this batch job to reindex all biblio or authority
records in your Koha database.  This job is useful
only if you are using Zebra; if you are using the 'NoZebra'
mode, this job should not be used.

Parameters:
    -b                      index bibliographic records

    -a                      index authority records

    -z                      select only updated and deleted
                            records marked in the zebraqueue
                            table.  Cannot be used with -r
                            or -s.

    -r                      clear Zebra index before
                            adding records to index

    -d                      Temporary directory for indexing.
                            If not specified, one is automatically
                            created.  The export directory
                            is automatically deleted unless
                            you supply the -k switch.

    -k                      Do not delete export directory.

    -s                      Skip export.  Used if you have
                            already exported the records 
                            in a previous run.

    -noxml                  index from ISO MARC blob
                            instead of MARC XML.  This
                            option is recommended only
                            for advanced user.

    -x                      export and index as xml instead of is02709 (biblios only).
                            use this if you might have records > 99,999 chars,
							
    -w                      skip shadow indexing for this batch

    -y                      do NOT clear zebraqueue after indexing; normally,
                            after doing batch indexing, zebraqueue should be
                            marked done for the affected record type(s) so that
                            a running zebraqueue_daemon doesn't try to reindex
                            the same records - specify -y to override this.  
                            Cannot be used with -z.

    -munge-config           Deprecated option to try
                            to fix Zebra config files.
    --help or -h            show this message.
_USAGE_
}

# FIXME: the following routines are deprecated and 
# will be removed once it is determined whether
# a script to fix Zebra configuration files is 
# actually needed.
sub munge_config {
#
# creating zebra-biblios.cfg depending on system
#

# getting zebraidx directory
my $zebraidxdir;
foreach (qw(/usr/local/bin/zebraidx
        /opt/bin/zebraidx
        /usr/bin/zebraidx
        )) {
    if ( -f $_ ) {
        $zebraidxdir=$_;
    }
}

unless ($zebraidxdir) {
    print qq|
    ERROR: could not find zebraidx directory
    ERROR: Either zebra is not installed,
    ERROR: or it's in a directory I don't checked.
    ERROR: do a which zebraidx and edit this file to add the result you get
|;
    exit;
}
$zebraidxdir =~ s/\/bin\/.*//;
print "Info : zebra is in $zebraidxdir \n";

# getting modules directory
my $modulesdir;
foreach (qw(/usr/local/lib/idzebra-2.0/modules/mod-grs-xml.so
            /usr/local/lib/idzebra/modules/mod-grs-xml.so
            /usr/lib/idzebra/modules/mod-grs-xml.so
            /usr/lib/idzebra-2.0/modules/mod-grs-xml.so
        )) {
    if ( -f $_ ) {
        $modulesdir=$_;
    }
}

unless ($modulesdir) {
    print qq|
    ERROR: could not find mod-grs-xml.so directory
    ERROR: Either zebra is not properly compiled (libxml2 is not setup and you don t have mod-grs-xml.so,
    ERROR: or it's in a directory I don't checked.
    ERROR: find where mod-grs-xml.so is and edit this file to add the result you get
|;
    exit;
}
$modulesdir =~ s/\/modules\/.*//;
print "Info: zebra modules dir : $modulesdir\n";

# getting tab directory
my $tabdir;
foreach (qw(/usr/local/share/idzebra/tab/explain.att
            /usr/local/share/idzebra-2.0/tab/explain.att
            /usr/share/idzebra/tab/explain.att
            /usr/share/idzebra-2.0/tab/explain.att
        )) {
    if ( -f $_ ) {
        $tabdir=$_;
    }
}

unless ($tabdir) {
    print qq|
    ERROR: could not find explain.att directory
    ERROR: Either zebra is not properly compiled,
    ERROR: or it's in a directory I don't checked.
    ERROR: find where explain.att is and edit this file to add the result you get
|;
    exit;
}
$tabdir =~ s/\/tab\/.*//;
print "Info: tab dir : $tabdir\n";

#
# AUTHORITIES creating directory structure
#
my $created_dir_or_file = 0;
if ($authorities) {
    print "====================\n";
    print "checking directories & files for authorities\n";
    print "====================\n";
    unless (-d "$authorityserverdir") {
        system("mkdir -p $authorityserverdir");
        print "Info: created $authorityserverdir\n";
        $created_dir_or_file++;
    }
    unless (-d "$authorityserverdir/lock") {
        mkdir "$authorityserverdir/lock";
        print "Info: created $authorityserverdir/lock\n";
        $created_dir_or_file++;
    }
    unless (-d "$authorityserverdir/register") {
        mkdir "$authorityserverdir/register";
        print "Info: created $authorityserverdir/register\n";
        $created_dir_or_file++;
    }
    unless (-d "$authorityserverdir/shadow") {
        mkdir "$authorityserverdir/shadow";
        print "Info: created $authorityserverdir/shadow\n";
        $created_dir_or_file++;
    }
    unless (-d "$authorityserverdir/tab") {
        mkdir "$authorityserverdir/tab";
        print "Info: created $authorityserverdir/tab\n";
        $created_dir_or_file++;
    }
    unless (-d "$authorityserverdir/key") {
        mkdir "$authorityserverdir/key";
        print "Info: created $authorityserverdir/key\n";
        $created_dir_or_file++;
    }
    
    unless (-d "$authorityserverdir/etc") {
        mkdir "$authorityserverdir/etc";
        print "Info: created $authorityserverdir/etc\n";
        $created_dir_or_file++;
    }
    
    #
    # AUTHORITIES : copying mandatory files
    #
    # the record model, depending on marc flavour
    unless (-f "$authorityserverdir/tab/record.abs") {
        if (C4::Context->preference("marcflavour") eq "UNIMARC") {
            system("cp -f $kohadir/etc/zebradb/marc_defs/unimarc/authorities/record.abs $authorityserverdir/tab/record.abs");
            print "Info: copied record.abs for UNIMARC\n";
        } else {
            system("cp -f $kohadir/etc/zebradb/marc_defs/marc21/authorities/record.abs $authorityserverdir/tab/record.abs");
            print "Info: copied record.abs for USMARC\n";
        }
        $created_dir_or_file++;
    }
    unless (-f "$authorityserverdir/tab/sort-string-utf.chr") {
        system("cp -f $kohadir/etc/zebradb/lang_defs/fr/sort-string-utf.chr $authorityserverdir/tab/sort-string-utf.chr");
        print "Info: copied sort-string-utf.chr\n";
        $created_dir_or_file++;
    }
    unless (-f "$authorityserverdir/tab/word-phrase-utf.chr") {
        system("cp -f $kohadir/etc/zebradb/lang_defs/fr/sort-string-utf.chr $authorityserverdir/tab/word-phrase-utf.chr");
        print "Info: copied word-phase-utf.chr\n";
        $created_dir_or_file++;
    }
    unless (-f "$authorityserverdir/tab/auth1.att") {
        system("cp -f $kohadir/etc/zebradb/authorities/etc/bib1.att $authorityserverdir/tab/auth1.att");
        print "Info: copied auth1.att\n";
        $created_dir_or_file++;
    }
    unless (-f "$authorityserverdir/tab/default.idx") {
        system("cp -f $kohadir/etc/zebradb/etc/default.idx $authorityserverdir/tab/default.idx");
        print "Info: copied default.idx\n";
        $created_dir_or_file++;
    }
    
    unless (-f "$authorityserverdir/etc/ccl.properties") {
#         system("cp -f $kohadir/etc/zebradb/ccl.properties ".C4::Context->zebraconfig('authorityserver')->{ccl2rpn});
        system("cp -f $kohadir/etc/zebradb/ccl.properties $authorityserverdir/etc/ccl.properties");
        print "Info: copied ccl.properties\n";
        $created_dir_or_file++;
    }
    unless (-f "$authorityserverdir/etc/pqf.properties") {
#         system("cp -f $kohadir/etc/zebradb/pqf.properties ".C4::Context->zebraconfig('authorityserver')->{ccl2rpn});
        system("cp -f $kohadir/etc/zebradb/pqf.properties $authorityserverdir/etc/pqf.properties");
        print "Info: copied pqf.properties\n";
        $created_dir_or_file++;
    }
    
    #
    # AUTHORITIES : copying mandatory files
    #
    unless (-f C4::Context->zebraconfig('authorityserver')->{config}) {
    open ZD,">:utf8 ",C4::Context->zebraconfig('authorityserver')->{config};
    print ZD "
# generated by KOHA/misc/migration_tools/rebuild_zebra.pl 
profilePath:\${srcdir:-.}:$authorityserverdir/tab/:$tabdir/tab/:\${srcdir:-.}/tab/

encoding: UTF-8
# Files that describe the attribute sets supported.
attset: auth1.att
attset: explain.att
attset: gils.att

modulePath:$modulesdir/modules/
# Specify record type
iso2709.recordType:grs.marcxml.record
recordType:grs.xml
recordId: (auth1,Local-Number)
storeKeys:1
storeData:1


# Lock File Area
lockDir: $authorityserverdir/lock
perm.anonymous:r
perm.kohaadmin:rw
register: $authorityserverdir/register:4G
shadow: $authorityserverdir/shadow:4G

# Temp File area for result sets
setTmpDir: $authorityserverdir/tmp

# Temp File area for index program
keyTmpDir: $authorityserverdir/key

# Approx. Memory usage during indexing
memMax: 40M
rank:rank-1
    ";
        print "Info: creating zebra-authorities.cfg\n";
        $created_dir_or_file++;
    }
    
    if ($created_dir_or_file) {
        print "Info: created : $created_dir_or_file directories & files\n";
    } else {
        print "Info: file & directories OK\n";
    }
    
}
if ($biblios) {
    print "====================\n";
    print "checking directories & files for biblios\n";
    print "====================\n";
    
    #
    # BIBLIOS : creating directory structure
    #
    unless (-d "$biblioserverdir") {
        system("mkdir -p $biblioserverdir");
        print "Info: created $biblioserverdir\n";
        $created_dir_or_file++;
    }
    unless (-d "$biblioserverdir/lock") {
        mkdir "$biblioserverdir/lock";
        print "Info: created $biblioserverdir/lock\n";
        $created_dir_or_file++;
    }
    unless (-d "$biblioserverdir/register") {
        mkdir "$biblioserverdir/register";
        print "Info: created $biblioserverdir/register\n";
        $created_dir_or_file++;
    }
    unless (-d "$biblioserverdir/shadow") {
        mkdir "$biblioserverdir/shadow";
        print "Info: created $biblioserverdir/shadow\n";
        $created_dir_or_file++;
    }
    unless (-d "$biblioserverdir/tab") {
        mkdir "$biblioserverdir/tab";
        print "Info: created $biblioserverdir/tab\n";
        $created_dir_or_file++;
    }
    unless (-d "$biblioserverdir/key") {
        mkdir "$biblioserverdir/key";
        print "Info: created $biblioserverdir/key\n";
        $created_dir_or_file++;
    }
    unless (-d "$biblioserverdir/etc") {
        mkdir "$biblioserverdir/etc";
        print "Info: created $biblioserverdir/etc\n";
        $created_dir_or_file++;
    }
    
    #
    # BIBLIOS : copying mandatory files
    #
    # the record model, depending on marc flavour
    unless (-f "$biblioserverdir/tab/record.abs") {
        if (C4::Context->preference("marcflavour") eq "UNIMARC") {
            system("cp -f $kohadir/etc/zebradb/marc_defs/unimarc/biblios/record.abs $biblioserverdir/tab/record.abs");
            print "Info: copied record.abs for UNIMARC\n";
        } else {
            system("cp -f $kohadir/etc/zebradb/marc_defs/marc21/biblios/record.abs $biblioserverdir/tab/record.abs");
            print "Info: copied record.abs for USMARC\n";
        }
        $created_dir_or_file++;
    }
    unless (-f "$biblioserverdir/tab/sort-string-utf.chr") {
        system("cp -f $kohadir/etc/zebradb/lang_defs/fr/sort-string-utf.chr $biblioserverdir/tab/sort-string-utf.chr");
        print "Info: copied sort-string-utf.chr\n";
        $created_dir_or_file++;
    }
    unless (-f "$biblioserverdir/tab/word-phrase-utf.chr") {
        system("cp -f $kohadir/etc/zebradb/lang_defs/fr/sort-string-utf.chr $biblioserverdir/tab/word-phrase-utf.chr");
        print "Info: copied word-phase-utf.chr\n";
        $created_dir_or_file++;
    }
    unless (-f "$biblioserverdir/tab/bib1.att") {
        system("cp -f $kohadir/etc/zebradb/biblios/etc/bib1.att $biblioserverdir/tab/bib1.att");
        print "Info: copied bib1.att\n";
        $created_dir_or_file++;
    }
    unless (-f "$biblioserverdir/tab/default.idx") {
        system("cp -f $kohadir/etc/zebradb/etc/default.idx $biblioserverdir/tab/default.idx");
        print "Info: copied default.idx\n";
        $created_dir_or_file++;
    }
    unless (-f "$biblioserverdir/etc/ccl.properties") {
#         system("cp -f $kohadir/etc/zebradb/ccl.properties ".C4::Context->zebraconfig('biblioserver')->{ccl2rpn});
        system("cp -f $kohadir/etc/zebradb/ccl.properties $biblioserverdir/etc/ccl.properties");
        print "Info: copied ccl.properties\n";
        $created_dir_or_file++;
    }
    unless (-f "$biblioserverdir/etc/pqf.properties") {
#         system("cp -f $kohadir/etc/zebradb/pqf.properties ".C4::Context->zebraconfig('biblioserver')->{ccl2rpn});
        system("cp -f $kohadir/etc/zebradb/pqf.properties $biblioserverdir/etc/pqf.properties");
        print "Info: copied pqf.properties\n";
        $created_dir_or_file++;
    }
    
    #
    # BIBLIOS : copying mandatory files
    #
    unless (-f C4::Context->zebraconfig('biblioserver')->{config}) {
    open ZD,">:utf8 ",C4::Context->zebraconfig('biblioserver')->{config};
    print ZD "
# generated by KOHA/misc/migrtion_tools/rebuild_zebra.pl 
profilePath:\${srcdir:-.}:$biblioserverdir/tab/:$tabdir/tab/:\${srcdir:-.}/tab/

encoding: UTF-8
# Files that describe the attribute sets supported.
attset:bib1.att
attset:explain.att
attset:gils.att

modulePath:$modulesdir/modules/
# Specify record type
iso2709.recordType:grs.marcxml.record
recordType:grs.xml
recordId: (bib1,Local-Number)
storeKeys:1
storeData:1


# Lock File Area
lockDir: $biblioserverdir/lock
perm.anonymous:r
perm.kohaadmin:rw
register: $biblioserverdir/register:4G
shadow: $biblioserverdir/shadow:4G

# Temp File area for result sets
setTmpDir: $biblioserverdir/tmp

# Temp File area for index program
keyTmpDir: $biblioserverdir/key

# Approx. Memory usage during indexing
memMax: 40M
rank:rank-1
    ";
        print "Info: creating zebra-biblios.cfg\n";
        $created_dir_or_file++;
    }
    
    if ($created_dir_or_file) {
        print "Info: created : $created_dir_or_file directories & files\n";
    } else {
        print "Info: file & directories OK\n";
    }
    
}
}
