#!/usr/bin/perl -w # please develop with -w

#use diagnostics;

# use Install;
use InstallAuth;
use C4::Context;
use C4::Output;
use C4::Languages;

use strict;    # please develop with the strict pragma

use CGI;

#
### Main Body ####
#
my $query = new CGI;
my $step  = $query->param('step') || 0;

my ($language, $template, $loggedinuser, $cookie);

if ($language = $query->param('language')) {	# assignment, not comparison
    setlanguagecookie( $query, $language, "install.pl?step=1" );
}
( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "installer/step" . ( $step ? $step : 1 ) . ".tmpl",
        query         => $query,
        type          => "intranet",
        authnotrequired => 0,
        debug           => 1,
    }
);

my %info;
$info{'dbname'} = C4::Context->config("database");
$info{'dbms'  } = (
      C4::Context->config("db_scheme")
    ? C4::Context->config("db_scheme")
    : "mysql" );
foreach (qw(hostname user password)) {
	$info{$_} = C4::Context->config($_);
}
($info{'hostname'}, $info{'port'}) = ($1,$2)
   if $info{'hostname'} =~ /([^:]*):([0-9]+)/;
my $dbh = DBI->connect(
    "DBI:$info{dbms}:$info{dbname}:$info{hostname}"
      . ( $info{port} ? ":$info{port}" : "" ),
    $info{'user'}, $info{'password'}
);

   if ($step == 1) {&step_one  ;}
elsif ($step == 2) {&step_two  ;}
elsif ($step == 3) {&step_three;}
else               {&step_else ;}

output_html_with_http_headers $query, $cookie, $template->output;

#
### Subroutines ###
# 
sub step_one {
    # Checking ALL perl Modules and services needed are installed.
    # Whenever there is an error, add a report to the page
    $template->param( language => 1 );
    my $problem;

    unless ( $] >= 5.006001 ) {    # Bug 179
        $template->param( "problems" => 1, "perlversion" => 1 );
        $problem = 1;
    }

    # We could here use a special find
    my @missing = ();
	my @required = qw(
		ZOOM
		LWP::Simple
		XML::Simple
		MARC::File::XML
		MARC::File::USMARC
		DBI
		Date::Manip
		DBD::mysql
		HTML::Template::Pro
		Date::Calc
		Digest::MD5
		MARC::Record
		List::MoreUtils
		XML::RSS
		CGI::Carp
		Mail::Sendmail
	);
	my %optional = (
		  'PDF::API2'            => 'usagebarcode',
		  'PDF::Reuse::Barcode'  => 'usagebarcode',
		  'PDF::Report'          => 'usagebarcode',
		  'Data::Random'         => 'usagebarcode',
		'Algorithm::CheckDigits' => 'usagebarcode',
		  'GD::Barcode'          => 'usagebarcode usagespine',
		  'GD::Barcode::UPCE'    => 'usagepine',
		  'Net::LDAP'            => 'usageLDAP',
		  'Mail::Sendmail'       => 'usagemail',
	);
	push @missing, map {{name => $_}} grep {! eval {require $_}} @required;

# The following modules are not mandatory, depends on how the library want to use Koha
	if ($#missing) {   # only when $#missing (is >= 0), so this isn't fatal
		foreach my $module (keys %optional) {
    		unless ( eval { require $module } ) {
				my @usages = split /\s+/, $optional{$module};
            	push @missing, { name => $module, map {$_ => 1} @usages };
        	}
		}
    	$template->param( missings => \@missing );
    }
    $template->param( 'checkmodule' => 1 ) unless (scalar(@missing) && $problem);
}

sub line_check ($) {
	my $line = shift;
	return 1 if (
		index( $line, 'ALL PRIVILEGES' ) > 0
		|| (   ( index( $line, 'SELECT' ) > 0 )
			&& ( index( $line, 'INSERT' ) > 0 )
			&& ( index( $line, 'UPDATE' ) > 0 )
			&& ( index( $line, 'DELETE' ) > 0 )
			&& ( index( $line, 'CREATE' ) > 0 )
			&& ( index( $line, 'DROP' ) > 0 ) )
	  );
	return 0;
}

