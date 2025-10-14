#!/usr/bin/perl
# Import an iso2709 file into Koha 3

use Modern::Perl;

#use diagnostics;

# Koha modules used
use MARC::File::USMARC;
use MARC::File::XML;
use MARC::Batch;
use MARC::Lint;
use Encode;

use Koha::Script;
use C4::Context;
use C4::Biblio qw(
    AddBiblio
    GetMarcFromKohaField
    ModBiblio
    ModBiblioMarc
    GetFrameworkCode
    BiblioAutoLink
);
use C4::Koha;
use C4::Charset                   qw( MarcToUTF8Record SetUTF8Flag );
use C4::Items                     qw( AddItemBatchFromMarc );
use C4::MarcModificationTemplates qw(
    GetModificationTemplates
    ModifyRecordWithTemplate
);
use C4::AuthoritiesMarc qw( GuessAuthTypeCode GuessAuthId GetAuthority ModAuthority AddAuthority );

use YAML::XS;
use Time::HiRes  qw( gettimeofday );
use Getopt::Long qw( GetOptions );
use IO::File;
use Pod::Usage qw( pod2usage );
use FindBin    ();

use Koha::Logger;
use Koha::Biblios;
use Koha::SearchEngine;
use Koha::SearchEngine::Search;

use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );
my ( $input_marc_file, $number, $offset, $cleanisbn ) = ( '', 0, 0, 1 );
my $version;
my $delete;
my $test_parameter;
my $skip_marc8_conversion;
my $char_encoding;
my $verbose;
my $commit;
my $fk_off;
my $format;
my $biblios;
my $authorities;
my $keepids;
my $match;
my $isbn_check;
my $logfile;
my $insert;
my $filters;
my $update;
my $all;
my $yamlfile;
my $authtypes;
my $append;
my $sourcetag;
my $sourcesubfield;
my $idmapfl;
my $dedup_barcode;
my $framework = '';
my $localcust;
my $marc_mod_template    = '';
my $marc_mod_template_id = -1;
my $skip_indexing        = 0;
my $skip_bad_records;
$| = 1;

GetOptions(
    'commit:f'            => \$commit,
    'file:s'              => \$input_marc_file,
    'n:f'                 => \$number,
    'o|offset:f'          => \$offset,
    'h|help'              => \$version,
    'd|delete'            => \$delete,
    't|test'              => \$test_parameter,
    's'                   => \$skip_marc8_conversion,
    'c:s'                 => \$char_encoding,
    'v|verbose:+'         => \$verbose,
    'fk'                  => \$fk_off,
    'm:s'                 => \$format,
    'l:s'                 => \$logfile,
    'append'              => \$append,
    'k|keepids:s'         => \$keepids,
    'b|biblios'           => \$biblios,
    'a|authorities'       => \$authorities,
    'authtypes:s'         => \$authtypes,
    'filter=s@'           => \$filters,
    'insert'              => \$insert,
    'update'              => \$update,
    'all'                 => \$all,
    'match=s@'            => \$match,
    'i|isbn'              => \$isbn_check,
    'x:s'                 => \$sourcetag,
    'y:s'                 => \$sourcesubfield,
    'idmap:s'             => \$idmapfl,
    'cleanisbn!'          => \$cleanisbn,
    'yaml:s'              => \$yamlfile,
    'dedupbarcode'        => \$dedup_barcode,
    'framework=s'         => \$framework,
    'custom:s'            => \$localcust,
    'marcmodtemplate:s'   => \$marc_mod_template,
    'si|skip_indexing'    => \$skip_indexing,
    'sk|skip_bad_records' => \$skip_bad_records,
);

$biblios ||= !$authorities;
$insert  ||= !$update;
my $writemode = ($append) ? "a" : "w";

pod2usage( -msg => "\nYou must specify either --biblios or --authorities, not both.\n", -exitval )
    if $biblios && $authorities;

if ($all) {
    $insert = 1;
    $update = 1;
}

my $using_elastic_search = ( C4::Context->preference('SearchEngine') eq 'Elasticsearch' );
my $mod_biblio_options   = {
    disable_autolink  => $using_elastic_search,
    skip_record_index => $using_elastic_search || $skip_indexing,
    overlay_context   => { source => 'bulkmarcimport' }
};
my $add_biblio_options = {
    disable_autolink  => $using_elastic_search,
    skip_record_index => $using_elastic_search || $skip_indexing
};
my $mod_authority_options = { skip_record_index => $using_elastic_search || $skip_indexing };
my $add_authority_options = { skip_record_index => $using_elastic_search || $skip_indexing };

