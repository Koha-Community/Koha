#!/usr/bin/perl

# Copyright 2015 Vaara-kirjastot
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Carp;

use Getopt::Long qw(:config no_ignore_case);

use Koha::Overdues::Controller;
use Koha::Overdues::Builder;
use Koha::Overdues::Calendar; #TODO: HACK TO ENABLE CALENDAR DAYS

my $help;
my $verbose = 0;
my @letterNumbers;
my @borrowerCategories;
my $mergeNotificationBranches;
my $collect;
my $send;
my $populateRegexp;
my $populateDelete;
my $sortByColumn;
my $sortByColumnAlt;
my $lookback;
my $notNotForLoan;
my $pageChangeItems;
my $pageChangeSeparator;

GetOptions(
    'h|help'                      => \$help,
    'v|verbose:i'                 => \$verbose,
    'l|letternumbers=s{,}'        => \@letterNumbers,
    'b|borrowercategories=s{,}'   => \@borrowerCategories,
    'm|mergenotificationbranches' => \$mergeNotificationBranches,
    'c|collect'                   => \$collect,
    's|send'                      => \$send,
    'p|populate:s'                => \$populateRegexp,
    'd|populateDelete'            => \$populateDelete,
    'sortby:s'                    => \$sortByColumn,
    'sortbyalt:s'                 => \$sortByColumnAlt,
    'lookback:s'                  => \$lookback,
    'notnotforloan:s'             => \$notNotForLoan,
    'pagechangeitems:i'           => \$pageChangeItems,
    'pagechangeseparator:s'       => \$pageChangeSeparator,
);

