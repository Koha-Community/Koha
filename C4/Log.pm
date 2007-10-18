package C4::Log; #assumes C4/Log

#package to deal with Logging Actions in DB


# Copyright 2000-2002 Katipo Communications
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
use C4::Context;
use C4::Date;

require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::Log - Koha Log Facility functions

=head1 SYNOPSIS

  use C4::Log;

=head1 DESCRIPTION

The functions in this module perform various functions in order to log all the operations done on the Database, including deleting and undeleting books, adding/editing members, etc.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&logaction &GetLogStatus &displaylog &GetLogs);

=item logaction

  &logaction($usernumber, $modulename, $actionname, $infos);

Adds a record into action_logs table to report the different changes upon the database

=cut

#'
sub logaction {
  my ($usernumber,$modulename, $actionname, $objectnumber, $infos)=@_;
    $usernumber='' unless $usernumber;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Insert into action_logs (timestamp,user,module,action,object,info) values (now(),?,?,?,?,?)");
    $sth->execute($usernumber,$modulename,$actionname,$objectnumber,$infos);
    $sth->finish;
}

=item GetLogStatus

  $status = GetLogStatus;

C<$status> is a hasref like this example:
    $hash = {
        BorrowersLog   => 1,
        CataloguingLog => 0,
        IssueLog       => 0,
        ...
    }

=cut

#'
sub GetLogStatus {
    my %hash;
    $hash{BorrowersLog}    = C4::Context->preference("BorrowersLog");
    $hash{CataloguingLog}  = C4::Context->preference("CataloguingLog");
    $hash{IssueLog}        = C4::Context->preference("IssueLog");
    $hash{ReturnLog}       = C4::Context->preference("CataloguingLog");
    $hash{SubscriptionLog} = C4::Context->preference("CataloguingLog");
    $hash{LetterLog}       = C4::Context->preference("LetterLog");
    $hash{FinesLog}       = C4::Context->preference("FinesLog");
    
    return \%hash;
}

=item displaylog

  &displaylog($modulename, @filters);
  $modulename is the name of the module on which the user wants to display logs
  @filters is an optional table of hash containing :
      - name : the name of the variable to filter
    - value : the value of the filter.... May be with * joker

returns a table of hash containing who did what on which object at what time

=cut

#'
sub displaylog {
  my ($modulename, @filters) = @_;
    my $dbh = C4::Context->dbh;
    my $strsth;
    if ($modulename eq "catalogue"){
        $strsth="select action_logs.timestamp, action_logs.action, action_logs.info, borrowers.cardnumber, borrowers.surname, borrowers.firstname, borrowers.userid,";
        $strsth .= "biblio.biblionumber, biblio.title, biblio.author" ;#if ($modulename eq "acqui.simple");
        $strsth .= " FROM action_logs LEFT JOIN borrowers ON borrowers.borrowernumber=action_logs.user";
        $strsth .= " LEFT JOIN biblio ON action_logs.object=biblio.biblionumber " ;#if ($modulename eq "acqui.simple");
    
        $strsth .=" WHERE action_logs.module = 'cataloguing' ";# if ($modulename eq "acqui.simple");
        if (@filters) {
            foreach my $filter (@filters) {
                if ($filter->{name} =~ /user/) {
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND borrowers.surname like ".$filter->{value};
                } elsif ($filter->{name} =~ /title/) {
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND biblio.title like ".$filter->{value};
                } elsif ($filter->{name} =~ /author/) {
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND biblio.author like ".$filter->{value};
                }
            }
        }
    } elsif ($modulename eq "acqui") {
        $strsth=qq|select action_logs.timestamp, action_logs.action, action_logs.info, borrowers.cardnumber, borrowers.surname, borrowers.firstname, borrowers.userid,
        biblio.biblionumber, biblio.title, biblio.author
        FROM action_logs LEFT JOIN borrowers ON borrowers.borrowernumber=action_logs.user 
        LEFT JOIN  biblio ON action_logs.object=biblio.biblionumber
        WHERE action_logs.module = 'cataloguing' |;# if ($modulename eq "acqui.simple");
        if (@filters){
            foreach my $filter (@filters){
                if ($filter->{name} =~ /user/){
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND borrowers.surname like ".$filter->{value};
                }elsif ($filter->{name} =~ /title/){
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND biblio.title like ".$filter->{value};
                }elsif ($filter->{name} =~ /author/){
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND biblio.author like ".$filter->{value};
                }
            }
        }
    } elsif ($modulename eq "members"){
        $strsth=qq|SELECT action_logs.timestamp, action_logs.action, action_logs.info, 
        borrowers.cardnumber, borrowers.surname, borrowers.firstname, borrowers.userid,
        bor2.cardnumber, bor2.surname, bor2.firstname, bor2.userid
        FROM action_logs LEFT JOIN borrowers ON borrowers.borrowernumber=action_logs.user LEFT JOIN borrowers as bor2 ON action_logs.object=bor2.borrowernumber
        WHERE action_logs.module = 'members' |;# if ($modulename eq "acqui.simple");
        if (@filters){
            foreach my $filter (@filters){
                if ($filter->{name} =~ /user/){
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND borrowers.surname like ".$filter->{value};
                }elsif ($filter->{name} =~ /surname/){
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND bor2.surname like ".$filter->{value};
                }elsif ($filter->{name} =~ /firstname/){
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND bor2.firsntame like ".$filter->{value};
                }elsif ($filter->{name} =~ /cardnumber/){
                    $filter->{value}=~s/\*/%/g;
                    $strsth .= " AND bor2.cardnumber like ".$filter->{value};
                }
            }
        }
    }
    
    if ($strsth){
        my $sth=$dbh->prepare($strsth);
        $sth->execute;
        my @results;
        my $count;
        my $hilighted=1;
        while (my $data = $sth->fetchrow_hashref){
            $data->{hilighted} = ($hilighted>0);
            $data->{info} =~ s/\n/<br\/>/g;
            $data->{day} = format_date($data->{timestamp});
            push @results, $data;
            $count++;
            $hilighted = -$hilighted;
        }
        return ($count, \@results);
    } else {return 0;}
}

=head2 GetLogs

$logs = GetLogs($datefrom,$dateto,$user,$module,$action,$object,$info);

Return: 
C<$logs> is a ref to a hash which containts all columns from action_logs

=cut

sub GetLogs {
    my $datefrom = shift;
    my $dateto   = shift;
    my $user     = shift;
    my $module   = shift;
    my $action   = shift;
    my $object   = shift;
    my $info     = shift;
    
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   action_logs
        WHERE 1
    ";
    $query .= " AND DATE_FORMAT(timestamp, '%Y-%m-%d') >= \"".$datefrom."\" " if $datefrom;
    $query .= " AND DATE_FORMAT(timestamp, '%Y-%m-%d') <= \"".$dateto."\" " if $dateto;
    $query .= " AND user LIKE \"%".$user."%\" "     if $user;
    $query .= " AND module LIKE \"%".$module."%\" " if $module;
    $query .= " AND action LIKE \"%".$action."%\" " if $action;
    $query .= " AND object LIKE \"%".$object."%\" " if $object;
    $query .= " AND info LIKE \"%".$info."%\" "     if $info;
    
    my $sth = $dbh->prepare($query);
    $sth->execute;
    
    my @logs;
    while( my $row = $sth->fetchrow_hashref ) {
        $row->{$row->{module}} = 1;
        push @logs , $row;
    }
    return \@logs;
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