my @search_engine_record_ids;
my @search_engine_records;
my $indexer;
if ($using_elastic_search) {
    use Koha::SearchEngine::Elasticsearch::Indexer;
    $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new(
        {
            index => $authorities
            ? $Koha::SearchEngine::Elasticsearch::AUTHORITIES_INDEX
            : $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX
        }
    );
}

if ( $version || ( $input_marc_file eq '' ) ) {
    pod2usage( -verbose => 2 );
    exit;
}
if ( $update && !( $match || $isbn_check ) ) {
    warn "Using --update without --match or --isbn seems to be useless.\n";
}

if ( defined $localcust ) {    #local customize module
    if ( !-e $localcust ) {
        $localcust = $localcust || 'LocalChanges';        #default name
        $localcust =~ s/^.*\/([^\/]+)$/$1/;               #extract file name only
        $localcust =~ s/\.pm$//;                          #remove extension
        my $fqcust = $FindBin::Bin . "/$localcust.pm";    #try migration_tools dir
        if ( -e $fqcust ) {
            $localcust = $fqcust;
        } else {
            print "WARNING: customize module $localcust.pm not found!\n";
            exit 1;
        }
    }
    require $localcust       if $localcust;
    $localcust = \&customize if $localcust;
}

if ( $marc_mod_template ne '' ) {
    my @templates = GetModificationTemplates();
    foreach my $this_template (@templates) {
        if ( $this_template->{'name'} eq $marc_mod_template ) {
            if ( $marc_mod_template_id < 0 ) {
                $marc_mod_template_id = $this_template->{'template_id'};
            } else {
                print "WARNING: MARC modification template name "
                    . "'$marc_mod_template' matches multiple templates. "
                    . "Please rename these templates\n";
                exit 1;
            }
        }
    }
    if ( $marc_mod_template_id < 0 ) {
        die "Can't located MARC modification template '$marc_mod_template'\n";
    } else {
        print "Records will be modified using MARC modification template: $marc_mod_template\n" if $verbose;
    }
}

my $dbh            = C4::Context->dbh;
my $heading_fields = get_heading_fields();
my $idmapfh;

if ( defined $idmapfl ) {
    open( $idmapfh, '>', $idmapfl ) or die "cannot open $idmapfl \n";
}

if ( ( not defined $sourcesubfield ) && ( not defined $sourcetag ) ) {
    $sourcetag      = "910";
    $sourcesubfield = "a";
}

# Disable logging for the biblios and authorities import operation. It would unnecessarily
# slow the import
$ENV{OVERRIDE_SYSPREF_CataloguingLog} = 0;
$ENV{OVERRIDE_SYSPREF_AuthoritiesLog} = 0;

if ($fk_off) {
    $dbh->do("SET FOREIGN_KEY_CHECKS = 0");
}

if ($delete) {
    if ($biblios) {
        print "Deleting biblios\n";
        $dbh->do("DELETE FROM biblio");
        $dbh->do("ALTER TABLE biblio AUTO_INCREMENT = 1");
        $dbh->do("DELETE FROM biblioitems");
        $dbh->do("ALTER TABLE biblioitems AUTO_INCREMENT = 1");
        $dbh->do("DELETE FROM items");
        $dbh->do("ALTER TABLE items AUTO_INCREMENT = 1");
    } else {
        print "Deleting authorities\n";
        $dbh->do("DELETE FROM auth_header");
    }
    $dbh->do("truncate zebraqueue");
}

if ($test_parameter) {
    print "TESTING MODE ONLY\n    DOING NOTHING\n===============\n";
}

my $batch;
my $marc_flavour = C4::Context->preference('marcflavour') || 'MARC21';

# The definition of $searcher must be before MARC::Batch->new
my $searcher = Koha::SearchEngine::Search->new(
    {
        index => (
              $authorities
            ? $Koha::SearchEngine::AUTHORITIES_INDEX
            : $Koha::SearchEngine::BIBLIOS_INDEX
        )
    }
);

print "Characteristic MARC flavour: $marc_flavour\n" if $verbose;
my $starttime = gettimeofday;

# don't let MARC::Batch open the file, as it applies the ':utf8' IO layer
my $fh = IO::File->new($input_marc_file) or die "Could not open $input_marc_file: $!";