my $usage = <<USAGE;


  --verbose               Defaults to 0, minimal output.
                          1, some results
                          2, detailed results
                          3, SQL dumps

  --lookback              How many days in the past to look for overdue Issues? Defaults to
                          the biggest delay in koha.overduerules.delay* + 30 days.
                          This is a limit to prevent re-enqueuing very old overdue notifications
                          which have already been sent, but subsequently deleted by the
                          cleanup_database.pl -script.

  --notnotforloan         Exclude overdue Issues which have this items.notforloan id.
                          Eg. For Vaara-kirjastot
                              --notnotforloan 6
                          would exclude all Issues for Items that have been claimed.
                          This is handy if you don't want to use the --lookback parameter to prevent
                          re-enqueuing very late Issues.
                          Also useful if you have lost your message_queue-rows and only know the
                          Items claimed status.

  --sortby                Based on which borrowers database column to sort the overdue notifications.
                          Defaults to
                              --sortby borrowernumber
                          This causes all notifications to be gathered under the borrower owning the
                          issue and notification. Alternatively you could sort them based on the
                              --sortby guarantorid
                          which would cause all borrowers who have a guarantor to collect their
                          notifications under the guarantor, not the perpetrator.
                          You must define
                              --sortbyalt borrowernumber
                          to fall back to if using the sortby-parameter.

  --sortbyalt             Alternative sorting borrowers-column, if sortby is not defined.
                          Should be borrowernumber if --sortby is used. Otherwise erratic behaviour
                          will happen when the Overdues Finder cannot sort the overdue notification.

  --mergenotificationbranches
                          Should the overdue notifications be enqueued by their borrowers homebranches,
                          or merge notifications from material all over branches.
                          Defaults to merge, override with
                              --mergenotificationbranches 0

  --pagechangeitems       After how many Items do we insert some text.
                          Defaults to 0 which means disabled.

  --pagechangeseparator   What text to append when --pagechangeitems triggers?
                          Can be any text, but is meant to cause a page break in the notification message.
                          Defaults to "\n", which is kinda lame :(

EXAMPLES:

  Before using this module, make sure that the overduerules have been properly configured.
  You have defined the letters you want to use and the fines for overduenotifications.
  Make sure that each overdue notification number (1st, 2nd, 3rd) has a distinct letterCode!
  Eg. ODUE1, ODUE2, ODUECLAIM (for the third letter). This is used to distinguish the letternumbers.

  If you are using PrintProviderEnfo, make sure that the following configuration is found in the \$KOHA_CONF
 <printProviders>
  <enfo>
   <!-- <dontReallySendAnything>comment this to actually send the letters, now we are just fakin'</dontReallySendAnything> -->
   <letterStagingDirectory>/tmp/enfo/</letterStagingDirectory>
   <clientId>JNS190</clientId>
   <remoteDirectory>testedtester</remoteDirectory>
   <host>ENFO IP</host>
   <user>USERNAME</user>
   <passwd>PASSWORD</passwd>
  </enfo>
 </printProviders>

  Also it is important to preserve the message_queue-entries as long as it takes to perform the complete
  overdue notification + claiming cycle, so we don't start sending first overdue notification again.
  Eg. if overdue notifications are sent for Issues overdue 21-, 42- and 70-days, where 70-days is the last notification.
      Then the cleanup_database.pl -script's --mail parameter needs to be over 70. 120 is a safe bet,
          giving you 50 days to fix any emerging issues before messaging gets out of sync.
      At Vaara-kirjastot, the message_queue-table is < 100MB when the cleaning delay is 120 days.


  ./overduemessages.pl --populate '^Barcode:\\s*(.*?)\$'

  Run this to generate message_queue_items -rows from existing message_queues.
  ./overduemessages.pl --populate '^ 1Nide:\\s*(.*?)\$'
  Having confirmed that everything was migrated as it should be,
  use this to delete empty and pending overdue notifications.
  ./overduemessages.pl --populate '^ 1Nide:\\s*(.*?)\$' --populateDelete

  To migrate from a system state where overdue notifications haven't been sent in 5+ months,
  you can use these commands:
  ./overduemessages.pl --collect --letternumbers 1 2 --mergenotificationbranches 1 --verbose 1
                       --lookback 180 --notnotforloan 6
                       --pagechangeitems 8 --pagechangeseparator "10\\n31"


  To operate this script daily at Vaara-kirjastot,
  First gather the overdue notifications and merge them to a default branch.
  ./overduemessages.pl --collect --letternumbers 1 2 --mergenotificationbranches
                       --pagechangeitems 8 --pagechangeseparator "10\\n31" --lookback 120
  Then gather all claim notifications to their respective branches.
  ./overduemessages.pl --collect --letternumbers 3
                       --pagechangeitems 8 --pagechangeseparator "10\\n31" --lookback 120
  Secondly send only letter numbers 1 and 2.
  Letternumber 3 is the Claim letter and that is done manually using the Claiming module.
  ./overduemessages.pl --send --letternumbers 1 2

USAGE

if ($help) {
    print $usage;
    exit 0;
}
unless ($collect || $send || $populateRegexp) {
    print $usage.
          "You must define atleast --collect or --send, better even both :)\n";
    exit 0;
}

my %repeatPageChange;
if ($pageChangeItems xor $pageChangeSeparator) { #Both of these must be defined or none.
    print $usage.
          "You must define both --pagechangeitems and --pagechangeseparator or neither.\n";
    exit 0;
}
elsif($pageChangeItems && $pageChangeSeparator) {
    $repeatPageChange{items} = $pageChangeItems;
    $repeatPageChange{separator} = $pageChangeSeparator;
}

 #TODO: HACK TO ENABLE CALENDAR DAYS
my $calendar = Koha::Overdues::Calendar->new();
$calendar->upsertWeekdays('','1,2,3,4,5,6,7');
C4::Context->set_preference('PrintProviderImplementation', 'PrintProviderEnfo');

my $controller = Koha::Overdues::Controller->new({verbose => $verbose,
                                                  sortBy => $sortByColumn,
                                                  sortByAlt => $sortByColumnAlt,
                                                  lookback => $lookback,
                                                  notNotForLoan => $notNotForLoan,
                                                  mergeBranches => $mergeNotificationBranches,
                                                  _repeatPageChange => ((scalar(%repeatPageChange)) ? \%repeatPageChange : undef),
                                                });
my ($overdueLetters, $errors) = $controller->gatherOverdueNotifications( (@letterNumbers)      ? \@letterNumbers      : undef,
                                                        (@borrowerCategories) ? \@borrowerCategories : undef,
                                                      ) if ($collect);
carp join("\n","!!ERRORS FOUND while gathering overdue notifications!!",@$errors) if($errors && ref($errors) eq 'ARRAY');

my $sentOverdueLetters = $controller->sendOverdueNotifications(
                                                        (@letterNumbers)      ? \@letterNumbers      : undef,
                                                      ) if ($send);

if ($populateRegexp) {
    my $builder = Koha::Overdues::Builder->new({verbose => $verbose});
    $builder->populateMessageQueueItemsFromMessageQueues( $populateRegexp, $populateDelete );

    print join("\n",
        "",
        "WARNING-WARNING-WARNING-WARNING-WARNING-WARNING-WARNING",
        "You must check that message_queue_items have been succesfully populated.",
        "You can do that from the DB, by running this:",
        "    SELECT mq.letter_code FROM message_queue_items mqi LEFT JOIN message_queue mq ON mq.message_id = mqi.message_id;",
        "You should get some results.",
        "",
        "If you are happy with the migration and conclude that the item parsing regexp worked,",
        "you should clean the database by deleting message_queue-rows for overdues with no",
        "pending issues. You can do that with this script as well using --populateDelete",
        "",
        );
}
