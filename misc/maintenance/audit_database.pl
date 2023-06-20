#!/usr/bin/perl

use Modern::Perl;
use SQL::Translator;
use SQL::Translator::Diff;
use Getopt::Long;

use C4::Context;

my $filename = "./installer/data/mysql/kohastructure.sql";

GetOptions(
    "filename=s" => \$filename,
) or die("Error in command line arguments\n");

if ( ! -f $filename ){
    die("Filename '$filename' does not exist\n");
}

my $sql_schema = get_kohastructure({ filename => $filename, });
my $db_schema = get_db();

if ($sql_schema && $db_schema){
    my $diff = SQL::Translator::Diff->new({
        output_db     => 'MySQL',
        source_schema => $db_schema,
        target_schema => $sql_schema,
    })->compute_differences->produce_diff_sql;

    print $diff;
    print "\n";
    print "WARNING!!!\n";
    print "These commands are only suggestions! They are not a replacement for updatedatabase.pl!\n";
    print "Review the database, updatedatabase.pl, and kohastructure.sql before making any changes!\n";
    print "\n";
}

sub get_db {
    my $database_name = C4::Context->config("database");
    print "Parsing schema for database '$database_name'\n";
    my $dbh = C4::Context->dbh;
    my $parser = SQL::Translator->new(
        parser => 'DBI',
        parser_args => {
            dbh => $dbh,
        },
    );
    my $schema = $parser->translate();

    #NOTE: Hack the schema to remove autoincrement
    #Otherwise, that difference will cause options for all tables to be reset unnecessarily
    my @tables = $schema->get_tables();
    foreach my $table (@tables){
        my @new_options = ();
        my $replace_options = 0;
        my $options = $table->{options};
        foreach my $hashref (@$options){
            if ( $hashref->{AUTO_INCREMENT} ){
                $replace_options = 1;
            }
            else {
                push(@new_options,$hashref);
            }
        }
        if ($replace_options){
            @{$table->{options}} = @new_options;
        }
    }
    return $schema;
}

sub get_kohastructure {
    my ($args) = @_;
    my $filename = $args->{filename};
    print "Parsing schema for file '$filename'\n";
    my $translator = SQL::Translator->new();
    $translator->parser("MySQL");
    my $schema = $translator->translate($filename);
    return $schema;
}