sub step_two {
		# STEP 2 Check Database connection and access
    $template->param(%info);
    my $checkmysql = $query->param("checkmysql");
    $template->param( 'mysqlconnection' => $checkmysql );
    if ($checkmysql and $dbh) {
            # Can connect to the mysql
            $template->param( "checkdatabaseaccess" => 1 );
            if ( $info{dbms} eq "mysql" ) {

                #Check if database created
                my $rv = $dbh->do("SHOW DATABASES LIKE \'$info{dbname}\'");
                if ( $rv == 1 ) {
                    $template->param( 'checkdatabasecreated' => 1 );
                }

                #Check if user have all necessary grants on this database.
                my $rq = $dbh->prepare( "SHOW GRANTS FOR \'$info{user}\'\@'$info{hostname}'");
                $rq->execute;
                my $grantaccess;
                my $dbname = $info{dbname};
                while ( my ($line) = $rq->fetchrow ) {
                    if ( $line =~ /$dbname/ || index( $line, '*.*' ) > 0 ) {
                        line_check($line) and $grantaccess = 1;
                    }
                }
                unless ($grantaccess) {
                    $rq = $dbh->prepare("SHOW GRANTS FOR \'$info{user}\'\@'\%'");
                    $rq->execute;
                    while ( my ($line) = $rq->fetchrow ) {
                        if ( $line =~ /$dbname/ || index( $line, '*.*' ) > 0 ) {
                        	line_check($line) and $grantaccess = 1;
                        }
                    }
                }
                $template->param( "checkgrantaccess" => $grantaccess );
            }
        } else {
            $template->param( "error" => DBI::err, "message" => DBI::errstr );
        }
}

