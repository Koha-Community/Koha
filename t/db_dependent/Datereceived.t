#!/usr/bin/perl

# This file is part of Koha.
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

#                                                    ,
#                                              .,cd$F
#                         .,ced$$$$$$$$$$$$$$$$$$$F,
#                      .c$$$$$$$$$$$$$$$$$$$$$P",z$$$c.
#                     c$$$$$$$$$$$$$$$$""`.,,cd$$$$$$$$b.
#                    d$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$c
#                   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$c
#                  d$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$.
#                  d$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#                  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#                  ?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#                  `$$$$$$$$$$$$$???$$$$$$$$$$$$$$$$$$$$$$$$
#                   ?$$$$$$$$P,zcecec,"$$$$$$",cecec,"?$$$$P
#               z$?$e`$$$$$$$d$",cec,"$$$$$$$"'.,."?$$bd$$$"J$
#               $$$r)$$$$$$$$P.P" P""L^$$$$$"J""?  "`$$$$$P.$$F
#               4$$F?$$$$$$$$ P      4 $$$$$ F       `$$$$ $$$F
#                ?$F4$$$$$$$$ $      .4$$$$$.4      .4$$$$.?$$
#                 ?b.$$$Lucec$cececece$$$???%cececececece$$ $$
#                  `?$$$$$$$$$$$$$$$$$$$$d$$b^$$$$$$$$$$$$$F^"
#                   ed$$$$$$$$$$$$$$$$$$$$$$F.$$$$$$$$$$$$$$
#                   $$$$$$$$$$$"$$$$$$$$.,,,z$P""^3$$$$$$$$$
#                   $$$$$$$$$$P.$$$$$$$$$$P"  .e$$$$$$$$$$$F
#                   ?$$$$$$$P"e$c            d$$$$$$$$$$$$"
#                    `"?$$$$$$$$?$. .eee$$$"e$P'd$$$$$PF"
#                           .,,,,`?$bc,`",c$F.,,,,,. .::.
#                      ..zd$$$$$$$$eu"???7"cd$$$$$F ::::: :.
#             .uedd$$$$$$$$$$$$$$$$$$$$$$$$$$$$$".:::::'.::::'$$$Weu.
#          ue$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$P".::::::' :::::: $$$$$$$$c
#        z$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$P".::::::::'.::::::: 9$$$$$$$$$k
#       $$$$$$$$$$$$$$$$$$$$$$$$$$$P"`.::::::::::'.:::::::: d$$$$$$$$$$$
#      9$$$$$$$$$$$$$$$"d$$$$$P"".::::::::::::::.::::::::'.$$$$$$$$$$$$$>
#      $$$$$$$$$$$$$$P,d$P"".:::::::::::::::::::::::::::'zeC?$$$$$$$$$$$L
#      $$$$$$$$$C?"':d".::::::::::::::::::::::::::::::'.d$$$$ -ee$$$$$$$$L
#      9$$$$$$$$$$$ ":::::::::::::::::::::::::::::::'.$$$$$$E  $$$$$$$$$$$
#     :$$$$$$$$$$$ ::::::::::::::::::::::::::::::'.e$$$$$$$$b  ?$$$$$$$$$$k
#     d$$$$$$$$$$ ::::::::::::::::::::::::::::'.e$$$$$$$$$$$$   $$$$$$$$$$$
#    :$$$$$$$$$$E ::::::::::::::::::::::::'..,,,,,,,,,."???$$,  $$$$$$$$$$$
#    d$",cecec,"':::::::::::::::::::::'`,c>>>>'<<<<<<CCCCCcc>> .zcecec,"$$$
#   J"z$$$$$$$$$b.`:::::::::::::::'`.cCCCCCCCCCCCCCCC>>cCCC>'e$$$$$$$$$$e"$
#   u$$$$$$$$$$$$$$u`::::::::::'.ccCCCCCCCCCCCCCCCC'Ccccc>'d$$$$$$$$$$$$$$r>
#  d$$$$$$$$$$$$$$$$b.`:::::',cc'CCCCCCCCCCCC>(C ccCCC>',d$$$$$$$$$$$$$$$$$b
#  $$$$$$$$$$$$$$$$$$$$c.`'cCCCCCc<CCCCCCC>.cCCcCCCC',z$$$$$$$$$$$$$$$$$$$$$$
#  $$$$$$$$$$$$$$$$$$$$$$$,<CCCCCCc`CCCCCCCCCCCCCC'z$$$$$$$$$$$$$$$$$$$$$$$$$
#  $$$$$$$$$$$$$$$$$$$$$$$$ CCCCCCCCCCCCCCCCCCCCC'$$$$$$$$$$$'$$$$$$$$$$$$$$$
#  $$$$$$$$$$$$$$$$$$$$$$$$ CCCCCCCCCCCCCCCCCCCC'<$$$$$$$$$$$,?$$$$$$$$$$$$$$
#  $$$$$$$$$P?$$$$$$$$$$$$F,CCCCCCCCCCCCCCCCCCCC,<$$$$$$$$$$$$br"??$$$$$$$$$$
#  $$$$PF""  <c"$$$$$$$$F,cCC')cCCCCCCCCC'Cc<CCCC,`$$$$$$$$$$$$"     ""?$$$$$
#  F          `Cc,`"".,ccCCC)cCC'CCCCCCCCccCc`<CCCc`?$$$$$$$$P"           `"?
#              `<CCCCCCCCC"-',ccCCCCCCCCCCCCCCc`<CCCCcc,``,c="
#                 `''''    `"<<CCCCCCCCCCC>>""    `'<CCC>'`

