package C4::Installer;

# Copyright (C) 2008 LibLime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

our $VERSION = 3.00;
use C4::Context;

=head1 NAME

C4::Installer

=head1 SYNOPSIS

use C4::Installer;

my $installer = C4::Installer->new();

my $all_languages = getAllLanguages();

my $error = $installer->load_db_schema();

my $list = $installer->sql_file_list('en', 'marc21', { optional => 1, mandatory => 1 });

my ($fwk_language, $error_list) = $installer->load_sql_in_order($all_languages, @$list);

$installer->set_version_syspref();

$installer->set_marcflavour_syspref('MARC21');

$installer->set_indexing_engine(0);

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=over 4

my $installer = C4::Installer->new();

=back

Creates a new installer.

=cut

sub new {
    my $class = shift;

    my $self = {};

    # get basic information from context
    $self->{'dbname'}   = C4::Context->config("database");
    $self->{'dbms'}     = C4::Context->config("db_scheme") ? C4::Context->config("db_scheme") : "mysql";
    $self->{'hostname'} = C4::Context->config("hostname");
    $self->{'port'}     = C4::Context->config("port");
    $self->{'user'}     = C4::Context->config("user");
    $self->{'password'} = C4::Context->config("pass");
    $self->{'dbh'} = DBI->connect("DBI:$self->{dbms}:dbname=$self->{dbname};host=$self->{hostname}" . 
                                  ( $self->{port} ? ";port=$self->{port}" : "" ),
                                  $self->{'user'}, $self->{'password'});
    $self->{'language'} = undef;
    $self->{'marcflavour'} = undef;

    bless $self, $class;
    return $self;
}


=head2 marc_framework_sql_list

=over 4

my ($defaulted_to_en, $list) = $installer->marc_framework_sql_list($lang, $marcflavour);

=back

Returns in C<$list> a structure listing the filename, description, section,
and mandatory/optional status of MARC framework scripts available for C<$lang>
and C<$marcflavour>.

If the C<$defaulted_to_en> return value is true, no scripts are available
for language C<$lang> and the 'en' ones are returned.

=cut

sub marc_framework_sql_list {
    my $self = shift;
    my $lang = shift;
    my $marcflavour = shift;

    my $defaulted_to_en = 0;

    undef $/;
    my $dir = C4::Context->config('intranetdir') . "/installer/data/$self->{dbms}/$lang/marcflavour/".lc($marcflavour);
    unless (opendir( MYDIR, $dir )) {
        if ($lang eq 'en') {
            warn "cannot open MARC frameworks directory $dir";
        } else {
            # if no translated MARC framework is available,
            # default to English
            $dir = C4::Context->config('intranetdir') . "/installer/data/$self->{dbms}/en/marcflavour/".lc($marcflavour);
            opendir(MYDIR, $dir) or warn "cannot open English MARC frameworks directory $dir";
            $defaulted_to_en = 1;
        }
    }
    my @listdir = sort grep { !/^\.|marcflavour/ && -d "$dir/$_" } readdir(MYDIR);
    closedir MYDIR;
   
    my @fwklist;
    my $request = $self->{'dbh'}->prepare("SELECT value FROM systempreferences WHERE variable='FrameworksLoaded'");
    $request->execute;
    my ($frameworksloaded) = $request->fetchrow;
    $frameworksloaded = '' unless defined $frameworksloaded; # avoid warning
    my %frameworksloaded;
    foreach ( split( /\|/, $frameworksloaded ) ) {
        $frameworksloaded{$_} = 1;
    }

    foreach my $requirelevel (@listdir) {
        opendir( MYDIR, "$dir/$requirelevel" );
        my @listname = grep { !/^\./ && -f "$dir/$requirelevel/$_" && $_ =~ m/\.sql$/ } readdir(MYDIR);
        closedir MYDIR;
        my %cell;
        my @frameworklist;
        map {
            my $name = substr( $_, 0, -4 );
            open FILE, "<:utf8","$dir/$requirelevel/$name.txt";
            my $lines = <FILE>;
            $lines =~ s/\n|\r/<br \/>/g;
            use utf8;
            utf8::encode($lines) unless ( utf8::is_utf8($lines) );
            my $mandatory = ($requirelevel =~ /(mandatory|requi|oblig|necess)/i);
            push @frameworklist,
              {
                'fwkname'        => $name,
                'fwkfile'        => "$dir/$requirelevel/$_",
                'fwkdescription' => $lines,
                'checked'        => ( ( $frameworksloaded{$_} || $mandatory ) ? 1 : 0 ),
                'mandatory'      => $mandatory,
              };
        } @listname;
        my @fwks =
          sort { $a->{'fwkname'} cmp $b->{'fwkname'} } @frameworklist;

        $cell{"frameworks"} = \@fwks;
        $cell{"label"}      = ucfirst($requirelevel);
        $cell{"code"}       = lc($requirelevel);
        push @fwklist, \%cell;
    }
 
    return ($defaulted_to_en, \@fwklist);
}