if ( defined $format && $format =~ /XML/i ) {

    # ugly hack follows -- MARC::File::XML, when used by MARC::Batch,
    # appears to try to convert incoming XML records from MARC-8
    # to UTF-8.  Setting the BinaryEncoding key turns that off
    # TODO: see what happens to ISO-8859-1 XML files.
    # TODO: determine if MARC::Batch can be fixed to handle
    #       XML records properly -- it probably should be
    #       be using a proper push or pull XML parser to
    #       extract the records, not using regexes to look
    #       for <record>.*</record>.
    $MARC::File::XML::_load_args{BinaryEncoding} = 'utf-8';
    my $recordformat = ( $marc_flavour eq "MARC21" ? "USMARC" : uc($marc_flavour) );

    #UNIMARC Authorities have a different way to manage encoding than UNIMARC biblios.
    $recordformat = $recordformat . "AUTH" if ( $authorities and $marc_flavour ne "MARC21" );
    $MARC::File::XML::_load_args{RecordFormat} = $recordformat;
    $batch = MARC::Batch->new( 'XML', $fh );
} else {
    $batch = MARC::Batch->new( 'USMARC', $fh );
}

$batch->warnings_off();
$batch->strict_off();
my $commitnum = $commit ? $commit : 50;
my $yamlhash;

# Skip file offset
if ($offset) {
    print "Skipping file offset: $offset records\n";
    $batch->next() while ( $offset-- );
}

my ( $tagid, $subfieldid );
if ($authorities) {
    $tagid = '001';
} else {
    ( $tagid, $subfieldid ) = GetMarcFromKohaField("biblio.biblionumber");
    $tagid ||= "001";
}

my $sth_isbn;

# the SQL query to search on isbn
if ($isbn_check) {
    $sth_isbn = $dbh->prepare("SELECT biblionumber, biblioitemnumber FROM biblioitems WHERE isbn=?");
}

my $loghandle;
if ($logfile) {
    $loghandle = IO::File->new( $logfile, $writemode );
    print $loghandle "id;operation;status\n";
}

my $record_number     = 0;
my $records_exhausted = 0;
my $logger            = Koha::Logger->get;
my $schema            = Koha::Database->schema;
my $lint              = MARC::Lint->new;