use Modern::Perl;

use C4::Context;
use C4::Biblio;
use C4::Items;

use Test::More tests => 13;

my $dbh = C4::Context->dbh;
my $schema = Koha::Database->new()->schema();

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;


#Get the MARC subfield biblioitems.datereceived is mapped to
my ( $datereceivedFieldCode, $datereceivedSubfieldCode ) =
            C4::Biblio::GetMarcFromKohaField( "biblioitems.datereceived", '' );

# Generate test biblio
my $biblio = MARC::Record->new();
$biblio->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
    MARC::Field->new('245', ' ', ' ', a => 'Proper test case constructors (setUps) and destructors (tearDowns) are golden'),
);
my ($biblionumber, $biblioitemnumber) = C4::Biblio::AddBiblio($biblio, '');


###   Test1 >> that biblio.datereceived is NULL when adding a Biblio         ###
my $bibliodata = C4::Biblio::GetBiblioData($biblionumber);
ok( (not defined $bibliodata->{datereceived}) , 'Searchable datereceived: Adding a Biblio leaves biblio.datereceived as NULL');


### Test2 >> items.datereceived is set when adding an Item                   ###
my $datereceived = DateTime->now( time_zone => C4::Context->tz() );
my $datereceivedIso = $datereceived->ymd().' '.$datereceived->hms(); #Replace the 'T' in ISO standard with a ' '
my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = C4::Items::AddItem(
    {
        homebranch       => 'MPL',
        holdingbranch    => 'MPL',
        barcode          => 'R00000342',
        replacementprice => 12.00,
        datereceived     => $datereceivedIso,
    },
    $biblionumber
);
my $item = C4::Items::GetItem($itemnumber);
ok( ($item->{datereceived} eq $datereceivedIso) , 'Searchable datereceived: Adding an Item set items.datereceived as NOW()');


### Test3 >> items.datereceived can also be later modified                   ###
#There should be scant need for it though, so it might be better to just javascript-hide the datereceived-column when editing Items.
$datereceived = DateTime->now( time_zone => C4::Context->tz() );
$datereceivedIso = $datereceived->ymd().' '.$datereceived->hms(); #Replace the 'T' in ISO standard with a ' '
C4::Items::ModItem(
    {
        datereceived     => $datereceivedIso,
    },
    $biblionumber,
    $itemnumber
);
$item = C4::Items::GetItem($itemnumber);
ok( ($item->{datereceived} eq $datereceivedIso) , "Searchable datereceived: Modding an Item's items.datereceived works");