sub step_three {
		# STEP 3 : database setup
    my $op = $query->param('op') || '';
    if ($op eq 'finished') {		# we have finished, just redirect to mainpage.
        print $query->redirect("/cgi-bin/koha/mainpage.pl");
        exit 1;
    }
    elsif ($op eq 'finish') {
        my $kohaversion=C4::Context::KOHAVERSION;
        # remove the 3 last . to have a Perl number
        $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
		my $finish;
        if (C4::Context->preference('Version')) {
            warn "UPDATE Version";
            $finish=$dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
        } else {
            warn "INSERT Version";
            $finish=$dbh->prepare("INSERT into systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. Do not change this value manually, it is written by the webinstaller')");
        }

        $finish->execute($kohaversion);
        # Installation is finished.
        # We just deny anybody acess to install
        # And we redirect people to mainpage.
        # The installer wil have to relogin since we do not pass cookie to redirection.
        $template->param( "$op" => 1 );
    }
    elsif ($op eq 'Nozebra') {
        if ($query->param($op)) {
            $dbh->do("UPDATE systempreferences SET value=1 WHERE variable='$op'");
        } else {
            $dbh->do("UPDATE systempreferences SET value=0 WHERE variable='$op'");
        }
        $template->param( "$op" => 1 );
    }
    elsif ($op eq 'addframeworks') {
    # 1ST install, 3rd sub-step : insert the SQL files the user has selected
        #Framework importing and reports
        my $lang;
        my %hashlevel;

       # sort by filename -> prepend with numbers to specify order of insertion.
        my @fnames = sort {
            my @aa = split /\/|\\/, ($a);
            my @bb = split /\/|\\/, ($b);
            $aa[-1] lt $bb[-1]
        } $query->param('framework');
        $dbh->do('SET FOREIGN_KEY_CHECKS=0');
        my $request = $dbh->prepare(
            "SELECT value FROM systempreferences WHERE variable='FrameworksLoaded'"
          );
        $request->execute;
        my ($systempreference) = $request->fetchrow;
        foreach my $file (@fnames) {
            #      warn $file;
            undef $/;
            my $strcmd = "mysql "
              . ( $info{hostname} ? " -h $info{hostname} " : "" )
              . ( $info{port}     ? " -P $info{port} "     : "" )
              . ( $info{user}     ? " -u $info{user} "     : "" )
              . ( $info{password} ? " -p$info{password}"   : "" )
              . " $info{dbname} ";
            my $error = qx($strcmd < $file 2>&1);
            my @file = split qr(\/|\\), $file;		# odd use of qr
			my $fsize = scalar(@file);
            $lang = $file[$fsize-3] unless ($lang);
            my $level = $file[$fsize-2];
            unless ($error and index($systempreference, $file[$fsize-1]) >= 0) {
                $systempreference .= "$file[$fsize-1]|"
            }

            #Bulding here a hierarchy to display files by level.
            push @{ $hashlevel{$level} },
              { "fwkname" => $file[$fsize-1], "error" => $error };
        }

        #systempreference contains an ending |
        chop $systempreference;
        my @list;
        map { push @list, { "level" => $_, "fwklist" => $hashlevel{$_} } }
          keys %hashlevel;
        my $fwk_language;
        for my $each_language (getAllLanguages()) {
            # 		warn "CODE".$each_language->{'language_code'};
            # 		warn "LANG:".$lang;
            if ( $lang eq $each_language->{'language_code'} ) {
                $fwk_language = $each_language->{language_locale_name};
            }
        }
        my $updateflag =
          $dbh->do(
            "UPDATE systempreferences set value=\"$systempreference\" where variable='FrameworksLoaded'"
          );
        unless ( $updateflag == 1 ) {
            my $string =
                "INSERT INTO systempreferences (value, variable, explanation, type) VALUES (\"$systempreference\",'FrameworksLoaded','Frameworks loaded through webinstaller','choice')";
            my $rq = $dbh->prepare($string);
            $rq->execute;
        }
        $template->param(
            "fwklanguage" => $fwk_language,
            "list"        => \@list
        );
        $template->param( "$op" => 1 );
        $dbh->do('SET FOREIGN_KEY_CHECKS=1');
    }
    elsif ($op eq 'selectframeworks') {
        #
        #
        # 1ST install, 2nd sub-step : show the user the sql datas he can insert in the database.
        #
        #
        # (note that the term "selectframeworks is not correct. The user can select various files, not only frameworks)
        
        # Framework Selection
        # sql data for import are supposed to be located in installer/data/<language>/<level>
        # Where <language> is en|fr or any international abbreviation (provided language hash is updated... This will be a problem with internationlisation.)
        # Where <level> is a category of requirement : required, recommended, optional
        # level should contain :
        #   SQL File for import With a readable name.
        #   txt File taht explains what this SQL File is meant for.
        # Could be VERY useful to have A Big file for a kind of library.
        # But could also be useful to have some Authorised values data set prepared here.
        # Framework Selection is achieved through checking boxes.
        my $langchoice = $query->param('fwklanguage') ||
        				 $query->cookie('KohaOpacLanguage') ;
        my $dir = C4::Context->config('intranetdir') . "/installer/data/";
        opendir( MYDIR, $dir );
        my @listdir = grep { !/^\.|CVS/ && -d "$dir/$_" } readdir(MYDIR);
        closedir MYDIR;
        my $frmwklangs = getFrameworkLanguages();
        my @languages;
        map {				# inappropriate use of map in void context
            push @languages,
              {
                'dirname'             => $_->{'language_code'},
                'languagedescription' => $_->{'language_name'},
                'checked' => ( $_->{'language_code'} eq $langchoice )
              }
              if ( $_->{'language_code'} );
        } @$frmwklangs;
        $template->param( "languagelist" => \@languages );
        undef $/;
        $dir = C4::Context->config('intranetdir') . "/installer/data/$langchoice";
        opendir ( MYDIR, $dir ) or warn "Cannot read directory $dir";
        @listdir = sort grep { !/^\.|CVS/ && -d "$dir/$_" } readdir(MYDIR);
        closedir MYDIR;
        my @levellist;
        my $request = $dbh->prepare(
            "SELECT value FROM systempreferences WHERE variable='FrameworksLoaded'"
          );
        $request->execute;
        my ($frameworksloaded) = $request->fetchrow;
        my %frameworksloaded;

        foreach ( split( /\|/, $frameworksloaded ) ) {
            $frameworksloaded{$_} = 1;
        }
        foreach my $requirelevel (@listdir) {
            $dir =
              C4::Context->config('intranetdir')
              . "/installer/data/$langchoice/$requirelevel";
            opendir( MYDIR, $dir );
            my @listname =
              grep { !/^\.|CVS/ && -f "$dir/$_" && $_ =~ m/\.sql$/ }
              readdir(MYDIR);
            closedir MYDIR;
            my %cell;
            my @frameworklist;
            map {							# inappropriate use of map in void context
                my $name = substr( $_, 0, -4 );
                open FILE, "< $dir/$name.txt";
                my $lines = <FILE>;
                $lines =~ s/\n|\r/<br \/>/g;
                use utf8;					# this doesn't even make sense here.
                utf8::encode($lines) unless ( utf8::is_utf8($lines) );
                push @frameworklist,
                  {
                    'fwkname'        => $name,
                    'fwkfile'        => "$dir/$_",
                    'fwkdescription' => $lines,
                    'checked'        => (
                        (
                            $frameworksloaded{$_}
                              || ( $requirelevel =~
                                /(mandatory|requi|oblig|necess)/i )
                        ) ? 1 : 0
                    )
                  };
            } @listname;
            my @fwks =
              sort { $a->{'fwkname'} lt $b->{'fwkname'} } @frameworklist;

  #       $cell{"mandatory"}=($requirelevel=~/(mandatory|requi|oblig|necess)/i);
            $cell{"frameworks"} = \@fwks;
            $cell{"label"}      = ucfirst($requirelevel);
            $cell{"code"}       = lc($requirelevel);
            push @levellist, \%cell;
        }
        $template->param( "levelloop" => \@levellist );
        $template->param( "$op"       => 1 );
    }
    elsif ($op eq 'importdatastructure' ) {
        #
        #
        # 1st install, 1st "sub-step" : import kohastructure
        #
        #
        my $dbh = DBI->connect(
            "DBI:$info{dbms}:$info{dbname}:$info{hostname}"
              . ( $info{port} ? ":$info{port}" : "" ),
            $info{'user'}, $info{'password'}
        );
        open( INPUT, "<kohastructure.sql" );
        my $file = do { local $/ = undef; <INPUT> };
        my @commands = split( /;/, $file );
        pop @commands;
        map { $dbh->do($_) } @commands;
        close(INPUT);
        $template->param(
            "error" => $dbh->errstr,
            "$op"   => 1,
        );
        $dbh->disconnect;
    }
    elsif ($op eq 'updatestructure' ) {
        #
        # Not 1st install, the only sub-step : update database
        #
        #Do updatedatabase And report
        my $execstring =
          C4::Context->config("intranetdir") . "/updater/updatedatabase";
        undef $/;
        my $string = qx|$execstring 2>&1|;
        if ($string) {
            $string =~ s/\n|\r/<br \/>/g;
            $string =~
                s/(DBD::mysql.*? failed: .*? line [0-9]*.|=================.*?====================)/<font color=red>$1<\/font>/g;
            $template->param( "updatereport" => $string );
        }
        $template->param( $op => 1 );
    }
    else {
        #
        # Check wether it's a 1st install or an update
        #
        # Check if there are enough tables.
        # Paul has cleaned up tables so reduced the count
        #I put it there because it implied a data import if condition was not satisfied.
        my $dbh = DBI->connect(
            "DBI:$info{dbms}:$info{dbname}:$info{hostname}"
              . ( $info{port} ? ":$info{port}" : "" ),
            $info{'user'}, $info{'password'}
        );
        my $rq = $dbh->prepare( "SHOW TABLES FROM " . $info{'dbname'} );
        $rq->execute;
        my $data = $rq->fetchall_arrayref( {} );
        my $count = scalar(@$data);
        #
        # we don't have tables, propose DB import
        #
        if ( $count < 70 ) {
            $template->param( "count" => $count, "proposeimport" => 1 );
        } else {
            # we have tables, propose to select files to upload or updatedatabase
            #
            $template->param( "count" => $count, "default" => 1 );
            #
            # 1st part of step 3 : check if there is a databaseversion systempreference
            # if there is, then we just need to upgrade
            # if there is none, then we need to install the database
            #
            if (my $dbversion = C4::Context->preference('Version')) {
            	$dbversion =~ s/(.*)\.(..)(..)(...)/$1.$2.$3.$4/;
                $template->param( "upgrading" => 1,
                                  "dbversion" => $dbversion,
                                "kohaversion" => C4::Context->KOHAVERSION,
                                );
            }
        }
        $dbh->disconnect;
    }
}

sub step_else {
    # LANGUAGE SELECTION page by default
    # using opendir + language Hash
    my $langavail = getTranslatedLanguages();
    my @languages;
    foreach (@$langavail) {
        push @languages,
          {
            'value'       => $_->{'language_code'},
            'description' => $_->{'language_name'}
          }
          if ( $_->{'language_code'} );
    }
    $template->param( languages => \@languages );
    if ($dbh) {
        my $rq =
          $dbh->prepare("SELECT * from systempreferences WHERE variable='Version'");
        if ( $rq->execute && $rq->fetchrow) {
			$query->redirect("install.pl?step=3");
        }
    }
}



