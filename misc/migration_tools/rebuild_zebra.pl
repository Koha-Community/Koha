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

# limit for database dumping
my $limit;# = "LIMIT 1";
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
);


if (not $result or $want_help) {
    print_usage();
    exit 0;
}

if (not $biblios and not $authorities) {
    my $msg = "Must specify -b or -a to reindex bibs or authorites\n";
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

if ($authorities) {
    #
    # exporting authorities
    #
    if ($skip_export) {
        print "====================\n";
        print "SKIPPING authorities export\n";
        print "====================\n";
    } else {
        print "====================\n";
        print "exporting authorities\n";
        print "====================\n";
        mkdir "$directory" unless (-d $directory);
        mkdir "$directory/authorities" unless (-d "$directory/authorities");
        open(OUT,">:utf8","$directory/authorities/authorities.iso2709") or die $!;
        my $dbh=C4::Context->dbh;
        my $sth;
        $sth=$dbh->prepare("select authid,marc from auth_header $limit");
        $sth->execute();
        my $i=0;
        while (my ($authid,$record) = $sth->fetchrow) {
            # FIXME : we retrieve the iso2709 record. if the GetAuthority (that uses the XML) fails
            # due to some MARC::File::XML failure, then try the iso2709, 
            # (add authid & authtype if needed)
            my $record;
            eval {
                $record = GetAuthority($authid);
            };
            next unless $record;
            # force authid in case it's not here, otherwise, zebra will die on this authority
            unless ($record->field('001')->data() eq $authid){
                print "$authid don't exist for this authority :".$record->as_formatted;
                $record->delete_field($record->field('001'));
                $record->insert_fields_ordered(MARC::Field->new('001',$authid));
            }
            if($@){
                print "  There was some pb getting authority : ".$authid."\n";
            next;
            }
        
            print ".";
            print "\r$i" unless ($i++ %100);
#            # remove leader length, that could be wrong, it will be calculated automatically by as_usmarc
#            # otherwise, if it's wron, zebra will fail miserabily (and never index what is after the failing record)
            my $leader=$record->leader;
            substr($leader,0,5)='     ';
            substr($leader,10,7)='22     ';
            $record->leader(substr($leader,0,24));
            print OUT $record->as_usmarc;
        }
        close(OUT);
    }
    
    #
    # and reindexing everything
    #
    print "====================\n";
    print "REINDEXING zebra\n";
    print "====================\n";
    system("zebraidx -c ".C4::Context->zebraconfig('authorityserver')->{config}." -g iso2709 -d authorities init") if ($reset);
    system("zebraidx -c ".C4::Context->zebraconfig('authorityserver')->{config}." $noshadow -g iso2709 -d authorities update $directory/authorities");
    system("zebraidx -c ".C4::Context->zebraconfig('authorityserver')->{config}." -g iso2709 -d authorities commit") unless $noshadow;
} else {
    print "skipping authorities\n";
}
#################################################################################################################
#                        BIBLIOS 
#################################################################################################################

if ($biblios) {
    # die;
    #
    # exporting biblios
    #
    if ($skip_export) {
        print "====================\n";
        print "SKIPPING biblio export\n";
        print "====================\n";
    } else {
        print "====================\n";
        print "exporting biblios\n";
        print "====================\n";
        mkdir "$directory" unless (-d $directory);
        mkdir "$directory/biblios" unless (-d "$directory/biblios");
        open(OUT,">:utf8 ","$directory/biblios/export") or die $!;
        my $dbh=C4::Context->dbh;
        my $sth;
    if ($noxml){
        $sth=$dbh->prepare("select biblionumber,marc from biblioitems order by biblionumber $limit");
        $sth->execute();
        my $i=0;
        while (my ($biblionumber,$marc) = $sth->fetchrow) {
            my $record;
            $record=MARC::Record->new_from_usmarc($marc);
            my $record_correct=1;
            # skip uncorrect records : isn't this bogus, as just after we reintroduce biblionumber if it's missing ?
            # FIXME next unless $record->field($biblionumbertagfield);
            # check if biblionumber is present, otherwise, add it on the fly
            if ($biblionumbertagfield eq '001') {
                unless ($record->field($biblionumbertagfield)->data()) {
                    $record_correct=0;
                    my $field;
                    # if the field where biblionumber is already exist, just update it, otherwise create it
                if ($record->field($biblionumbertagfield)) {
                $field =  $record->field($biblionumbertagfield);
                $field->update($biblionumber);
                } else {
                my $newfield;
                $newfield = MARC::Field->new( $biblionumbertagfield, $biblionumber);
                $record->append_fields($newfield);
                }
            }
            } else {
            unless ($record->subfield($biblionumbertagfield,$biblionumbertagsubfield)) {
                $record_correct=0;
                my $field;
                # if the field where biblionumber is already exist, just update it, otherwise create it
                if ($record->field($biblionumbertagfield)) {
                $field =  $record->field($biblionumbertagfield);
                $field->add_subfields($biblionumbertagsubfield => $biblionumber);
                } else {
                my $newfield;
                $newfield = MARC::Field->new( $biblionumbertagfield,'','', $biblionumbertagsubfield => $biblionumber);
                $record->append_fields($newfield);
                }
            }
    #             warn "FIXED BIBLIONUMBER".$record->as_formatted;
            }
            unless ($record->subfield($biblioitemnumbertagfield,$biblioitemnumbertagsubfield)) {
                $record_correct=0;
            #             warn "INCORRECT BIBLIOITEMNUMBER :".$record->as_formatted;
            my $field;
                # if the field where biblionumber is already exist, just update it, otherwise create it
                if ($record->field($biblioitemnumbertagfield)) {
                    $field =  $record->field($biblioitemnumbertagfield);
                    if ($biblioitemnumbertagfield <10) {
                    $field->update($biblionumber);
                    } else {
                    $field->add_subfields($biblioitemnumbertagsubfield => $biblionumber);
                    }
                } else {
                    my $newfield;
                    if ($biblioitemnumbertagfield <10) {
                    $newfield = MARC::Field->new( $biblioitemnumbertagfield, $biblionumber);
                    } else {
                    $newfield = MARC::Field->new( $biblioitemnumbertagfield,'','', $biblioitemnumbertagsubfield => $biblionumber);
                    }
                    $record->insert_grouped_field($newfield);
            }
        #             warn "FIXED BIBLIOITEMNUMBER".$record->as_formatted;
            }
            my $leader=$record->leader;
            substr($leader,0,5)='     ';
            substr($leader,10,7)='22     ';
            $record->leader(substr($leader,0,24));
                print OUT $record->as_usmarc();
        }
        close (OUT);
    } else {
        $sth=$dbh->prepare("SELECT biblionumber FROM biblioitems ORDER BY biblionumber $limit");
        $sth->execute();
        my $i=0;
        while (my ($biblionumber) = $sth->fetchrow) {
            print ".";
            print "\r$i" unless ($i++ %100);
            my $record;
            eval {
                $record = GetMarcBiblio($biblionumber);
            };
            if($@){
                print "  There was some pb getting biblio : #".$biblionumber."\n";
                next;
            }
            next unless $record;
# die if $record->subfield('090','9') eq 11;
    #         print $record;
            # check that biblionumber & biblioitemnumber are stored in the MARC record, otherwise, add them & update the biblioitems.marcxml data.
            my $record_correct=1;
            # skip uncorrect records : isn't this bogus, as just after we reintroduce biblionumber if it's missing ?
            # FIXME next unless $record->field($biblionumbertagfield);
            #
            #
            # CHECK  biblionumber
            #
            #
            if ($biblionumbertagfield eq '001') {
                unless ($record->field($biblionumbertagfield) && $record->field($biblionumbertagfield)->data()) {
                    $record_correct=0;
                    my $field;
                    # if the field where biblionumber is already exist, just update it, otherwise create it
                    if ($record->field($biblionumbertagfield)) {
                        $field =  $record->field($biblionumbertagfield);
                        $field->update($biblionumber);
                    } else {
                        my $newfield;
                        $newfield = MARC::Field->new( $biblionumbertagfield, $biblionumber);
                        $record->append_fields($newfield);
                    }
                }
            } else {
                unless ($record->subfield($biblionumbertagfield,$biblionumbertagsubfield)) {
#                 warn "fixing biblionumber for $biblionumbertagfield,$biblionumbertagsubfield = $biblionumber";
                    $record_correct=0;
                    my $field;
                    # if the field where biblionumber is already exist, just update it, otherwise create it
                    if ($record->field($biblionumbertagfield)) {
                        $field =  $record->field($biblionumbertagfield);
                        $field->add_subfields($biblionumbertagsubfield => $biblionumber);
                    } else {
                        my $newfield;
                        $newfield = MARC::Field->new( $biblionumbertagfield,'','', $biblionumbertagsubfield => $biblionumber);
                        $record->append_fields($newfield);
                    }
                }
#                 warn "FIXED BIBLIONUMBER".$record->as_formatted;
            }
            #
            #
            # CHECK BIBLIOITEMNUMBER
            #
            #
            unless ($record->subfield($biblioitemnumbertagfield,$biblioitemnumbertagsubfield)) {
#                 warn "fixing biblioitemnumber for $biblioitemnumbertagfield,$biblioitemnumbertagsubfield = $biblionumber";
                $record_correct=0;
                my $field;
                # if the field where biblionumber is already exist, just update it, otherwise create it
                if ($record->field($biblioitemnumbertagfield)) {
                    $field =  $record->field($biblioitemnumbertagfield);
                    if ($biblioitemnumbertagfield <10) {
                        $field->update($biblionumber);
                    } else {
                        $field->add_subfields($biblioitemnumbertagsubfield => $biblionumber);
                    }
                } else {
                    my $newfield;
                    if ($biblioitemnumbertagfield <10) {
                        $newfield = MARC::Field->new( $biblioitemnumbertagfield, $biblionumber);
                    } else {
                        $newfield = MARC::Field->new( $biblioitemnumbertagfield,'','', $biblioitemnumbertagsubfield => $biblionumber);
                    }
                    $record->insert_grouped_field($newfield);
                }
    #             warn "FIXED BIBLIOITEMNUMBER".$record->as_formatted;
            }
            #
            #
            # CHECK FIELD 100
            #
            #
            my $encoding = C4::Context->preference("marcflavour");
            # deal with UNIMARC field 100 (encoding) : create it if needed & set encoding to unicode
            if ( $encoding eq "UNIMARC" ) {
                my $string;
                if ( length($record->subfield( 100, "a" )) == 35 ) {
                    $string = $record->subfield( 100, "a" );
                    my $f100 = $record->field(100);
                    $record->delete_field($f100);
                }
                else {
                    $string = POSIX::strftime( "%Y%m%d", localtime );
                    $string =~ s/\-//g;
                    $string = sprintf( "%-*s", 35, $string );
                }
                substr( $string, 22, 6, "frey50" );
                unless ( length($record->subfield( 100, "a" )) == 35 ) {
                    $record->delete_field($record->field(100));
                    $record->insert_grouped_field(
                        MARC::Field->new( 100, "", "", "a" => $string ) );
                }
            }
            unless ($record_correct) {
                my $update_xml = $dbh->prepare("update biblioitems set marcxml=? where biblionumber=?");
                warn "UPDATING $biblionumber (missing biblionumber or biblioitemnumber in MARC record : ".$record->as_xml;
                $update_xml->execute($record->as_xml,$biblionumber);
            }
            # remove leader length, that could be wrong, it will be calculated automatically by as_usmarc
            # otherwise, if it's wron, zebra will fail miserabily (and never index what is after the failing record)
            my $leader=$record->leader;
            substr($leader,0,5)='     ';
            substr($leader,10,7)='22     ';
            $record->leader(substr($leader,0,24));
            print OUT $record->as_usmarc();
        }
        close(OUT);
    }
    }
    
    #
    # and reindexing everything
    #
    print "====================\n";
    print "REINDEXING zebra\n";
    print "====================\n";
    system("zebraidx -g iso2709 -c ".C4::Context->zebraconfig('biblioserver')->{config}." -d biblios init") if ($reset);
    system("zebraidx -g iso2709 -c ".C4::Context->zebraconfig('biblioserver')->{config}." $noshadow -d biblios update $directory/biblios");
    system("zebraidx -g iso2709 -c ".C4::Context->zebraconfig('biblioserver')->{config}." -d biblios commit") unless $noshadow;
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

    -w                      skip shadow indexing for this batch

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
