#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) YEAR  YOURNAME-OR-YOUREMPLOYER
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

use strict;
use warnings;
use diagnostics;

use C4::InstallAuth;
use CGI qw ( -utf8 );
use POSIX qw(strftime);

use C4::Context;
use C4::Output;
use C4::Templates;
use C4::Languages qw(getAllLanguages getTranslatedLanguages);
use C4::Installer;

use Koha;

my $query = new CGI;
my $step  = $query->param('step');

my $language = $query->param('language');
my ( $template, $loggedinuser, $cookie );

my $all_languages = getAllLanguages();

if ( defined($language) ) {
    C4::Templates::setlanguagecookie( $query, $language, "install.pl?step=1" );
}
( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "installer/step" . ( $step ? $step : 1 ) . ".tt",
        query         => $query,
        type          => "intranet",
        authnotrequired => 0,
        debug           => 1,
    }
);

my $installer = C4::Installer->new();
my %info;
$info{'dbname'} = C4::Context->config("database");
$info{'dbms'}   = (
      C4::Context->config("db_scheme")
    ? C4::Context->config("db_scheme")
    : "mysql"
);
$info{'hostname'} = C4::Context->config("hostname");
$info{'port'}     = C4::Context->config("port");
$info{'user'}     = C4::Context->config("user");
$info{'password'} = C4::Context->config("pass");
$info{'tls'} = C4::Context->config("tls");
    if ($info{'tls'} && $info{'tls'} eq 'yes'){
        $info{'ca'} = C4::Context->config('ca');
        $info{'cert'} = C4::Context->config('cert');
        $info{'key'} = C4::Context->config('key');
        $info{'tlsoptions'} = ";mysql_ssl=1;mysql_ssl_client_key=".$info{key}.";mysql_ssl_client_cert=".$info{cert}.";mysql_ssl_ca_file=".$info{ca};
        $info{'tlscmdline'} =  " --ssl-cert ". $info{cert} . " --ssl-key " . $info{key} . " --ssl-ca ".$info{ca}." "
    }

my $dbh = DBI->connect(
    "DBI:$info{dbms}:dbname=$info{dbname};host=$info{hostname}"
      . ( $info{port} ? ";port=$info{port}" : "" )
      . ( $info{tlsoptions} ? $info{tlsoptions} : "" ),
    $info{'user'}, $info{'password'}
);

