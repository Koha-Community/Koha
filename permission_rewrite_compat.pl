#!/usr/bin/perl
use Modern::Perl;

use Getopt::Long;

use Text::CSV;
my $csv = Text::CSV->new({binary => 1, allow_whitespace => 1, always_quote => 1, quote_char => "'", escape_char         => "'",});

my @moduleBitToModuleName;

my ($help, $verbose, $revert, $dryrun);

GetOptions(
  'h|help'       => \$help,
  'r|revert'     => \$revert,
  'v|verbose'    => \$verbose,
  'd|dry-run'    => \$dryrun,
);

if ($help) {
  print <<HELP;

For feature Bug 14540 - PermissionManager,

Refactors userflags.sql and userpermissions.sql
to the new Koha::Auth::PermissionManager -model
so you don't have to...

Makes backups with .orig-extension

 -r --revert   Revert backups
 -d --dry-run  Make changes to files but don't push to DB
 -h --help     This dandy help

HELP
exit;
}

my $quiet = ($verbose) ? '' : ' -q ';

my $userflags_file = `find -name userflags.sql -not -path "*/blib/*"`;
chomp $userflags_file;
my $userperms_file = `find -name userpermissions.sql -not -path "*/blib/*"`;
chomp $userperms_file;
die "File $userflags_file is not writable" unless (-w $userflags_file);
die "File $userperms_file is not writable" unless (-w $userperms_file);


## First process userflags.
sub userflags {
  print `wget $quiet https://raw.githubusercontent.com/Koha-Community/Koha/master/installer/data/mysql/userflags.sql       -O $userflags_file` or die "Couldn't get userflags.sql from github";
  open(my $FH, '<', $userflags_file) or die $!;

  my $userflags_sql_header = 'INSERT IGNORE INTO permission_modules (module, description) VALUES';
  my @userflags_sql;
  while (<$FH>) {
    if ($_ =~ /^INSERT INTO/) { #replace the first INSERT INTO row with the new header instead
      print sprintf("%4d: %10s '%s'", $., 'Skipping', $_) if $verbose;
      next;
    }
    elsif ($_ =~ /^\s*\((.+?)\),?$/) {
      print sprintf("%4d: %10s '%s'", $., 'Parsing', $_) if $verbose;
      #example row       (0,'superlibrarian','Access to all librarian functions',0),
      #we want this      ('superlibrarian','Access to all librarian functions'),
      my $status = $csv->parse( $1 );
      my @columns = $csv->fields();
      unless (@columns) {
        die "Line $.: ".$csv->error_diag();
      }
      if (@columns == 2) {
        die "Line $.: Only 2 columns found from $userflags_file, row:\n$_\nLooks like this file is already transformed?";
      }
      $status = $csv->combine($columns[1],$columns[2]);
      my $line   = $csv->string();
      unless ($line) {
        die "Line $.: ".$csv->error_diag();
      }
      push(@userflags_sql, "($line)");
      $moduleBitToModuleName[$columns[0]] = $columns[1]; #Translation table for permissions
    }
    elsif ($_ =~ /^;/) {
      print sprintf("%4d: %10s '%s'", $., 'Closing', $_) if $verbose;
      last;
    }
    else {
      die "Line $.: Unknown row\n$_";
    }
  }
  close($FH);

  my $userflags_sql = $userflags_sql_header."\n".join(",\n", @userflags_sql)."\n"."; SHOW WARNINGS;";

  print `mv $userflags_file $userflags_file.orig`;

  open($FH, '>', $userflags_file);
  print $FH $userflags_sql;
  close($FH);

  unless ($dryrun) {
    print sprintf("%4d: %10s '%s'\n", $., 'Importing', $userflags_file) if $verbose;
    `mysql < $userflags_file` or die "Pushing userflags to DB failed";
  }
}

## Then process userpermissions.sql
sub userpermissions {
  print `wget $quiet https://raw.githubusercontent.com/Koha-Community/Koha/master/installer/data/mysql/userpermissions.sql -O $userperms_file` or die "Couldn't get userpermissions.sql from github";
  open(my $FH, '<', $userperms_file) or die $!;

  my $userpermissions_sql_header = 'INSERT IGNORE INTO permissions (module, code, description) VALUES';
  my @userpermissions_sql;
  while (<$FH>) {
    if ($_ =~ /^INSERT INTO/) { #replace the first INSERT INTO row with the new header instead
      print sprintf("%4d: %10s '%s'", $., 'Skipping', $_) if $verbose;
      next;
    }
    elsif ($_ =~ /^\s*\((.+?)\),?$/) {
      print sprintf("%4d: %10s '%s'", $., 'Parsing', $_) if $verbose;
      #example row       ( 1, 'circulate_remaining_permissions', 'Remaining circulation permissions'),
      #we want this      ( 'circulate', 'circulate_remaining_permissions', 'Remaining circulation permissions'),
      my $status = $csv->parse( $1 );
      my @columns = $csv->fields();
      unless (@columns) {
        die "Line $.: ".$csv->error_diag();
      }
      if ($columns[0] !~ /^\d+$/) {
        die "Line $.: First column is not a digit in $userperms_file, row:\n$_\nLooks like this file is already transformed?";
      }
      unless ($columns[0]) {
        die "Line $.: \$columns[0] is undef at line '$_'";
      }
      my $moduleName = $moduleBitToModuleName[$columns[0]];
      $status = $csv->combine($moduleName,$columns[1],$columns[2]);
      my $line   = $csv->string();
      unless ($line) {
        die "Line $.: ".$csv->error_diag();
      }
      push(@userpermissions_sql, "($line)");
    }
    elsif ($_ =~ /^;/) {
      print sprintf("%4d: %10s '%s'", $., 'Closing', $_) if $verbose;
      last;
    }
    else {
      die "Line $.: Unknown row\n$_";
    }
  }
  close($FH);

  my $userpermissions_sql = $userpermissions_sql_header."\n".join(",\n", @userpermissions_sql)."\n"."; SHOW WARNINGS;";

  print `mv $userperms_file $userperms_file.orig`;

  open($FH, '>', $userperms_file);
  print $FH $userpermissions_sql;
  close($FH);

  unless ($dryrun) {
    print sprintf("%4d: %10s '%s'\n", $., 'Importing', $userperms_file) if $verbose;
    `mysql < $userflags_file` or die "Pushing userpermissions to DB failed";
  }
}

sub revert {
  print `mv $userperms_file.orig $userperms_file`;
  print `mv $userflags_file.orig $userflags_file`;
}

if ($revert) {
  revert;
}
else {
  userflags;
  userpermissions;
}