=head2 sample_data_sql_list

=over 4

my ($defaulted_to_en, $list) = $installer->sample_data_sql_list($lang);

=back

Returns in C<$list> a structure listing the filename, description, section,
and mandatory/optional status of sample data scripts available for C<$lang>.
If the C<$defaulted_to_en> return value is true, no scripts are available
for language C<$lang> and the 'en' ones are returned.

=cut

sub sample_data_sql_list {
    my $self = shift;
    my $lang = shift;

    my $defaulted_to_en = 0;

    undef $/;
    my $dir = C4::Context->config('intranetdir') . "/installer/data/$self->{dbms}/$lang";
    unless (opendir( MYDIR, $dir )) {
        if ($lang eq 'en') {
            warn "cannot open sample data directory $dir";
        } else {
            # if no sample data is available,
            # default to English
            $dir = C4::Context->config('intranetdir') . "/installer/data/$self->{dbms}/en";
            opendir(MYDIR, $dir) or warn "cannot open English sample data directory $dir";
            $defaulted_to_en = 1;
        }
    }
    my @listdir = sort grep { !/^\.|marcflavour/ && -d "$dir/$_" } readdir(MYDIR);
    closedir MYDIR;

    my @levellist;
    my $request = $self->{'dbh'}->prepare("SELECT value FROM systempreferences WHERE variable='FrameworksLoaded'");
    $request->execute;
    my ($frameworksloaded) = $request->fetchrow;
    $frameworksloaded = '' unless defined $frameworksloaded; # avoid warning
    my %frameworksloaded;
    foreach ( split( /\|/, $frameworksloaded ) ) {
        $frameworksloaded{$_} = 1;
    }

    foreach my $requirelevel (@listdir) {
        opendir( MYDIR, "$dir/$requirelevel" );
        my @listname = grep { !/^\./ && -f "$dir/$requirelevel/$_" && $_ =~ m/\.sql$/ } readdir(MYDIR);
        closedir MYDIR;
        my %cell;
        my @frameworklist;
        map {
            my $name = substr( $_, 0, -4 );
            open FILE, "<:utf8","$dir/$requirelevel/$name.txt";
            my $lines = <FILE>;
            $lines =~ s/\n|\r/<br \/>/g;
            use utf8;
            utf8::encode($lines) unless ( utf8::is_utf8($lines) );
            my $mandatory = ($requirelevel =~ /(mandatory|requi|oblig|necess)/i);
            push @frameworklist,
              {
                'fwkname'        => $name,
                'fwkfile'        => "$dir/$requirelevel/$_",
                'fwkdescription' => $lines,
                'checked'        => ( ( $frameworksloaded{$_} || $mandatory ) ? 1 : 0 ),
                'mandatory'      => $mandatory,
              };
        } @listname;
        my @fwks = sort { $a->{'fwkname'} cmp $b->{'fwkname'} } @frameworklist;

        $cell{"frameworks"} = \@fwks;
        $cell{"label"}      = ucfirst($requirelevel);
        $cell{"code"}       = lc($requirelevel);
        push @levellist, \%cell;
    }

    return ($defaulted_to_en, \@levellist);
}

=head2 sql_file_list

=over 4

my $list = $installer->sql_file_list($lang, $marcflavour, $subset_wanted);

=back

Returns an arrayref containing the filepaths of installer SQL scripts
available for laod.  The C<$lang> and C<$marcflavour> arguments
specify the desired language and MARC flavour. while C<$subset_wanted>
is a hashref containing possible named parameters 'mandatory' and 'optional'.

=cut

sub sql_file_list {
    my $self = shift;
    my $lang = shift;
    my $marcflavour = shift;
    my $subset_wanted = shift;

    my ($marc_defaulted_to_en, $marc_sql) = $self->marc_framework_sql_list($lang, $marcflavour);
    my ($sample_defaulted_to_en, $sample_sql) = $self->sample_data_sql_list($lang);
    
    my @sql_list = ();
    map { 
        map {
            if ($subset_wanted->{'mandatory'}) {
                push @sql_list, $_->{'fwkfile'} if $_->{'mandatory'};
            }
            if ($subset_wanted->{'optional'}) {
                push @sql_list, $_->{'fwkfile'} unless $_->{'mandatory'};
            }
        } @{ $_->{'frameworks'} }
    } (@$marc_sql, @$sample_sql);
    
    return \@sql_list
}