$schema->txn_begin;
RECORD: while () {

    my $record;
    $record_number++;

    # get record
    eval { $record = $batch->next() };
    if ($@) {
        print "Bad MARC record $record_number: $@ skipped\n";

        # FIXME - because MARC::Batch->next() combines grabbing the next
        # blob and parsing it into one operation, a correctable condition
        # such as a MARC-8 record claiming that it's UTF-8 can't be recovered
        # from because we don't have access to the original blob.  Note
        # that the staging import can deal with this condition (via
        # C4::Charset::MarcToUTF8Record) because it doesn't use MARC::Batch.
        next;
    }
    if ($record) {
        $record_number++;

        if ($skip_bad_records) {
            my $xml = $record->as_xml_record();
            eval { MARC::Record::new_from_xml( $xml, 'UTF-8', "MARC21" ); };
            if ($@) {
                print "Record $record_number generated invalid xml:\n";
                $lint->check_record($record);
                foreach my $warning ( $lint->warnings ) {
                    print "    " . $warning . "\n";
                }
                print "    Record skipped!";
                next;
            }
        }
        # transcode the record to UTF8 if needed & applicable.
        if ( $record->encoding() eq 'MARC-8' and not $skip_marc8_conversion ) {
            my ( $guessed_charset, $charset_errors );
            ( $record, $guessed_charset, $charset_errors ) = MarcToUTF8Record(
                $record,
                $marc_flavour . ( ( $authorities and $marc_flavour ne "MARC21" ) ? 'AUTH' : '' )
            );
            if ( $guessed_charset eq 'failed' ) {
                warn "ERROR: failed to perform character conversion for record $record_number\n";
                next RECORD;
            }
        }
        SetUTF8Flag($record);
        &$localcust($record) if $localcust;

        if ( ( $verbose // 1 ) == 1 ) {    #no dot for verbose==2
            print "." . ( $record_number % 100 == 0 ? "\n$record_number" : '' );
        }

        if ( $marc_mod_template_id > 0 ) {
            print "Modifying MARC\n" if $verbose;
            ModifyRecordWithTemplate( $marc_mod_template_id, $record );
        }

        my $isbn;

        # remove trailing - in isbn (only for biblios, of course)
        if ( $biblios && ( $cleanisbn || $isbn_check ) ) {
            my $tag   = $marc_flavour eq 'UNIMARC' ? '010' : '020';
            my $field = $record->field($tag);
            $isbn = $field && $field->subfield('a');
            if ( $isbn && $cleanisbn ) {
                $isbn =~ s/-//g;
                $field->update( 'a' => $isbn );
            }
        }

        # search for duplicates (based on Local-number)
        my $originalid        = GetRecordId( $record, $tagid, $subfieldid );
        my $matched_record_id = undef;
        if ($match) {
            require C4::Search;
            my $server = ( $authorities ? 'authorityserver' : 'biblioserver' );
            my $query  = build_query( $match, $record );
            $logger->debug("Bulkmarcimport: $query");
            my ( $error, $results, $totalhits ) = $searcher->simple_search_compat( $query, 0, 3, [$server] );

            # changed to warn so able to continue with one broken record
            if ( defined $error ) {
                warn "unable to search the database for duplicates : $error";
                printlog( { id => $originalid, op => "match", status => "ERROR" } ) if ($logfile);
                next RECORD;
            }
            $logger->debug("Bulkmarcimport: $query $server : $totalhits");

            # sub SimpleSearch could return undefined, but only on error, so
            # should not really need to safeguard here, but do so anyway
            $results //= [];
            if ( @{$results} == 1 ) {
                my $matched_record = C4::Search::new_record_from_zebra( $server, $results->[0] );
                SetUTF8Flag($matched_record);
                $matched_record_id = GetRecordId( $matched_record, $tagid, $subfieldid );

                if ( $authorities && $marc_flavour ) {

                    #Skip if authority in database is the same or newer than the incoming record
                    if ( RecordRevisionIsGtOrEq( $matched_record, $record ) ) {
                        if ($yamlfile) {
                            $yamlhash->{$originalid} = YAMLFileEntry(
                                $matched_record,
                                $matched_record_id,
                                0
                            );
                        }
                        next;
                    }
                }
            } elsif ( @{$results} > 1 ) {
                $logger->debug("More than one match for: $query");
                next;
            } else {
                $logger->debug("No match for: $query");
            }

            if ( $keepids && $originalid ) {
                my $storeidfield;
                if ( length($keepids) == 3 ) {
                    $storeidfield = MARC::Field->new( $keepids, $originalid );
                } else {
                    $storeidfield =
                        MARC::Field->new( substr( $keepids, 0, 3 ), "", "", substr( $keepids, 3, 1 ), $originalid );
                }
                $record->insert_fields_ordered($storeidfield);
                $record->delete_field( $record->field($tagid) );
            }
        }

        foreach my $stringfilter (@$filters) {
            if ( length($stringfilter) == 3 ) {
                foreach my $field ( $record->field($stringfilter) ) {
                    $record->delete_field($field);
                    $logger->debug( "Removed: ", $field->as_string );
                }
            } elsif ( $stringfilter =~ /([0-9]{3})([a-z0-9])(.*)/ ) {
                my $removetag      = $1;
                my $removesubfield = $2;
                my $removematch    = $3;
                if ( ( $removetag > "010" ) && $removesubfield ) {
                    foreach my $field ( $record->field($removetag) ) {
                        $field->delete_subfield( code => "$removesubfield", match => $removematch );
                        $logger->debug( "Potentially removed: ", $field->subfield($removesubfield) );
                    }
                }
            }
        }
        unless ($test_parameter) {

            if ($authorities) {
                my $authtypecode = GuessAuthTypeCode( $record, $heading_fields );
                my $authid;

                if ($matched_record_id) {
                    if ($update) {
                        ## Authority has an id and is in database: update
                        eval {
                            ($authid) = ModAuthority(
                                $matched_record_id, $record, $authtypecode,
                                $mod_authority_options,
                            );
                        };
                        if ($@) {
                            warn "ERROR: Update authority $matched_record_id failed: $@\n";
                            printlog( { id => $matched_record_id, op => "update", status => "ERROR" } ) if ($logfile);
                            next RECORD;
                        } else {
                            printlog( { id => $authid, op => "update", status => "ok" } ) if ($logfile);
                        }
                    } elsif ($logfile) {
                        warn "WARNING: Update authority $originalid skipped";
                        printlog(
                            {
                                id     => $matched_record_id,
                                op     => "update",
                                status =>
                                    "warning: authority already in database and option -update not enabled, skipping..."
                            }
                        );
                    }
                } elsif ($insert) {
                    ## An authid is defined but no authority in database: insert
                    eval { ($authid) = AddAuthority( $record, undef, $authtypecode, $add_authority_options ); };
                    if ($@) {
                        warn "ERROR: Insert authority $originalid failed: $@\n";
                        printlog( { id => $originalid, op => "insert", status => "ERROR" } ) if ($logfile);
                        next RECORD;
                    } else {
                        printlog( { id => $authid, op => "insert", status => "ok" } ) if ($logfile);
                    }
                } else {
                    warn "WARNING: Insert authority $originalid skipped";
                    printlog(
                        {
                            id     => $originalid, op => "insert",
                            status => "warning : authority not in database and option -insert not enabled, skipping..."
                        }
                    ) if ($logfile);
                }

                if ($yamlfile) {
                    $yamlhash->{$originalid} = YAMLFileEntry(
                        $record,
                        $authid,
                        1    #@FIXME: Really always updated?
                    );
                }
                if ($indexer) {
                    push @search_engine_record_ids, $authid;
                    push @search_engine_records,    $record;
                }
            } else {
                my ( $biblioitemnumber, $itemnumbers_ref, $errors_ref, $record_id );

                # check for duplicate, based on ISBN (skip it if we already have found a duplicate with match parameter
                if ( !$matched_record_id && $isbn_check && $isbn ) {
                    $sth_isbn->execute($isbn);
                    ( $matched_record_id, $biblioitemnumber ) = $sth_isbn->fetchrow;
                }

                if ( defined $idmapfl && $matched_record_id ) {
                    if ( $sourcetag < "010" ) {
                        if ( $record->field($sourcetag) ) {
                            my $source = $record->field($sourcetag)->data();
                            printf( $idmapfh "%s|%s\n", $source, $matched_record_id );
                        }
                    } else {
                        my $source = $record->subfield( $sourcetag, $sourcesubfield );
                        printf( $idmapfh "%s|%s\n", $source, $matched_record_id );
                    }
                }

                # Create biblio, unless we already have it (either match or ISBN)
                if ($matched_record_id) {
                    eval { $biblioitemnumber = Koha::Biblios->find($matched_record_id)->biblioitem->biblioitemnumber; };
                    if ($update) {
                        my $success;
                        eval {
                            $success = ModBiblio(
                                $record, $matched_record_id, GetFrameworkCode($matched_record_id),
                                $mod_biblio_options
                            );
                        };
                        if ($@) {
                            warn "ERROR: Update biblio $matched_record_id failed: $@\n";
                            printlog( { id => $matched_record_id, op => "update", status => "ERROR" } ) if ($logfile);
                            next RECORD;
                        } elsif ( !$success ) {
                            warn "ERROR: Update biblio $matched_record_id failed for unknown reason";
                            printlog( { id => $matched_record_id, op => "update", status => "ERROR" } ) if ($logfile);
                            next RECORD;
                        } else {
                            $record_id = $matched_record_id;
                            printlog( { id => $record_id, op => "update", status => "ok" } ) if ($logfile);
                        }
                    } else {
                        warn "WARNING: Update biblio $originalid skipped";
                        printlog(
                            {
                                id     => $matched_record_id, op => "update",
                                status => "warning : already in database and option -update not enabled, skipping..."
                            }
                        ) if ($logfile);
                    }
                } elsif ($insert) {
                    my $record_clone = $record->clone();
                    C4::Biblio::_strip_item_fields($record_clone);
                    eval {
                        ( $record_id, $biblioitemnumber ) = AddBiblio( $record_clone, $framework, $add_biblio_options );
                    };
                    if ($@) {
                        warn "ERROR: Insert biblio $originalid failed: $@\n";
                        printlog( { id => $originalid, op => "insert", status => "ERROR" } ) if ($logfile);
                        next RECORD;
                    } else {
                        printlog( { id => $originalid, op => "insert", status => "ok" } ) if ($logfile);
                    }

                    # If incoming record has bib ids set we need to transfer
                    # new ids from record_clone to incoming record to avoid
                    # working on wrong record (the original record) later on
                    # when adding items for example
                    C4::Biblio::_koha_marc_update_bib_ids( $record, $framework, $record_id, $biblioitemnumber );
                } else {
                    warn "WARNING: Insert biblio $originalid skipped";
                    printlog(
                        {
                            id     => $originalid, op => "insert",
                            status => "warning : biblio not in database and option -insert not enabled, skipping..."
                        }
                    ) if ($logfile);
                    next RECORD;
                }
                my $record_has_added_items = 0;
                if ($record_id) {
                    $yamlhash->{$originalid} = $record_id if $yamlfile;
                    eval {
                        ( $itemnumbers_ref, $errors_ref ) =
                            AddItemBatchFromMarc( $record, $record_id, $biblioitemnumber, $framework );
                    };
                    my $error_adding = $@;

                    if ($error_adding) {
                        warn "ERROR: Adding items to bib $record_id failed: $error_adding";
                        printlog( { id => $record_id, op => "insert items", status => "ERROR" } ) if ($logfile);

                        # if we failed because of an exception, assume that
                        # the MARC columns in biblioitems were not set.
                        next RECORD;
                    }

                    $record_has_added_items = @{$itemnumbers_ref};

                    if ( $dedup_barcode && grep { exists $_->{error_code} && $_->{error_code} eq 'duplicate_barcode' }
                        @$errors_ref )
                    {
                        # Find the record called 'barcode'
                        my ( $tag, $sub ) = C4::Biblio::GetMarcFromKohaField('items.barcode');

                        # Now remove any items that didn't have a duplicate_barcode error,
                        # erase the barcodes on items that did, and re-add those items.
                        my %dupes;
                        foreach my $i ( 0 .. $#{$errors_ref} ) {
                            my $ref = $errors_ref->[$i];
                            if ( $ref && ( $ref->{error_code} eq 'duplicate_barcode' ) ) {
                                $dupes{ $ref->{item_sequence} } = 1;

                                # Delete the error message because we're going to
                                # retry this one.
                                delete $errors_ref->[$i];
                            }
                        }
                        my $seq = 0;
                        foreach my $field ( $record->field($tag) ) {
                            $seq++;
                            if ( $dupes{$seq} ) {

                                # Here we remove the barcode
                                $field->delete_subfield( code => $sub );
                            } else {

                                # otherwise we delete the field because we don't want
                                # two of them
                                $record->delete_fields($field);
                            }
                        }

                        # Now re-add the record as before, adding errors to the prev list
                        my $more_errors;
                        eval {
                            ( $itemnumbers_ref, $more_errors ) =
                                AddItemBatchFromMarc( $record, $record_id, $biblioitemnumber, '' );
                        };
                        if ($@) {
                            warn "ERROR: Adding items to bib $record_id failed: $@\n";
                            printlog( { id => $record_id, op => "insert items", status => "ERROR" } ) if ($logfile);

                            # if we failed because of an exception, assume that
                            # the MARC columns in biblioitems were not set.
                            next RECORD;
                        }
                        $record_has_added_items ||= @{$itemnumbers_ref};
                        if ( @{$more_errors} ) {
                            push @$errors_ref, @{$more_errors};
                        }
                    }

                    if ($record_has_added_items) {
                        printlog( { id => $record_id, op => "insert items", status => "ok" } ) if ($logfile);
                    }

                    if ( @{$errors_ref} ) {
                        report_item_errors( $record_id, $errors_ref );
                    }

                    my $biblio = Koha::Biblios->find($record_id);
                    $record = $biblio->metadata_record( { embed_items => 1 } );

                    if ($indexer) {
                        push @search_engine_record_ids, $record_id;
                        push @search_engine_records,    $record;
                    }
                }
            }
        }
        print $record->as_formatted() . "\n" if ( $verbose // 0 ) == 2;
    } else {
        $records_exhausted = 1;
    }

    if ( !$test_parameter && $record_number % $commitnum == 0 || $record_number == $number || $records_exhausted ) {
        if ($indexer) {
            $indexer->update_index( \@search_engine_record_ids, \@search_engine_records ) unless $skip_indexing;
            if ( C4::Context->preference('AutoLinkBiblios') ) {
                foreach my $record (@search_engine_records) {
                    BiblioAutoLink( $record, $framework );
                }
            }
            @search_engine_record_ids = ();
            @search_engine_records    = ();
        }
        $schema->txn_commit;
        $schema->txn_begin;
    }
    last if $record_number == $number || $records_exhausted;
}

if ( !$test_parameter ) {
    $schema->txn_commit;
}

if ($fk_off) {
    $dbh->do("SET FOREIGN_KEY_CHECKS = 1");
}

# Restore CataloguingLog and AuthoritiesLog
delete $ENV{OVERRIDE_SYSPREF_CataloguingLog};
delete $ENV{OVERRIDE_SYSPREF_AuthoritiesLog};

my $timeneeded = gettimeofday - $starttime;
print "\n$record_number MARC records done in $timeneeded seconds\n";
if ($logfile) {
    print $loghandle "file : $input_marc_file\n";
    print $loghandle "$record_number MARC records done in $timeneeded seconds\n";
    $loghandle->close;
}
if ($yamlfile) {
    open my $yamlfileout, q{>}, "$yamlfile" or die "cannot open $yamlfile \n";
    print $yamlfileout Encode::decode_utf8( YAML::XS::Dump($yamlhash) );
}
exit 0;

sub YAMLFileEntry {
    my ( $record, $record_id, $updated ) = @_;

    my $entry = { authid => $record_id };

    # we recover all subfields of the heading authorities
    my @subfields;
    foreach my $field ( $record->field("2..") ) {
        push @subfields, map { ( $_->[0] =~ /[a-z]/ ? $_->[1] : () ) } $field->subfields();
    }
    $entry->{'subfields'} = \@subfields;
    $entry->{'updated'}   = $updated;

    return $entry;
}

sub RecordRevisionIsGtOrEq {
    my ( $record_a, $record_b ) = @_;
    return
           $record_a->field('005')
        && $record_b->field('005')
        && $record_a->field('005')->data
        && $record_b->field('005')->data
        && $record_a->field('005')->data >= $record_b->field('005')->data;
}

sub GetRecordId {
    my $marcrecord = shift;
    my $tag        = shift;
    my $subfield   = shift;
    if ( $tag lt "010" ) {
        return $marcrecord->field($tag)->data() if $marcrecord->field($tag);
    } elsif ($subfield) {
        if ( $marcrecord->field($tag) ) {
            return $marcrecord->subfield( $tag, $subfield );
        }
    }
}

sub build_query {
    my ( $match, $record ) = @_;
    my @searchstrings;

    foreach my $matchpoint (@$match) {
        my $query = build_simplequery( $matchpoint, $record );
        push( @searchstrings, $query ) if $query;
    }
    my $op = 'AND';
    return join( " $op ", @searchstrings );
}

sub build_simplequery {
    my ( $matchpoint, $record ) = @_;

    my @searchstrings;
    my ( $index, $record_data ) = split( /,/, $matchpoint );
    if ( $record_data =~ /(\d{3})(.*)/ ) {
        my ( $tag, $subfields ) = ( $1, $2 );
        foreach my $field ( $record->field($tag) ) {
            if ( length( $field->as_string("$subfields") ) > 0 ) {
                push( @searchstrings, "$index:\"" . $field->as_string("$subfields") . "\"" );
            }
        }
    } else {
        print "Invalid matchpoint format, invalid marc-field: $matchpoint\n";
    }
    my $op = 'AND';
    return join( " $op ", @searchstrings );
}

sub report_item_errors {
    my $biblionumber = shift;
    my $errors_ref   = shift;

    foreach my $error ( @{$errors_ref} ) {
        next if !$error;
        my $msg =
            "Item not added (bib $biblionumber, item tag #$error->{'item_sequence'}, barcode $error->{'item_barcode'}): ";
        my $error_code = $error->{'error_code'};
        $error_code =~ s/_/ /g;
        $msg .= "$error_code $error->{'error_information'}";
        print $msg, "\n";
    }
}

sub printlog {
    my $logelements = shift;
    print $loghandle join( ";", map { defined $_ ? $_ : "" } @$logelements{qw<id op status>} ), "\n";
}

sub get_heading_fields {
    my $headingfields;
    if ($authtypes) {
        $headingfields = YAML::XS::LoadFile($authtypes);
        $headingfields = { C4::Context->preference('marcflavour') => $headingfields };
        $logger->debug( Encode::decode_utf8( YAML::XS::Dump($headingfields) ) );
    }
    unless ($headingfields) {
        $headingfields = $dbh->selectall_hashref(
            "SELECT auth_tag_to_report, authtypecode from auth_types", 'auth_tag_to_report',
            { Slice => {} }
        );
        $headingfields = { C4::Context->preference('marcflavour') => $headingfields };
    }
    return $headingfields;
}

=head1 NAME

bulkmarcimport.pl - Import bibliographic/authority records into Koha

=head1 USAGE

 $ export KOHA_CONF=/etc/koha.conf
 $ perl misc/migration_tools/bulkmarcimport.pl -d --commit 1000 \\
    --file /home/jmf/koha.mrc -n 3000

=head1 WARNING

Don't use this script before you've entered and checked your MARC parameters
tables twice (or more!). Otherwise, the import won't work correctly and you
will get invalid data.

=head1 DESCRIPTION

=over

=item  B<-h, --help>

This version/help screen

=item B<-b, --biblios>

Type of import: bibliographic records

=item B<-a, --authorities>

Type of import: authority records

=item B<--file>=I<FILE>

The I<FILE> to import

=item  B<-v, --verbose>

Verbose mode. 1 means "some infos", 2 means "MARC dumping"

=item B<--fk>

Turn off foreign key checks during import.

=item B<-n>=I<NUMBER>

The I<NUMBER> of records to import. If missing, all the file is imported

=item B<-o, --offset>=I<NUMBER>

File offset before importing, ie I<NUMBER> of records to skip.

=item B<--commit>=I<NUMBER>

The I<NUMBER> of records to wait before performing a 'commit' operation

=item B<-l>

File logs actions done for each record and their status into file

=item B<--append>

If specified, data will be appended to the logfile. If not, the logfile will be erased for each execution.

=item B<-t, --test>

Test mode: parses the file, saying what it would do, but doing nothing.

=item B<-s>

Skip automatic conversion of MARC-8 to UTF-8.  This option is provided for
debugging.

=item B<-c>=I<CHARACTERISTIC>

The I<CHARACTERISTIC> MARC flavour. At the moment, only I<MARC21> and
I<UNIMARC> are supported. MARC21 by default.

=item B<-d, --delete>

Delete EVERYTHING related to biblio in koha-DB before import. Tables: biblio,
biblioitems, items

=item B<-m>=I<FORMAT>

Input file I<FORMAT>: I<MARCXML> or I<ISO2709> (defaults to ISO2709)

=item B<--authtypes>

file yamlfile with authoritiesTypes and distinguishable record field in order
to store the correct authtype

=item B<--yaml>

yaml file  format a yaml file with ids

=item B<--filter>

list of fields that will not be imported. Can be any from 000 to 999 or field,
subfield and subfield's matching value such as 200avalue

=item B<--insert>

if set, only insert when possible

=item B<--update>

if set, only updates (any biblio should have a matching record)

=item B<--all>

if set, do whatever is required

=item B<-k, --keepids>=<FIELD>

Field store ids in I<FIELD> (useful for authorities, where 001 contains the
authid for Koha, that can contain a very valuable info for authorities coming
from LOC or BNF. useless for biblios probably)

=item B<--match>=<FIELD>

I<FIELD> matchindex,fieldtomatch matchpoint to use to deduplicate fieldtomatch
can be either 001 to 999 or field and list of subfields as such 100abcde

=item B<-i, --isbn>

If set, a search will be done on isbn, and, if the same isbn is found, the
biblio is not added. It's another method to deduplicate.  B<-match> & B<-isbn>
can be both set.

=item B<--cleanisbn>

Clean ISBN fields from entering biblio records, ie removes hyphens. By default,
ISBN are cleaned. --nocleanisbn will keep ISBN unchanged.

=item B<-x>=I<TAG>

Source bib I<TAG> for reporting the source bib number

=item B<-y>=I<SUBFIELD>

Source I<SUBFIELD> for reporting the source bib number

=item B<--idmap>=I<FILE>

I<FILE> for the koha bib and source id

=item B<--keepids>

Store ids in 009 (useful for authorities, where 001 contains the authid for
Koha, that can contain a very valuable info for authorities coming from LOC or
BNF. useless for biblios probably)

=item B<--dedupbarcode>

If set, whenever a duplicate barcode is detected, it is removed and the attempt
to add the record is retried, thereby giving the record a blank barcode. This
is useful when something has set barcodes to be a biblio ID, or similar
(usually other software.)

=item B<--framework>

This is the code for the framework that the requested records will have attached
to them when they are created. If not specified, then the default framework
will be used.

=item B<--custom>=I<MODULE>

This parameter allows you to use a local module with a customize subroutine
that is called for each MARC record.
If no filename is passed, LocalChanges.pm is assumed to be in the
migration_tools subdirectory. You may pass an absolute file name or a file name
from the migration_tools directory.

=item B<--marcmodtemplate>=I<TEMPLATE>

This parameter allows you to specify the name of an existing MARC
modification template to apply as the MARC records are imported (these
templates are created in the "MARC modification templates" tool in Koha).
If not specified, no MARC modification templates are used (default).

=item B<-si, --skip_indexing>

If set, do not index the imported records with Zebra or Elasticsearch.
Use this when you plan to do a complete reindex of your data after running
bulkmarciport. This can increase performance and avoid unnecessary load.

=item B<-sk, --skip_bad_records>

If set, check the validity of records before adding. If they are invalid we will
print the output of MARC::Lint->check_record and skip them during the import. Without
this option bad records may kill the job.

=back

=cut

