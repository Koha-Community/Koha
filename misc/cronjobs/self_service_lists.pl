use Modern::Perl;
use utf8;
use English;
use Carp::Always;
use Data::Printer;
use File::Basename;
$0 = File::Basename::basename($0);

use Getopt::Long qw(:config no_ignore_case);

my %argv = (
    file => "$ENV{KOHA_PATH}/koha-tmpl/intranet-tmpl/blocklist",
    encrypt => 0,
    type => 'csv',
    columns => [],
);

my $HELP = <<HELP;

NAME
  $0 - Extract all kinds of self-service lists for communicating patron permissions

SYNOPSIS
  perl $0 --file '$argv{file}' \
          --encrypt ./credentials-file --type '$argv{type}' \
          -c borrowers.cardnumber -c borrowers.emailpro

  Results in the creation of a file named $argv{file}.$argv{type}.gpg
  Containing borrowers-table columns 'borrowernumber cardnumber emailpro' + HasSelfServicePermission

DESCRIPTION
  $0 extracts parametrizable "block" lists from Koha to the given destination file. Basically these
  files can contain a lot of different data elements extracted from Koha and this script should
  produce highly customizable block list variations for caching patron self-service statuses for
  3rd parties.

  $0 exports files in various different formats. Automatically prepends the file type.

  $0 can transparently encrypt files for safe transport, using a preseeded secret passphrase.
  Automatically prepends .gpg to show the file is encrypted.

SELF-SERVICE PERMISSION
  $0 calculates the HasSelfServicePermission-column using the system preference 'SSRules'.
  The self-service permissions is typically the last column in the exported files.

ARGUMENTS

  -f --file Filepath without suffix. Defaults to '$argv{file}'.
      Into which file to export the --export:able data elements?
      Suffix is automatically added based on the --content-type and possible --encrypt:ion

  --encrypt Boolean|path-to-file|String-of-credentials. Defaults to '$argv{encrypt}'.
      See the syspref 'SelfServiceListsEncryption' for the file format.
      Encrypt the exportable file using one of the given configuration methods:
      --encrypt 1
        The configuration from the syspref 'SelfServiceListsEncryption' is used.
        This is the recommended option, so the passphrase can be easily changed.
      --encrypt path/to/file
        The configuration is read from the given file path. This is the safest option.
      --encrypt 'passphrase\nalgorithm'
        The configuration is passed as commandline parameters.

  -t --type String. Defaults to '$argv{type}'.
      The exportable content-type, one of:

          csv: The selected columns are expported in the order they are given,
               prepended by the borrowernumber and appended by the HasSelfServicePermission

          mv-xml: Specific export type for Mikro-Väylä.
                  Exports only the borrowernumber and the HasSelfServicePermission.

          yml: Due to the internal mechanics of Perl, the selected columns are exported in
               pseudo-random order as YAML object attributes

  -c --column Repeatable borrowers-table column
      borrowers-table columns to include, in the given order.
      The first column is always the borrowernumber and the last column is the self service permission

  -l --limit Integer
      Used for testing. Limit the amount of borrowers to fetch for inspection.
      Defaults to fetching all borrowers from the DB.

HELP

GetOptions(
    'f|file:s'                   => \$argv{file},
    't|type:s'                   => \$argv{type},
    'encrypt'                    => \$argv{encrypt},
    'c|column:s@'                => \$argv{columns},
    'l|limit:i'                  => \$argv{limit},
    'v|verbosity+'               => \$argv{verbosity},
    'h|help'                     => sub { print $HELP; exit 0; },
) or die("Error in command line arguments\n$!");

use C4::Context;
#C4::Context->setCommandlineEnvironment();
C4::Context->interface('commandline');
use Koha::Logger;
Koha::Logger->setConsoleVerbosity($argv{verbosity});

use C4::SelfServiceLists;
C4::SelfServiceLists::run(\%argv);