if ( $step && $step == 1 ) {

    #First Step (for both fresh installations and upgrades)
    #Checking ALL perl Modules and services needed are installed.
    #Whenever there is an error, adding a report to the page
    my $op = $query->param('op') || 'noop';
    $template->param( language      => 1 );
    $template->param( 'checkmodule' => 1 )
      ; # we start with the assumption that there are no problems and set this to 0 if there are

    unless ( $] >= 5.010000 ) {    # Bug 7375
        $template->param( problems => 1, perlversion => 1, checkmodule => 0 );
    }

    my $perl_modules = C4::Installer::PerlModules->new;
    $perl_modules->versions_info;

    my $modules = $perl_modules->get_attr('missing_pm');
    if ( scalar(@$modules) ) {
        my @components  = ();
        my $checkmodule = 1;
        foreach (@$modules) {
            my ( $module, $stats ) = each %$_;
            $checkmodule = 0 if $stats->{'required'};
            push(
                @components,
                {
                    name    => $module,
                    version => $stats->{'min_ver'},
                    require => $stats->{'required'},
                    usage   => $stats->{'usage'},
                }
            );
        }
        @components = sort { $a->{'name'} cmp $b->{'name'} } @components;
        $template->param(
            missing_modules => \@components,
            checkmodule     => $checkmodule,
            op              => $op
        );
    }
}
elsif ( $step && $step == 2 ) {

    #STEP 2 Check Database connection and access

    $template->param(%info);
    my $checkdb = $query->param("checkdb");
    $template->param( 'dbconnection' => $checkdb );
    if ($checkdb) {
        if ($dbh) {

            # Can connect to the mysql
            $template->param( "checkdatabaseaccess" => 1 );
            if ( $info{dbms} eq "mysql" ) {

                #Check if database created
                my $rv = $dbh->do("SHOW DATABASES LIKE \'$info{dbname}\'");
                if ( $rv == 1 ) {
                    $template->param( 'checkdatabasecreated' => 1 );
                }

                #Check if user have all necessary grants on this database.
                my $rq =
                  $dbh->prepare(
                    "SHOW GRANTS FOR \'$info{user}\'\@'$info{hostname}'");
                $rq->execute;
                my $grantaccess;
                while ( my ($line) = $rq->fetchrow ) {
                    my $dbname = $info{dbname};
                    if ( $line =~ m/^GRANT (.*?) ON `$dbname`\.\*/
                        || index( $line, '*.*' ) > 0 )
                    {
                        $grantaccess = 1
                          if (
                            index( $line, 'ALL PRIVILEGES' ) > 0
                            || (   ( index( $line, 'SELECT' ) > 0 )
                                && ( index( $line, 'INSERT' ) > 0 )
                                && ( index( $line, 'UPDATE' ) > 0 )
                                && ( index( $line, 'DELETE' ) > 0 )
                                && ( index( $line, 'CREATE' ) > 0 )
                                && ( index( $line, 'DROP' ) > 0 ) )
                          );
                    }
                }
                unless ($grantaccess) {
                    $rq =
                      $dbh->prepare("SHOW GRANTS FOR \'$info{user}\'\@'\%'");
                    $rq->execute;
                    while ( my ($line) = $rq->fetchrow ) {
                        my $dbname = $info{dbname};
                        if ( $line =~ m/$dbname/ || index( $line, '*.*' ) > 0 )
                        {
                            $grantaccess = 1
                              if (
                                index( $line, 'ALL PRIVILEGES' ) > 0
                                || (   ( index( $line, 'SELECT' ) > 0 )
                                    && ( index( $line, 'INSERT' ) > 0 )
                                    && ( index( $line, 'UPDATE' ) > 0 )
                                    && ( index( $line, 'DELETE' ) > 0 )
                                    && ( index( $line, 'CREATE' ) > 0 )
                                    && ( index( $line, 'DROP' ) > 0 ) )
                              );
                        }
                    }
                }
                $template->param( "checkgrantaccess" => $grantaccess );
            }    # End mysql connect check...

            elsif ( $info{dbms} eq "Pg" ) {

                # Check if database has been created...
                my $rv = $dbh->do(
"SELECT * FROM pg_catalog.pg_database WHERE datname = \'$info{dbname}\';"
                );
                if ( $rv == 1 ) {
                    $template->param( 'checkdatabasecreated' => 1 );
                }

                # Check if user has all necessary grants on this database...
                my $rq = $dbh->do(
                    "SELECT u.usesuper
            FROM pg_catalog.pg_user as u
            WHERE u.usename = \'$info{user}\';"
                );
                if ( $rq == 1 ) {
                    $template->param( "checkgrantaccess" => 1 );
                }
            }    # End Pg connect check...
        }
        else {
            $template->param( "error" => DBI::err, "message" => DBI::errstr );
        }
    }
}
elsif ( $step && $step == 3 ) {

    # STEP 3 : database setup

    my $op = $query->param('op');
    if ( $op && $op eq 'finished' ) {
        #
        # we have finished, just redirect to mainpage.
        #
        print $query->redirect("/cgi-bin/koha/mainpage.pl");
        exit;
    }
    elsif ( $op && $op eq 'finish' ) {
        $installer->set_version_syspref();

# Installation is finished.
# We just deny anybody access to install
# And we redirect people to mainpage.
# The installer will have to relogin since we do not pass cookie to redirection.
        $template->param( "$op" => 1 );
    }

    elsif ( $op && $op eq 'addframeworks' ) {

        # 1ST install, 3rd sub-step : insert the SQL files the user has selected

        my ( $fwk_language, $list ) =
          $installer->load_sql_in_order( $all_languages,
            $query->multi_param('framework') );
        $template->param(
            "fwklanguage" => $fwk_language,
            "list"        => $list
        );
        use Koha::SearchEngine::Elasticsearch;
        Koha::SearchEngine::Elasticsearch->reset_elasticsearch_mappings;
        $template->param( "$op" => 1 );
    }
    elsif ( $op && $op eq 'selectframeworks' ) {
#
#
# 1ST install, 2nd sub-step : show the user the sql datas they can insert in the database.
#
#
# (note that the term "selectframeworks is not correct. The user can select various files, not only frameworks)

#Framework Selection
#sql data for import are supposed to be located in installer/data/<language>/<level>
# Where <language> is en|fr or any international abbreviation (provided language hash is updated... This will be a problem with internationlisation.)
# Where <level> is a category of requirement : required, recommended optional
# level should contain :
#   SQL File for import With a readable name.
#   txt File that explains what this SQL File is meant for.
# Could be VERY useful to have A Big file for a kind of library.
# But could also be useful to have some Authorised values data set prepared here.
# Framework Selection is achieved through checking boxes.
        my $langchoice = $query->param('fwklanguage');
        $langchoice = $query->cookie('KohaOpacLanguage') unless ($langchoice);
        $langchoice =~ s/[^a-zA-Z_-]*//g;
        my $marcflavour = $query->param('marcflavour');
        if ($marcflavour) {
            $installer->set_marcflavour_syspref($marcflavour);
        }
        $marcflavour = C4::Context->preference('marcflavour')
          unless ($marcflavour);

        #Insert into database the selected marcflavour
        undef $/;
        my ( $marc_defaulted_to_en, $fwklist ) =
          $installer->marc_framework_sql_list( $langchoice, $marcflavour );
        $template->param( 'en_marc_frameworks' => $marc_defaulted_to_en );
        $template->param( "frameworksloop"     => $fwklist );
        $template->param( "marcflavour"        => ucfirst($marcflavour) );

        my ( $sample_defaulted_to_en, $levellist ) =
          $installer->sample_data_sql_list($langchoice);
        $template->param( "en_sample_data" => $sample_defaulted_to_en );
        $template->param( "levelloop"      => $levellist );
        $template->param( "$op"            => 1 );

    }
    elsif ( $op && $op eq 'choosemarc' ) {
        #
        #
        # 1ST install, 2nd sub-step : show the user the marcflavour available.
        #
        #

#Choose Marc Flavour
#sql data are supposed to be located in installer/data/<dbms>/<language>/marcflavour/marcflavourname
# Where <dbms> is database type according to DBD syntax
# Where <language> is en|fr or any international abbreviation (provided language hash is updated... This will be a problem with internationlisation.)
# Where <level> is a category of requirement : required, recommended optional
# level should contain :
#   SQL File for import With a readable name.
#   txt File taht explains what this SQL File is meant for.
# Could be VERY useful to have A Big file for a kind of library.
# But could also be useful to have some Authorised values data set prepared here.
# Marcflavour Selection is achieved through radiobuttons.
        my $langchoice = $query->param('fwklanguage');

        $langchoice = $query->cookie('KohaOpacLanguage') unless ($langchoice);
        $langchoice =~ s/[^a-zA-Z_-]*//g;
        my $dir =
          C4::Context->config('intranetdir')
          . "/installer/data/$info{dbms}/$langchoice/marcflavour";
        unless ( opendir( MYDIR, $dir ) ) {
            if ( $langchoice eq 'en' ) {
                warn "cannot open MARC frameworks directory $dir";
            }
            else {
                # if no translated MARC framework is available,
                # default to English
                $dir = C4::Context->config('intranetdir')
                  . "/installer/data/$info{dbms}/en/marcflavour";
                opendir( MYDIR, $dir )
                  or warn "cannot open English MARC frameworks directory $dir";
            }
        }
        my @listdir = grep { !/^\./ && -d "$dir/$_" } readdir(MYDIR);
        closedir MYDIR;
        my $marcflavour = C4::Context->preference("marcflavour");
        my @flavourlist;
        foreach my $marc (@listdir) {
             my %cell=(
                 "label"=> ucfirst($marc),
                  "code"=>uc($marc),
               "checked"=> defined($marcflavour) ? uc($marc) eq $marcflavour : 0);
#             $cell{"description"}= do { local $/ = undef; open INPUT "<$dir/$marc.txt"||"";<INPUT> };
             push @flavourlist, \%cell;
        }
        $template->param( "flavourloop" => \@flavourlist );
        $template->param( "$op"         => 1 );
    }
    elsif ( $op && $op eq 'importdatastructure' ) {
        #
        #
        # 1st install, 1st "sub-step" : import kohastructure
        #
        #
        my $error = $installer->load_db_schema();
        $template->param(
            "error" => $error,
            "$op"   => 1,
        );
    }
    elsif ( $op && $op eq 'updatestructure' ) {
        #
        # Not 1st install, the only sub-step : update database
        #
        #Do updatedatabase And report

        if ( !defined $ENV{PERL5LIB} ) {
            my $find = "C4/Context.pm";
            my $path = $INC{$find};
            $path =~ s/\Q$find\E//;
            $ENV{PERL5LIB} = "$path:$path/installer";
            warn "# plack? inserted PERL5LIB $ENV{PERL5LIB}\n";
        }

        my $now         = POSIX::strftime( "%Y-%m-%dT%H:%M:%S", localtime() );
        my $logdir      = C4::Context->config('logdir');
        my $dbversion   = C4::Context->preference('Version');
        my $kohaversion = Koha::version;
        $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;

        my $filename_suffix = join '_', $now, $dbversion, $kohaversion;
        my ( $logfilepath, $logfilepath_errors ) = (
            chk_log( $logdir, "updatedatabase_$filename_suffix" ),
            chk_log( $logdir, "updatedatabase-error_$filename_suffix" )
        );

        my $cmd = C4::Context->config("intranetdir")
          . "/installer/data/$info{dbms}/updatedatabase.pl >> $logfilepath 2>> $logfilepath_errors";

        system($cmd );

        my $fh;
        open( $fh, "<:encoding(utf-8)", $logfilepath )
          or die "Cannot open log file $logfilepath: $!";
        my @report = <$fh>;
        close $fh;
        if (@report) {
            $template->param( update_report =>
                  [ map { { line => $_ } } split( /\n/, join( '', @report ) ) ]
            );
            $template->param( has_update_succeeds => 1 );
        }
        else {
            eval { `rm $logfilepath` };
        }
        open( $fh, "<:encoding(utf-8)", $logfilepath_errors )
          or die "Cannot open log file $logfilepath_errors: $!";
        @report = <$fh>;
        close $fh;
        if (@report) {
            $template->param( update_errors =>
                  [ map { { line => $_ } } split( /\n/, join( '', @report ) ) ]
            );
            $template->param( has_update_errors => 1 );
            warn
"The following errors were returned while attempting to run the updatedatabase.pl script:\n";
            foreach my $line (@report) { warn "$line\n"; }
        }
        else {
            eval { `rm $logfilepath_errors` };
        }
        $template->param( $op => 1 );
    }
    else {
#
# check whether it's a 1st install or an update
#
#Check if there are enough tables.
# Paul has cleaned up tables so reduced the count
#I put it there because it implied a data import if condition was not satisfied.
        my $dbh = DBI->connect(
    		"DBI:$info{dbms}:dbname=$info{dbname};host=$info{hostname}"
		. ( $info{port} ? ";port=$info{port}" : "" )
                . ( $info{tlsoptions} ? $info{tlsoptions} : "" ),
            	$info{'user'}, $info{'password'}
        );
        my $rq;
        if ( $info{dbms} eq 'mysql' ) { $rq = $dbh->prepare("SHOW TABLES"); }
        elsif ( $info{dbms} eq 'Pg' ) {
            $rq = $dbh->prepare(
                "SELECT *
                FROM information_schema.tables
                WHERE table_schema='public' and table_type='BASE TABLE';"
            );
        }
        $rq->execute;
        my $data = $rq->fetchall_arrayref( {} );
        my $count = scalar(@$data);
        #
        # we don't have tables, propose DB import
        #
        if ( $count < 70 ) {
            $template->param( "count" => $count, "proposeimport" => 1 );
        }
        else {
           #
           # we have tables, propose to select files to upload or updatedatabase
           #
            $template->param( "count" => $count, "default" => 1 );
     #
     # 1st part of step 3 : check if there is a databaseversion systempreference
     # if there is, then we just need to upgrade
     # if there is none, then we need to install the database
     #
            if ( C4::Context->preference('Version') ) {
                my $dbversion = C4::Context->preference('Version');
                $dbversion =~ /(.*)\.(..)(..)(...)/;
                $dbversion = "$1.$2.$3.$4";
                $template->param(
                    "upgrading"   => 1,
                    "dbversion"   => $dbversion,
                    "kohaversion" => Koha::version(),
                );
            }
        }
    }
}
else {

    # LANGUAGE SELECTION page by default
    # using opendir + language Hash
    my $languages_loop = getTranslatedLanguages('intranet');
    $template->param( installer_languages_loop => $languages_loop );
    if ($dbh) {
        my $rq =
          $dbh->prepare(
            "SELECT * from systempreferences WHERE variable='Version'");
        if ( $rq->execute ) {
            my ($version) = $rq->fetchrow;
            if ($version) {
                print $query->redirect(
                    "/cgi-bin/koha/installer/install.pl?step=3");
                exit;
            }
        }
    }
}
output_html_with_http_headers $query, $cookie, $template->output;

sub chk_log {    #returns a logfile in $dir or - if that failed - in temp dir
    my ( $dir, $name ) = @_;
    my $fn = $dir . '/' . $name . '.log';
    if ( !open my $fh, '>', $fn ) {
        $name .= '_XXXX';
        require File::Temp;
        ( $fh, $fn ) =
          File::Temp::tempfile( $name, TMPDIR => 1, SUFFIX => '.log' );

        #if this should not work, let croak take over
    }
    return $fn;
}