### Test4 && 5 >> biblio.datereceived can be set                             ###
my $error = C4::Biblio::UpdateDatereceived($biblionumber);
$bibliodata = C4::Biblio::GetBiblioData($biblionumber);
my $record = C4::Biblio::GetMarcBiblio($biblionumber);

#Compare the YMD of datereceiveds, because UpdateDatereceived set the datereceived to NOW() and seconds dont match.
ok( (substr($bibliodata->{datereceived},0,10) eq substr($datereceivedIso,0,10)),
       "Searchable datereceived: Setting the biblio.datereceived.");
#Compare the YMD of datereceiveds, because UpdateDatereceived set the subfield to NOW() and seconds dont match.
ok( (substr($record->subfield($datereceivedFieldCode, $datereceivedSubfieldCode),0,10) eq substr($datereceivedIso,0,10)),
       "Searchable datereceived: Upserting the MARC Subfield datereceived is mapped to.");
$datereceivedIso = $bibliodata->{datereceived}; #Store the new datereceived for the next test.

### Test6 && 7 >> biblio.datereceived can be set only once                   ###
sleep 1; #Make sure the datereceived of the previous test differs atleast by one second.
$error = C4::Biblio::UpdateDatereceived($biblionumber);
$bibliodata = C4::Biblio::GetBiblioData($biblionumber);
$record = C4::Biblio::GetMarcBiblio($biblionumber);

#Compare the datereceiveds. They should be the same as set during the last test.
ok( ($bibliodata->{datereceived} eq $datereceivedIso),
       "Searchable datereceived: Setting the biblio.datereceived only once.");
ok( ($record->subfield($datereceivedFieldCode, $datereceivedSubfieldCode) eq $datereceivedIso),
       "Searchable datereceived: Upserting the MARC Subfield datereceived is mapped only once.");


### Test8 && 9 >> Overriding the biblio.datereceived using a bibliodata-hash.     ###
$bibliodata->{datereceived} = undef;
$datereceived = DateTime->new(time_zone => C4::Context->tz(),
                              year => 1985,
                              month => 12,
                              day => 10,
                              hour => 2);
$datereceivedIso = $datereceived->ymd().' '.$datereceived->hms(); #Replace the 'T' in ISO standard with a ' '
$error = C4::Biblio::UpdateDatereceived($bibliodata, $datereceived);
$bibliodata = C4::Biblio::GetBiblioData($biblionumber);
$record = C4::Biblio::GetMarcBiblio($biblionumber);

#Compare the datereceiveds. They should be the same as set during the last test.
ok( ($bibliodata->{datereceived} eq $datereceivedIso),
       "Searchable datereceived: Overriding the biblio.datereceived.");
ok( ($record->subfield($datereceivedFieldCode, $datereceivedSubfieldCode) eq $datereceivedIso),
       "Searchable datereceived: Overriding the MARC Subfield datereceived is mapped.");


### Test10 >> No biblionumber.     ###
$bibliodata->{biblionumber} = undef;
$error = C4::Biblio::UpdateDatereceived($bibliodata);
ok( ($error eq 'NO_BIBLIONUMBER'),
       "Searchable datereceived: ERROR, No biblionumber in bibliodata caught.");

### Test11 >> No biblionumber2.     ###
$error = C4::Biblio::UpdateDatereceived(undef);
ok( ($error eq 'NO_BIBLIONUMBER'),
       "Searchable datereceived: ERROR, No biblionumber caught.");

### Test12 >> No bibliodate found from biblionumber.     ###
$error = C4::Biblio::UpdateDatereceived(9999559995);
ok( ($error eq 'NO_BIBLIODATA'),
       "Searchable datereceived: ERROR, No bibliodata from biblionumber caught.");

### Test13 >> datereceived must be a DateTime.     ###
$error = C4::Biblio::UpdateDatereceived($biblionumber, '2012-12-31T23:45:12');
ok( ($error eq 'NOT_DATETIME'),
       "Searchable datereceived: ERROR, Not a DateTime caught.");


$dbh->rollback();