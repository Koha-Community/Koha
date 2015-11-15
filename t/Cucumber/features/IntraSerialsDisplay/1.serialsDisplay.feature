# Copyright Vaara-kirjastot 2015
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

Serials display improvements:

Shorthands:
SAMap - Serials Availability Map
ITRow - Items Table Row

Given Subscriptions with many SerialItems
And we have received some Serials in the current loggedinbranch
When the 'librarian' goes to the 'catalogue/detail.pl'-page
Then the newest 20 Serials which have Items attached (SerialItems) and are present in the loggedinbranch are displayed in the Items Table.
And the SAMap is displayed in the view

When the user clicks the "Hold"-button in the ITRow of Item '1N001'
Then the HoldPicker-widget is displayed
And the HoldPicker-widget has preselected the correct 'Biblio, Item and PickupBranch'

When the user enters the Userid 'achiles' to the HoldPicker's Borrower Search Element
And presses 'enter'
Then the Borrower 'achiles' is displayed in the HoldPicker.

When the user clicks 'Place Hold' in the HoldPicker
Then 'Hold placed' is displayed in the HoldPicker
And 'Hold placed' is appended to the ITRow's Hold report Element
And the Borrower 'achiles' has a new Item-level Hold for Item '1N001'

When the user clicks the "Hold"-button in the ITRow of Item '1N005'
Then the HoldPicker-widget is moved to overlap the ITRow of Item '1N005'
And the HoldPicker-widget has preselected the correct 'Item'

When the user clicks the "X"-button in the HoldPicker
Then the HoldPicker is hidden



When the 'librarian' changes the loggedinbranch to a Branch with no SerialItems for the current Biblio
And the 'librarian' goes to the 'catalogue/detail.pl'-page
Then the newest 20 Serials which have Items attached (SerialItems) from any branch are displayed in the Items Table.
And the SAMap is displayed in the view

When the user expands the SAMap Volume
Then the user is shown all the Numbers under that Volume.

When the user clicks a Serial Number in the SAMap
Then all the SerialItems for that Volume and Number are displayed in the Items Table.
And the Item '1N004' in the Items Table has a status of 'available'

Given the Item '2N001-2015:10' is transferred
And the Item '2N002-2015:10' is on hold
And the Item '2N003-2015:10' is waiting for pickup
When the user clicks the Serial Number '2015:10' in the SAMap
Then the Item '2N001' in the Items Table has a status of 'is transferred'
And the Item '2N002' in the Items Table has a status of 'hold placed'
And the Item '2N003' in the Items Table has a status of 'waiting for pickup'



@overdues
Feature: To configure the Overdues module, we need to be able to CREATE, READ,
 UPDATE and DELETE Overduerules.

 Scenario: Remove all overduerules so we can start testing this feature unhindered
  Given there are no previous overdue notifications
  Then I cannot find any overduerules

 Scenario: Create some default overdue rules.
  Given a set of overduerules
   | branchCode | borrowerCategory | letterNumber | messageTransportTypes | delay | letterCode | debarred | fine |
   |            | S                | 1            | print, sms            | 20    | ODUE1      | 0        | 0.0  |
   |            | S                | 2            | print, sms            | 30    | ODUE2      | 0        |      |
   |            | S                | 3            | print, sms            | 40    | ODUE3      | 1        | 5    |
   |            | PT               | 1            | print, sms            | 10    | ODUE1      | 0        | 3    |
   |            | PT               | 2            | print, sms            | 20    | ODUE2      | 0        | 3.3  |
   |            | PT               | 3            | print, sms            | 30    | ODUE3      | 1        | 6.5  |
   | CPL        | PT               | 1            | print                 | 25    | ODUE1      | 0        | 3.3  |
   | CPL        | PT               | 2            | print                 | 45    | ODUE2      | 1        | 5.5  |
   | FTL        | YA               | 1            | print, sms, email     | 15    | ODUE1      | 1        | 1.3  |
   | FTL        | YA               | 2            | print, sms, email     | 30    | ODUE2      | 1        | 2.5  |
   | FTL        | YA               | 3            | print, sms, email     | 45    | ODUE3      | 1        | 1.5  |
   | CCL        | YA               | 1            | print, sms, email     | 45    | ODUE1      | 0        | 1.5  |
   | CCL        | YA               | 2            | print, sms, email     | 90    | ODUE2      | 1        | 2.5  |
   #Last two rows are deleted later.
  Then I should find the rules from the OverdueRulesMap-object.

 Scenario: Update overdue rules defined in the last scenario.
  When I've updated the following overduerules
   | branchCode | borrowerCategory | letterNumber | messageTransportTypes | delay | letterCode | debarred | fine |
   | CCL        | YA               | 1            | print                 | 15    | ODUE1      | 0        | 0.0  |
   | CCL        | YA               | 2            | print,sms             | 45    | ODUE3      | 0        | 5    |
  Then I should find the rules from the OverdueRulesMap-object.

 Scenario: Delete some overdue rules defined in the last scenarios.
  When I've deleted the following overduerules, then I cannot find them.
   | branchCode | borrowerCategory | letterNumber |
   | CCL        | YA               | 1            |
   | CCL        | YA               | 2            |

 Scenario: Create an overduerule with a bad value
  When I try to add overduerules with bad values, I get errors.
   | branchCode | borrowerCategory | letterNumber | messageTransportTypes | delay | letterCode | debarred | fine  | errorCode          |
   | CPL        |                  | 1            | print, sms            | 0     | ODUE1      | 0        | 1.3   | NOBORROWERCATEGORY |
   | FTL        | S                | 2d           | sms                   | 1     | ODUE2      | 1        | 1.3   | BADLETTERNUMBER    |
   | FTL        | S                |              | sms                   | 1     | ODUE2      | 1        | 1.3   | BADLETTERNUMBER    |
   | CPL        | S                | 2            | email                 | f3    | ODUE2      | 1        | 1.3   | BADDELAY           |
   | CPL        | S                | 2            | email                 |       | ODUE2      | 1        | 1.3   | BADDELAY           |
   | FTL        | S                | 3            | print                 | 3     |            | 1        | 1.3   | NOLETTER           |
   | FTL        | S                | 1            | print                 | 3     | ODUE3      | Fäbä     | 1.3   | BADDEBARRED        |
   | FTL        | S                | 1            | print, email          | 3     | ODUE2      | 1        | 2,5   | BADFINE            |
   | FTL        | S                | 1            | print, email          | 3     | ODUE2      | 1        | f2.5  | BADFINE            |
   | FTL        | S                | 3            |                       | 10    | ODUE3      | 0        | 1.3   | NOTRANSPORTTYPES   |

 Scenario: Tear down any database additions from this feature
  When all scenarios are executed, tear down database changes.
