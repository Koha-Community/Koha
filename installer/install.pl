#!/usr/bin/perl -w # please develop with -w

#use diagnostics;

# use Install;
use InstallAuth;
use C4::Context;
use C4::Output;
use C4::Languages;

use strict;    # please develop with the strict pragma

use CGI;

my $query = new CGI;
my $step  = $query->param('step');

my $language = $query->param('language');
my ( $template, $loggedinuser, $cookie );

my $all_languages = getAllLanguages();

if ( defined($language) ) {
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
$info{'dbms'} =
  (   C4::Context->config("db_scheme")
    ? C4::Context->config("db_scheme")
    : "mysql" );
$info{'hostname'} = C4::Context->config("hostname");
$info{'port'} = C4::Context->config("port");
$info{'user'}     = C4::Context->config("user");
$info{'password'} = C4::Context->config("pass");
my $dbh = DBI->connect(
    "DBI:$info{dbms}:dbname=$info{dbname};host=$info{hostname}"
      . ( $info{port} ? ";port=$info{port}" : "" ),
    $info{'user'}, $info{'password'}
);

if ( $step && $step == 1 ) {
    #First Step
    #Checking ALL perl Modules and services needed are installed.
    #Whenever there is an error, adding a report to the page
    $template->param( language => 1 );
    my $problem;

    unless ( $] >= 5.006001 ) {    # Bug 179
        $template->param( "problems" => 1, "perlversion" => 1 );
        $problem = 1;
    }

    # We could here use a special find
    my @missing = ();
    unless ( eval { require ZOOM } ) {
        push @missing, { name => "ZOOM" };
    }
    unless ( eval { require LWP::Simple } ) {
        push @missing, { name => "LWP::Simple" };
    }
    unless ( eval { require XML::Simple } ) {
        push @missing, { name => "XML::Simple" };
    }
    unless ( eval { require MARC::File::XML } ) {
        push @missing, { name => "MARC::File::XML" };
    }
    unless ( eval { require MARC::File::USMARC } ) {
        push @missing, { name => "MARC::File::USMARC" };
    }
    unless ( eval { require DBI } ) {
        push @missing, { name => "DBI" };
    }
    unless ( eval { require Date::Manip } ) {
        push @missing, { name => "Date::Manip" };
    }
    unless ( eval { require DBD::mysql } ) {
        push @missing, { name => "DBD::mysql" };
    }
    unless ( eval { require HTML::Template::Pro } ) {
        push @missing, { name => "HTML::Template::Pro" };
    }
    unless ( eval { require Date::Calc } ) {
        push @missing, { name => "Date::Calc" };
    }
    unless ( eval { require Digest::MD5 } ) {
        push @missing, { name => "Digest::MD5" };
    }
    unless ( eval { require MARC::Record } ) {
        push @missing, { name => "MARC::Record" };
    }
    unless ( eval { require Mail::Sendmail } ) {
        push @missing, { name => "Mail::Sendmail", usagemail => 1 };
    }
    unless ( eval { require List::MoreUtils } ) {
        push @missing, { name => "List::MoreUtils" };
    }
    unless ( eval { require XML::RSS } ) {
        push @missing, { name => "XML::RSS" };
    }
    unless ( eval { require CGI::Carp } ) {
        push @missing, { name => "CGI::Carp" };
    }


# The following modules are not mandatory, depends on how the library want to use Koha
    unless ( eval { require PDF::API2 } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing, { name => "PDF::API2", usagebarcode => 1 };
        }
    }
    unless ( eval { require GD::Barcorde } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing,
              { name => "GD::Barcode", usagebarcode => 1, usagespine => 1 };
        }
    }
    unless ( eval { require Data::Random } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing, { name => "Data::Random", usagebarcode => 1 };
        }
    }
    unless ( eval { require PDF::Reuse::Barcode } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing, { name => "PDF::Reuse::Barcode", usagebarcode => 1 };
        }
    }
    unless ( eval { require PDF::Report } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing, { name => "PDF::Report", usagebarcode => 1 };
        }
    }
    unless ( eval { require Net::LDAP } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing, { name => "Algorithm::CheckDigits", usagebarcode => 1 };
        }
    }
    unless ( eval { require GD::Barcode::UPCE } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing, { name => "GD::Barcode::UPCE", usagepine => 1 };
        }
    }
    unless ( eval { require Net::LDAP } ) {
        if ( $#missing >= 0 ) {   # only when $#missing >= 0 so this isn't fatal
            push @missing, { name => "Net::LDAP", usageLDAP => 1 };
        }
    }
    $template->param( missings => \@missing ) if ( scalar(@missing) > 0 );
    $template->param( 'checkmodule' => 1 )
      unless ( scalar(@missing) && $problem );

}
elsif ( $step && $step == 2 ) {
#
#STEP 2 Check Database connection and access
#
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
                    if ( $line =~ m/$dbname/ || index( $line, '*.*' ) > 0 ) {
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
            }	# End mysql connect check...
	    
	    elsif ( $info{dbms} eq "Pg" ) {
		# Check if database has been created...
		my $rv = $dbh->do( "SELECT * FROM pg_catalog.pg_database WHERE datname = \'$info{dbname}\';" );
		if ( $rv == 1 )	{
			$template->param( 'checkdatabasecreated' => 1 );
		}

		# Check if user has all necessary grants on this database...
		my $rq = $dbh->do( "SELECT u.usesuper
				    FROM pg_catalog.pg_user as u
				    WHERE u.usename = \'$info{user}\';" );
		if ( $rq == 1 ) {
			$template->param( "checkgrantaccess" => 1 );
		}
            }	# End Pg connect check...
        }
        else {
            $template->param( "error" => DBI::err, "message" => DBI::errstr );
        }
    }
}
elsif ( $step && $step == 3 ) {
#
#
# STEP 3 : database setup
#
# 
    my $op = $query->param('op');
    if ( $op && $op eq 'finished' ) {
        #
        # we have finished, just redirect to mainpage.
        #
        print $query->redirect("/cgi-bin/koha/mainpage.pl");
        exit 1;
    }
    elsif ( $op && $op eq 'finish' ) {
        my $kohaversion=C4::Context::KOHAVERSION;
        # remove the 3 last . to have a Perl number
        $kohaversion =~ s/(.*\..*)\.(.*)\.(.*)/$1$2$3/;
        if (C4::Context->preference('Version')) {
            warn "UPDATE Version";
            my $finish=$dbh->prepare("UPDATE systempreferences SET value=? WHERE variable='Version'");
            $finish->execute($kohaversion);
        } else {
            warn "INSERT Version";
            my $finish=$dbh->prepare("INSERT into systempreferences (variable,value,explanation) values ('Version',?,'The Koha database version. Don t change this value manually, it s holded by the webinstaller')");
            $finish->execute($kohaversion);
        }

        # Installation is finished.
        # We just deny anybody access to install
        # And we redirect people to mainpage.
        # The installer will have to relogin since we do not pass cookie to redirection.
        $template->param( "$op" => 1 );
    }
    elsif ( $op && $op eq 'Nozebra' ) {
        if ($query->param('Nozebra')) {
            $dbh->do("UPDATE systempreferences SET value=1 WHERE variable='NoZebra'");
        } else {
            $dbh->do("UPDATE systempreferences SET value=0 WHERE variable='NoZebra'");
        }
        $template->param( "$op" => 1 );
    }
    elsif ( $op && $op eq 'addframeworks' ) {
    #
    # 1ST install, 3rd sub-step : insert the SQL files the user has selected
    #

        #Framework importing and reports
        my $lang;
        my %hashlevel;

       # sort by filename -> prepend with numbers to specify order of insertion.
        my @fnames = sort {
            my @aa = split /\/|\\/, ($a);
            my @bb = split /\/|\\/, ($b);
            $aa[-1] cmp $bb[-1]
        } $query->param('framework');
	if ( $info{dbms} eq 'mysql' ) { $dbh->do('SET FOREIGN_KEY_CHECKS=0'); }
	elsif ( $info{dbms} eq 'Pg' ) { $dbh->do('SET CONSTRAINTS ALL DEFERRED;'); }
        my $request =
          $dbh->prepare(
            "SELECT value FROM systempreferences WHERE variable='FrameworksLoaded'"
          );
        $request->execute;
        my ($systempreference) = $request->fetchrow;
        foreach my $file (@fnames) {

            #      warn $file;
            undef $/;
	    my $error;
	    if ( $info{dbms} eq 'mysql' ) {
            	my $strcmd = "mysql "
              		. ( $info{hostname} ? " -h $info{hostname} " : "" )
              		. ( $info{port}     ? " -P $info{port} "     : "" )
              		. ( $info{user}     ? " -u $info{user} "     : "" )
              		. ( $info{password} ? " -p$info{password}"   : "" )
              		. " $info{dbname} ";
            	$error = qx($strcmd < $file 2>&1 1>/dev/null);			# We want to send stdout to null and return only stderr... -fbcit
    	    }
	    elsif ( $info{dbms} eq 'Pg' ) { 
            	my $strcmd = "psql "
              		. ( $info{hostname} ? " -h $info{hostname} " : "" )
              		. ( $info{port}     ? " -p $info{port} "     : "" )
              		. ( $info{user}     ? " -U $info{user} "     : "" )
#              		 . ( $info{password} ? " -W $info{password}"   : "" )
              		. " $info{dbname} ";
            	$error = qx($strcmd -f $file 2>&1 1>/dev/null);			# ...even more so with psql...
    	    }
            my @file = split qr(\/|\\), $file;
            $lang = $file[ scalar(@file) - 3 ] unless ($lang);
            my $level = $file[ scalar(@file) - 2 ];
            unless ($error) {
                $systempreference .= "$file[scalar(@file)-1]|"
                  unless (
                    index( $systempreference, $file[ scalar(@file) - 1 ] ) >=
                    0 );
            }

            #Bulding here a hierarchy to display files by level.
            push @{ $hashlevel{$level} },
              { "fwkname" => $file[ scalar(@file) - 1 ], "error" => $error };
        }

        #systempreference contains an ending |
        chop $systempreference;
        my @list;
        map { push @list, { "level" => $_, "fwklist" => $hashlevel{$_} } }
          keys %hashlevel;
        my $fwk_language;
        for my $each_language (@$all_languages) {

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
	if ( $info{dbms} eq 'mysql' ) { $dbh->do('SET FOREIGN_KEY_CHECKS=1'); }
	elsif ( $info{dbms} eq 'Pg' ) { $dbh->do('SET CONSTRAINTS ALL IMMEDIATE;'); }
    }
    elsif ( $op && $op eq 'selectframeworks' ) {
        #
        #
        # 1ST install, 2nd sub-step : show the user the sql datas he can insert in the database.
        #
        #
        # (note that the term "selectframeworks is not correct. The user can select various files, not only frameworks)
        
        #Framework Selection
        #sql data for import are supposed to be located in installer/data/<language>/<level>
        # Where <language> is en|fr or any international abbreviation (provided language hash is updated... This will be a problem with internationlisation.)
        # Where <level> is a category of requirement : required, recommended optional
        # level should contain :
        #   SQL File for import With a readable name.
        #   txt File taht explains what this SQL File is meant for.
        # Could be VERY useful to have A Big file for a kind of library.
        # But could also be useful to have some Authorised values data set prepared here.
        # Framework Selection is achieved through checking boxes.
        my $langchoice = $query->param('fwklanguage');
        $langchoice = $query->cookie('KohaOpacLanguage') unless ($langchoice);
        my $marcflavour = $query->param('marcflavour');
        if ($marcflavour){    
          my $request =
            $dbh->prepare(
              "INSERT IGNORE INTO `systempreferences` (variable,value,explanation,options,type) VALUES('marcflavour','$marcflavour','Define global MARC flavor (MARC21 or UNIMARC) used for character encoding','MARC21|UNIMARC','Choice');"
            );     
          $request->execute;
        };    
        $marcflavour = C4::Context->preference('marcflavour') unless ($marcflavour);
        #Insert into database the selected marcflavour
    
        undef $/;
        my $dir =
          C4::Context->config('intranetdir') . "/installer/data/$info{dbms}/$langchoice/marcflavour/".lc($marcflavour);
        opendir( MYDIR, $dir ) || warn "no open $dir";
        my @listdir = sort grep { !/^\.|marcflavour/ && -d "$dir/$_" } readdir(MYDIR);
        closedir MYDIR;
                  
        my @fwklist;
        my $request =
          $dbh->prepare(
            "SELECT value FROM systempreferences WHERE variable='FrameworksLoaded'"
          );
        $request->execute;
        my ($frameworksloaded) = $request->fetchrow;
        my %frameworksloaded;
        foreach ( split( /\|/, $frameworksloaded ) ) {
            $frameworksloaded{$_} = 1;
        }
        
        foreach my $requirelevel (@listdir) {
            opendir( MYDIR, "$dir/$requirelevel" );
            my @listname =
              grep { !/^\./ && -f "$dir/$requirelevel/$_" && $_ =~ m/\.sql$/ }
              readdir(MYDIR);
            closedir MYDIR;
            my %cell;
            my @frameworklist;
            map {
                my $name = substr( $_, 0, -4 );
                open FILE, "< $dir/$requirelevel/$name.txt";
                my $lines = <FILE>;
                $lines =~ s/\n|\r/<br \/>/g;
                use utf8;
                utf8::encode($lines) unless ( utf8::is_utf8($lines) );
                push @frameworklist,
                  {
                    'fwkname'        => $name,
                    'fwkfile'        => "$dir/$requirelevel/$_",
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

#             $cell{"mandatory"}=($requirelevel=~/(mandatory|requi|oblig|necess)/i);
            $cell{"frameworks"} = \@fwks;
            $cell{"label"}      = ucfirst($requirelevel);
            $cell{"code"}       = lc($requirelevel);
            push @fwklist, \%cell;
        }
        $template->param( "frameworksloop" => \@fwklist );
        $template->param( "marcflavour" => ucfirst($marcflavour));
        
        $dir =
          C4::Context->config('intranetdir') . "/installer/data/$info{dbms}/$langchoice";
        opendir( MYDIR, $dir ) || warn "no open $dir";
        @listdir = sort grep { !/^\.|marcflavour/ && -d "$dir/$_" } readdir(MYDIR);
        closedir MYDIR;
        my @levellist;
        foreach my $requirelevel (@listdir) {
            opendir( MYDIR, "$dir/$requirelevel" );
            my @listname =
              grep { !/^\./ && -f "$dir/$requirelevel/$_" && $_ =~ m/\.sql$/ }
              readdir(MYDIR);
            closedir MYDIR;
            my %cell;
            my @frameworklist;
            map {
                my $name = substr( $_, 0, -4 );
                open FILE, "< $dir/$requirelevel/$name.txt";
                my $lines = <FILE>;
                $lines =~ s/\n|\r/<br \/>/g;
                use utf8;
                utf8::encode($lines) unless ( utf8::is_utf8($lines) );
                push @frameworklist,
                  {
                    'fwkname'        => $name,
                    'fwkfile'        => "$dir/$requirelevel/$_",
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

#             $cell{"mandatory"}=($requirelevel=~/(mandatory|requi|oblig|necess)/i);
            $cell{"frameworks"} = \@fwks;
            $cell{"label"}      = ucfirst($requirelevel);
            $cell{"code"}       = lc($requirelevel);
            push @levellist, \%cell;
        }
        $template->param( "levelloop" => \@levellist );
        $template->param( "$op"       => 1 );
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
        my $dir =
          C4::Context->config('intranetdir') . "/installer/data/$info{dbms}/$langchoice/marcflavour";
        opendir( MYDIR, $dir ) || warn "no open $dir";
        my @listdir = grep { !/^\./ && -d "$dir/$_" } readdir(MYDIR);
        closedir MYDIR;
        my $marcflavour=C4::Context->preference("marcflavour");    
        my @flavourlist;
        foreach my $marc (@listdir) {
            my %cell=(    
            "label"=> ucfirst($marc),
            "code"=>uc($marc),
            "checked"=>uc($marc) eq $marcflavour);      
#             $cell{"description"}= do { local $/ = undef; open INPUT "<$dir/$marc.txt"||"";<INPUT> };
            push @flavourlist, \%cell;
        }
        $template->param( "flavourloop" => \@flavourlist );
        $template->param( "$op"       => 1 );
    }
    elsif ( $op && $op eq 'importdatastructure' ) {
        #
        #
        # 1st install, 1st "sub-step" : import kohastructure
        #
        #
	my $datadir = C4::Context->config('intranetdir') . "/installer/data/$info{dbms}";
	my $error;
        if ( $info{dbms} eq 'mysql' ) {
	    my $strcmd = "mysql "
	        . ( $info{hostname} ? " -h $info{hostname} " : "" )
	        . ( $info{port}     ? " -P $info{port} "     : "" )
	        . ( $info{user}     ? " -u $info{user} "     : "" )
	        . ( $info{password} ? " -p$info{password}"   : "" )
	        . " $info{dbname} ";
	    $error = qx($strcmd <$datadir/kohastructure.sql 2>&1 1>/dev/null);
        }
        elsif ( $info{dbms} eq 'Pg' ) { 
            my $strcmd = "psql "
                . ( $info{hostname} ? " -h $info{hostname} " : "" )
                . ( $info{port}     ? " -p $info{port} "     : "" )
                . ( $info{user}     ? " -U $info{user} "     : "" )
#                . ( $info{password} ? " -W $info{password}"   : "" )		# psql will NOT accept a password, but prompts...
                . " $info{dbname} ";						# Therefore, be sure to run 'trust' on localhost in pg_hba.conf -fbcit
            $error = qx($strcmd -f $datadir/kohastructure.sql 2>&1 1>/dev/null);# Be sure to set 'client_min_messages = error' in postgresql.conf
	    									# so that only true errors are returned to stderr or else the installer will
										# report the import a failure although it really succeded -fbcit
    	}
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
        my $execstring =
          C4::Context->config("intranetdir") . "/installer/data/$info{dbms}/updatedatabase.pl";
        undef $/;
        my $string = qx($execstring 2>&1 1>/dev/null);				# added '1>/dev/null' to return only stderr in $string. Needs testing here. -fbcit
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
        # check wether it's a 1st install or an update
        #
        #Check if there are enough tables.
        # Paul has cleaned up tables so reduced the count
        #I put it there because it implied a data import if condition was not satisfied.
        my $dbh = DBI->connect(
    		"DBI:$info{dbms}:dbname=$info{dbname};host=$info{hostname}"
      		. ( $info{port} ? ";port=$info{port}" : "" ),
            	$info{'user'}, $info{'password'}
        );
	my $rq;
        if ( $info{dbms} eq 'mysql' ) { $rq = $dbh->prepare( "SHOW TABLES FROM " . $info{'dbname'} ); }
	elsif ( $info{dbms} eq 'Pg' ) { $rq = $dbh->prepare( "SELECT *
								FROM information_schema.tables
								WHERE table_schema='public' and table_type='BASE TABLE';" ); }
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
            if (C4::Context->preference('Version')) {
                my $dbversion = C4::Context->preference('Version');
                $dbversion =~ /(.*)\.(..)(..)(...)/;
                $dbversion = "$1.$2.$3.$4";
                $template->param("upgrading" => 1,
                                "dbversion" => $dbversion,
                                "kohaversion" => C4::Context->KOHAVERSION,
                                );
            }
        }

        $dbh->disconnect;
    }
}
else {

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
          $dbh->prepare(
            "SELECT * from systempreferences WHERE variable='Version'");
        if ( $rq->execute ) {
            my ($version) = $rq->fetchrow;
            if ($version) {
                $query->redirect("install.pl?step=3");
            }
        }
    }
}
output_html_with_http_headers $query, $cookie, $template->output;