=head2 load_db_schema 

=over 4

my $error = $installer->load_db_schema();

=back

Loads the SQL script that creates Koha's tables and indexes.  The
return value is a string containing error messages reported by the
load.

=cut

sub load_db_schema {
    my $self = shift;

    my $datadir = C4::Context->config('intranetdir') . "/installer/data/$self->{dbms}";
    my $error = $self->load_sql("$datadir/kohastructure.sql");
    return $error;

}

=head2 load_sql_in_order

=over 4

my ($fwk_language, $list) = $installer->load_sql_in_order($all_languages, @sql_list);

=back

Given a list of SQL scripts supplied in C<@sql_list>, loads each of them
into the database and sets the FrameworksLoaded system preference to names
of the scripts that were loaded.

The SQL files are loaded in alphabetical order by filename (not including
directory path).  This means that dependencies among the scripts are to
be resolved by carefully naming them, keeping in mind that the directory name
does *not* currently count.

FIXME: this is a rather delicate way of dealing with dependencies between 
       the install scripts.

The return value C<$list> is an arrayref containing a hashref for each
"level" or directory containing SQL scripts; the hashref in turns contains
a list of hashrefs containing a list of each script load and any error
messages associated with the loading of each script.

FIXME: The C<$fwk_language> code probably doesn't belong and needs to be
moved to a different method.

=cut

sub load_sql_in_order {
    my $self = shift;
    my $all_languages = shift;
    my @sql_list = @_;

    my $lang;
    my %hashlevel;
    my @fnames = sort {
        my @aa = split /\/|\\/, ($a);
        my @bb = split /\/|\\/, ($b);
        $aa[-1] cmp $bb[-1]
    } @sql_list;
    my $request = $self->{'dbh'}->prepare( "SELECT value FROM systempreferences WHERE variable='FrameworksLoaded'" );
    $request->execute;
    my ($systempreference) = $request->fetchrow;
    $systempreference = '' unless defined $systempreference; # avoid warning
    foreach my $file (@fnames) {
        #      warn $file;
        undef $/;
        my $error = $self->load_sql($file);
        my @file = split qr(\/|\\), $file;
        $lang = $file[ scalar(@file) - 3 ] unless ($lang);
        my $level = $file[ scalar(@file) - 2 ];
        unless ($error) {
            $systempreference .= "$file[scalar(@file)-1]|"
              unless ( index( $systempreference, $file[ scalar(@file) - 1 ] ) >= 0 );
        }

        #Bulding here a hierarchy to display files by level.
        push @{ $hashlevel{$level} },
          { "fwkname" => $file[ scalar(@file) - 1 ], "error" => $error };
    }

    #systempreference contains an ending |
    chop $systempreference;
    my @list;
    map { push @list, { "level" => $_, "fwklist" => $hashlevel{$_} } } keys %hashlevel;
    my $fwk_language;
    for my $each_language (@$all_languages) {

        #       warn "CODE".$each_language->{'language_code'};
        #       warn "LANG:".$lang;
        if ( $lang eq $each_language->{'language_code'} ) {
            $fwk_language = $each_language->{language_locale_name};
        }
    }
    my $updateflag =
      $self->{'dbh'}->do(
        "UPDATE systempreferences set value=\"$systempreference\" where variable='FrameworksLoaded'"
      );

    unless ( $updateflag == 1 ) {
        my $string =
            "INSERT INTO systempreferences (value, variable, explanation, type) VALUES (\"$systempreference\",'FrameworksLoaded','Frameworks loaded through webinstaller','choice')";
        my $rq = $self->{'dbh'}->prepare($string);
        $rq->execute;
    }
    return ($fwk_language, \@list);
}

=head2 set_marcflavour_syspref 

=over 4

$installer->set_marcflavour_syspref($marcflavour);

=back

Set the 'marcflavour' system preference.  The incoming
C<$marcflavour> references to a subdirectory of
installer/data/$dbms/$lang/marcflavour, and is
normalized to MARC21 or UNIMARC.

FIXME: this method assumes that the MARC flavour will be either
MARC21 or UNIMARC.

=cut

