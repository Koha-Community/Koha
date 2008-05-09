package KohaTest::Installer::SqlScripts;
use base qw( KohaTest::Installer );

use strict;
use warnings;

use Test::More;
use C4::Languages;
use C4::Installer;

sub startup_50_get_installer : Test( startup => 1 ) {
    my $self = shift;
    my $installer = C4::Installer->new();
    is(ref($installer), "C4::Installer", "created installer");
    $self->{installer} = $installer;
}

sub installer_all_sample_data : Tests {
    my $self = shift;

    skip "did not create installer" unless ref($self->{installer}) eq 'C4::Installer';

    my $all_languages = getAllLanguages();
    # find the available directory names
    my $dir=C4::Context->config('intranetdir')."/installer/data/" . 
            (C4::Context->config("db_scheme") ? C4::Context->config("db_scheme") : "mysql") . "/";
    opendir (MYDIR,$dir);
    my @languages = grep { !/^\.|CVS/ && -d "$dir/$_"} readdir(MYDIR);    
    closedir MYDIR;
    
    cmp_ok(scalar(@languages), '>', 0, "at least one framework language defined");
    
    foreach my $lang_code (@languages) {
        SKIP: {
            my $marc_flavours = $self->{installer}->marcflavour_list($lang_code);
            ok(defined($marc_flavours), "at least one MARC flavour for $lang_code");
            skip "no MARC flavours for $lang_code" unless defined($marc_flavours);

            foreach my $flavour (@$marc_flavours) {
                SKIP: {
                    $self->clear_test_database();
                    my $schema_error = $self->{installer}->load_db_schema();
                    is($schema_error, "", "no errors during schema load");
                    skip "error during schema load" if $schema_error ne "";
        
                    my $list = $self->{installer}->sql_file_list($lang_code, $flavour, { optional => 1, mandatory => 1 });
                    my $sql_count = scalar(@$list);
                    cmp_ok($sql_count, '>', 0, "at least one SQL init file for $lang_code, $flavour");
                    skip "no SQL init files defined for $lang_code, $flavour" unless $sql_count > 0;

                    my ($fwk_language, $installed_list) = $self->{installer}->load_sql_in_order($all_languages, @$list);

                    # extract list of files
                    my @file_list = map { map { $_ } @{  $_->{fwklist} } } @$installed_list; 
                    my $num_processed = scalar(@file_list);
                    cmp_ok($num_processed, '==', $sql_count, "processed all sql scripts for $lang_code, $flavour");

                    my %sql_to_load = map { my $file = $_; $file =~ s!^(.*)(/|\\)!!; $file => 1 } @$list;                    
                    foreach my $sql (@file_list) {
                        ok(exists($sql_to_load{ $sql->{fwkname} }), "SQL script $sql->{fwkname} is on list");
                        delete $sql_to_load{ $sql->{fwkname} };
                        is($sql->{error}, "", "no errors when loading $sql->{fwkname}");
                    }
                    ok(not(%sql_to_load), "no SQL scripts for $lang_code, $flavour left unloaded");
                }
            }
        }
    }
}

sub shutdown_50_clear_installer : Tests( shutdown ) {
    my $self = shift;
    delete $self->{installer};
}

1;