sub set_marcflavour_syspref {
    my $self = shift;
    my $marcflavour = shift;

    # we can have some variants of marc flavour, by having different directories, like : unimarc_small and unimarc_full, for small and complete unimarc frameworks.
    # marc_cleaned finds the marcflavour, without the variant.
    my $marc_cleaned = 'MARC21';
    $marc_cleaned = 'UNIMARC' if $marcflavour =~ /unimarc/i;
    my $request =
        $self->{'dbh'}->prepare(
          "INSERT IGNORE INTO `systempreferences` (variable,value,explanation,options,type) VALUES('marcflavour','$marc_cleaned','Define global MARC flavor (MARC21 or UNIMARC) used for character encoding','MARC21|UNIMARC','Choice');"
        );
    $request->execute;
}

=head2 set_indexing_engine 

=over 4

$installer->set_indexing_engine($nozebra);

=back

Sets system preferences related to the indexing
engine.  The C<$nozebra> argument is a boolean;
if true, turn on NoZebra mode and turn off QueryFuzzy,
QueryWeightFields, and QueryStemming.  If false, turn
off NoZebra mode (i.e., use the Zebra search engine).

=cut

sub set_indexing_engine {
    my $self = shift;
    my $nozebra = shift;

    if ($nozebra) {
        $self->{'dbh'}->do("UPDATE systempreferences SET value=1 WHERE variable='NoZebra'");
        $self->{'dbh'}->do("UPDATE systempreferences SET value=0 WHERE variable in ('QueryFuzzy','QueryWeightFields','QueryStemming')");
    } else {
        $self->{'dbh'}->do("UPDATE systempreferences SET value=0 WHERE variable='NoZebra'");
    }

}

=head2 set_version_syspref

=over 4

$installer->set_version_syspref();

=back

Set or update the 'Version' system preference to the current
Koha software version.

=cut

sub set_version_syspref {
    my $self = shift;

    my $kohaversion=C4::Context::KOHAVERSION;
    # remove the 3 last . to have a Perl number
    $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
    if (C4::Context->preference('Version')) {
        warn "UPDATE Version";
        my $finish=$self->{'dbh'}->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
        $finish->execute($kohaversion);
    } else {
        warn "INSERT Version";
        my $finish=$self->{'dbh'}->prepare("INSERT into systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. WARNING: Do not change this value manually, it is maintained by the webinstaller')");
        $finish->execute($kohaversion);
    }
}

=head2 load_sql

=over 4

my $error = $installer->load_sql($filename);

=back

Runs a the specified SQL using the DB's command-line
SQL tool, and returns any strings sent to STDERR
by the command-line tool.

FIXME: there has been a long-standing desire to
       replace this with an SQL loader that goes
       through DBI; partly for portability issues
       and partly to improve error handling.

FIXME: even using the command-line loader, some more
       basic error handling should be added - deal
       with missing files, e.g.

=cut

sub load_sql {
    my $self = shift;
    my $filename = shift;

    my $datadir = C4::Context->config('intranetdir') . "/installer/data/$self->{dbms}";
    my $error;
    my $strcmd;
    if ( $self->{dbms} eq 'mysql' ) {
        $strcmd = "mysql "
            . ( $self->{hostname} ? " -h $self->{hostname} " : "" )
            . ( $self->{port}     ? " -P $self->{port} "     : "" )
            . ( $self->{user}     ? " -u $self->{user} "     : "" )
            . ( $self->{password} ? " -p'$self->{password}'"   : "" )
            . " $self->{dbname} ";
        $error = qx($strcmd <$filename 2>&1 1>/dev/null);
    } elsif ( $self->{dbms} eq 'Pg' ) {
        $strcmd = "psql "
            . ( $self->{hostname} ? " -h $self->{hostname} " : "" )
            . ( $self->{port}     ? " -p $self->{port} "     : "" )
            . ( $self->{user}     ? " -U $self->{user} "     : "" )
#            . ( $self->{password} ? " -W $self->{password}"   : "" )       # psql will NOT accept a password, but prompts...
            . " $self->{dbname} ";                        # Therefore, be sure to run 'trust' on localhost in pg_hba.conf -fbcit
        $error = qx($strcmd -f $filename 2>&1 1>/dev/null);
        # Be sure to set 'client_min_messages = error' in postgresql.conf
        # so that only true errors are returned to stderr or else the installer will 
        # report the import a failure although it really succeded -fbcit
    }
    return $error;
}

=head1 AUTHOR

C4::Installer is a refactoring of logic originally from installer/installer.pl, which was
originally written by Henri-Damien Laurant.

Koha Developement team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
