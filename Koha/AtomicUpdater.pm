package Koha::AtomicUpdater;

# Copyright Open Source Freedom Fighters
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

use Modern::Perl;
use Carp;
use Scalar::Util qw(blessed);
use Try::Tiny;
use Data::Format::Pretty::Console qw(format_pretty);
use Git;
use YAML::XS;
use File::Slurp;

use C4::Installer;

use Koha::Database;
use Koha::Cache;
use Koha::AtomicUpdate;

use base qw(Koha::Objects);

use Koha::Exception::File;
use Koha::Exception::Parse;
use Koha::Exception::BadParameter;
use Koha::Exception::DuplicateObject;

sub _type {
    return 'Atomicupdate';
}
sub object_class {
    return 'Koha::AtomicUpdate';
}
sub _get_castable_unique_columns {
    return ['atomicupdate_id'];
}

=head find
@OVERLOADS
    my $$atomicUpdate = $atomicUpdater->find($issue_id || $atomicupdate_id);

@PARAM1 Scalar, issue_id or atomicupdate_id
@RETURNS Koha::AtomicUpdate
@THROWS Koha::Exception::DuplicateObject, if @PARAM1 matches both the issue_id and atomicupdate_id,
                                          you should change your issue naming convention.
=cut

sub find {
    my ( $self, $id ) = @_;
    return unless $id;
    if (ref($id)) {
        return $self->SUPER::find($id);
    }

    my @results = $self->_resultset()->search({'-or' => [
                                            {issue_id => $id},
                                            {atomicupdate_id => $id}
                                        ]});
    return unless @results;
    if (scalar(@results > 1)) {
        my @cc1 = caller(1);
        my @cc0 = caller(0);
        Koha::Exception::DuplicateObject->throw(error => $cc1[3]."() -> ".$cc0[3]."():> Given \$id '$id' matches multiple issue_ids and atomicupdate_ids. Aborting because couldn't get a uniquely identifying AtomicUpdate.");
    }

    my $object = $self->object_class()->_new_from_dbic( $results[0] );
    return $object;
}

my $updateOrderFilename = '_updateorder';

sub new {
    my ($class, $params) = @_;

    my $cache = Koha::Cache->new();
    my $self = $cache->get_from_cache('Koha::AtomicUpdater') || {};
    bless($self, $class);

    $self->{verbose} = $params->{verbose} || $self->{verbose} || 0;
    $self->{scriptDir} = $params->{scriptDir} || $self->{scriptDir} || C4::Context->config('intranetdir') . '/installer/data/mysql/atomicupdate/';
    $self->{confFile} = $params->{confFile} || $self->{confFile} || C4::Context->config('intranetdir') . '/installer/data/mysql/atomicupdate.conf';
    $self->{gitRepo} = $params->{gitRepo} || $self->{gitRepo} || $ENV{KOHA_PATH};
    $self->{dryRun} = $params->{dryRun} || $self->{dryRun} || 0;

    $self->_loadConfig();
    return $self;
}

=head getAtomicUpdates

    my $atomicUpdates = $atomicUpdater->getAtomicUpdates();

Gets all the AtomicUpdate-objects in the DB. This result should be Koha::Cached.
@RETURNS HASHRef of Koha::AtomicUpdate-objects, keyed with the issue_id
=cut

sub getAtomicUpdates {
    my ($self) = @_;

    my @au = $self->search({});
    my %au; #HASHify the AtomicUpdate-objects for easy searching.
    foreach my $au (@au) {
        $au{$au->issue_id} = $au;
    }
    return \%au;
}

sub addAtomicUpdate {
    my ($self, $params) = @_;
    print "Adding atomicupdate '".($params->{issue_id} || $params->{filename})."'\n" if $self->{verbose} > 2;

    my $atomicupdate = Koha::AtomicUpdate->new($params);
    $atomicupdate->store();
    $atomicupdate = $self->find($atomicupdate->issue_id);
    return $atomicupdate;
}

=head addAllAtomicUpdates

Gets all pending atomicupdates and marks them added. This is useful for installer
where we want to set all atomicupdates marked as applied to avoid applying them
after installation.

=cut

sub addAllAtomicUpdates {
    my ($self) = @_;

    my $atomicUpdates = $self->getPendingAtomicUpdates();
    foreach my $key (keys %$atomicUpdates) {
        $self->addAtomicUpdate($atomicUpdates->{$key}->unblessed);
    }

    return $atomicUpdates;
}

sub removeAtomicUpdate {
    my ($self, $issueId) = @_;
    print "Deleting atomicupdate '$issueId'\n" if $self->{verbose} > 2;

    my $atomicupdate = $self->find($issueId);
    if ($atomicupdate) {
        $atomicupdate->delete;
        print "Deleted atomicupdate '$issueId'\n" if $self->{verbose} > 2;
    }
    else {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->removeIssueFromLog():> No such Issue '$issueId' stored to the atomicupdates-table");
    }
}

sub listToConsole {
    my ($self) = @_;
    my @stringBuilder;

    my @atomicupdates = $self->search({});
    foreach my $au (@atomicupdates) {
        push @stringBuilder, $au->unblessed();
    }
    return Data::Format::Pretty::Console::format_pretty(\@stringBuilder);
}

sub listPendingToConsole {
    my ($self) = @_;
    my @stringBuilder;

    my $atomicUpdates = $self->getPendingAtomicUpdates();
    foreach my $key (sort keys %$atomicUpdates) {
        my $au = $atomicUpdates->{$key};
        push @stringBuilder, $au->unblessed();
    }
    return Data::Format::Pretty::Console::format_pretty(\@stringBuilder);
}

sub getPendingAtomicUpdates {
    my ($self) = @_;

    my %pendingAtomicUpdates;
    my $atomicupdateFiles = $self->_getValidAtomicUpdateScripts();
    my $atomicUpdatesDeployed = $self->getAtomicUpdates();
    foreach my $key (keys(%$atomicupdateFiles)) {
        my $au = $atomicupdateFiles->{$key};
        my $parsedissueId =  $self->_parseIssueIds($au->issue_id);
        unless ($atomicUpdatesDeployed->{$au->issue_id} || $atomicUpdatesDeployed->{$parsedissueId}) {
            #This script hasn't been deployed.
            $pendingAtomicUpdates{$au->issue_id} = $au;
        }
    }
    return \%pendingAtomicUpdates;
}

=head applyAtomicUpdates

    my $atomicUpdater = Koha::AtomicUpdater->new();
    my $appliedAtomicupdates = $atomicUpdater->applyAtomicUpdates();

Checks the atomicupdates/-directory for any not-applied update scripts and
runs them in the order specified in the _updateorder-file in atomicupdate/-directory.

@RETURNS ARRAYRef of Koha::AtomicUpdate-objects deployed on this run
=cut

sub applyAtomicUpdates {
    my ($self) = @_;

    my %appliedUpdates;

    my $atomicUpdates = $self->getPendingAtomicUpdates();
    my $updateOrder = $self->getUpdateOrder();
    foreach my $issueId ( @$updateOrder ) {
        my $atomicUpdate = $atomicUpdates->{$issueId};
        next unless $atomicUpdate; #Not each ordered Git commit necessarily have a atomicupdate-script.

        $self->applyAtomicUpdate($atomicUpdate);
        $appliedUpdates{$issueId} = $atomicUpdate;
    }

    #Check that we have actually applied all the updates.
    my $stillPendingAtomicUpdates = $self->getPendingAtomicUpdates();
    if (scalar(%$stillPendingAtomicUpdates)) {
        my @issueIds = sort keys %$stillPendingAtomicUpdates;
        print "Warning! After upgrade, the following atomicupdates are still pending '@issueIds'\n Try rebuilding the atomicupdate-scripts update order from the original Git repository.\n";
    }

    return \%appliedUpdates;
}

sub applyAtomicUpdate {
    my ($self, $atomicUpdate) = @_;
    #Validate params
    unless ($atomicUpdate) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->applyAtomicUpdate($atomicUpdate):> Parameter must be a Koha::AtomicUpdate-object or a path to a valid atomicupdates-script!");
    }
    if ($atomicUpdate && ref($atomicUpdate) eq '') { #We have a scalar, presumably a filepath to atomicUpdate-script.
        $atomicUpdate = Koha::AtomicUpdate->new({filename => $atomicUpdate});
    }
    $atomicUpdate = Koha::AtomicUpdater->cast($atomicUpdate);

    my $filename = $atomicUpdate->filename;
    print "Applying file '$filename'\n" if $self->{verbose} > 2;

    unless ($self->{dryRun}) {
        my $rv;
        if ( $filename =~ /\.sql$/ ) {
            my $installer = C4::Installer->new();
            $rv = $installer->load_sql( $self->{scriptDir}.'/'.$filename ) ? 0 : 1;
        } elsif ( $filename =~ /\.(perl|pl)$/ ) {
            # Koha-community uses .perl files for developer atomic updates. These
            # simplified versions of atomicupdates do not instantiate $dbh, and
            # subroutines CheckVersion and SetVersion from updatedatabase.pl are
            # out of scope when executed by the AtomicUpdater. In order to support
            # community dev atomicupdates, we have to re-define these subroutines
            # and pass $dbh into the .perl file.
            #
            # See atomicupdates/skeleton.perl for default community template.
            if ($filename =~ /\.perl$/) {
                our $dbh = C4::Context->dbh;
                sub SetVersion   { return 1; }
                sub CheckVersion {
                    unless ($_[0] =~ /^XXX$/) {
                        Koha::Exception::File->throw(
                            error => 'Atomicupdate is not a dev atomicupdate. Dev'
                            .' updates are identified by CheckVersion("XXX").'
                            ." Given version is $_[0]."
                        );
                    }
                    return 1;
                }
            }

            my $fileAndPath = $self->{scriptDir}.'/'.$filename;
            $rv = do $fileAndPath;
            unless ($rv) {
                warn "couldn't parse $fileAndPath: $@\n" if $@;
                warn "couldn't do $fileAndPath: $!\n"    unless defined $rv;
                warn "couldn't run $fileAndPath\n"       unless $rv;
            }
        }
        print 'AtomicUpdate '.$atomicUpdate->filename." done.\n" if $self->{verbose} > 0;
        $atomicUpdate->store();
    }

    print "File '$filename' applied\n" if $self->{verbose} > 2;
}

=head _getValidAtomicUpdateScripts

@RETURNS HASHRef of Koha::AtomicUpdate-objects, of all the files
                in the atomicupdates/-directory that can be considered valid.
                Validity is currently conforming to the naming convention.
                Keys are the issue_id of atomicupdate-scripts
                Eg. {'Bug8584' => Koha::AtomicUpdate,
                     ...
                    }
=cut

sub _getValidAtomicUpdateScripts {
    my ($self) = @_;

    my %atomicUpdates;
    opendir( my $dirh, $self->{scriptDir} );
    foreach my $file ( sort readdir $dirh ) {
        print "Looking at file '$file'\n" if $self->{verbose} > 2;

        my $atomicUpdate;
        try {
            $atomicUpdate = Koha::AtomicUpdate->new({filename => $file});
        } catch {
            if (blessed($_)) {
                if ($_->isa('Koha::Exception::File') || $_->isa('Koha::Exception::Parse')) {
                    print "File-error for file '$file': ".$_->error()." \n" if $self->{verbose} > 2;
                    #We can ignore filename validation issues, since the directory has
                    #loads of other types of files as well. Like README . ..
                }
                else {
                    $_->rethrow();
                }
            }
            else {
                die $_; #Rethrow the unknown Exception
            }
        };
        next unless $atomicUpdate;

        $atomicUpdates{$atomicUpdate->issue_id} = $atomicUpdate;
    }
    return \%atomicUpdates;
}

=head getUpdateOrder

    $atomicUpdater->getUpdateOrder();

@RETURNS ARRAYRef of Strings, IssueIds ordered from the earliest to the newest.
=cut

sub getUpdateOrder {
    my ($self) = @_;

    my $updateOrderFilepath = $self->{scriptDir}."/$updateOrderFilename";
    open(my $FH, "<:encoding(UTF-8)", $updateOrderFilepath) or die "Koha::AtomicUpdater->_saveAsUpdateOrder():> Couldn't open the updateOrderFile for reading\n$!\n";
    my @updateOrder = map {chomp($_); $_;} <$FH>;
    close $FH;
    return \@updateOrder;
}

=head

    my $issueIdOrder = Koha::AtomicUpdater->buildUpdateOrderFromGit(10000);

Creates a update order file '_updateorder' for atomicupdates to know which updates come before which.
This is a simple way to make sure the atomicupdates are applied in the correct order.
The update order file is by default in your $KOHA_PATH/installer/data/mysql/atomicupdate/_updateorder

This requires a Git repository to be in the $ENV{KOHA_PATH} to be effective.

@PARAM1 Integer, How many Git commits to include to the update order file,
                 10000 is a good default.
@RETURNS ARRAYRef of Strings, The update order of atomicupdates from oldest to newest.
=cut

sub buildUpdateOrderFromGit {
    my ($self, $gitCommitsCount) = @_;

    my %orderedCommits; #Store the commits we have ordered here, so we don't reorder any followups.
    my @orderedCommits;

    my $i = 0; #Index of array where we push issue_ids
    my $commits = $self->_getGitCommits($gitCommitsCount);
    foreach my $commit (reverse @$commits) {

        my ($commitHash, $commitTitle) = $self->_parseGitOneliner($commit);
        unless ($commitHash && $commitTitle) {
            next();
        }

        my $issueId;
        try {
            $issueId = Koha::AtomicUpdate::getIssueIdentifier(undef, $commitTitle);
        } catch {
            if (blessed($_)) {
                if($_->isa('Koha::Exception::Parse')) {
                    #Silently ignore parsing errors
                    print "Koha::AtomicUpdater->buildUpdateOrderFromGit():> Couldn't parse issue_id from Git commit title '$commitTitle'.\n"
                                    if $self->{verbose} > 1;
                }
                else {
                    $_->rethrow();
                }
            }
            else {
                die $_;
            }
        };
        next unless $issueId;

        if ($orderedCommits{ $issueId }) {
            next();
        }
        else {
            $orderedCommits{ $issueId } = $issueId;
            $orderedCommits[$i] = $issueId;
            $i++;
        }
    }

    $self->_saveAsUpdateOrder(\@orderedCommits);
    return \@orderedCommits;
}

sub _parseIssueIds {
    my ($self, $issueId) = @_;

    my @keys = split /(-)/, $issueId;
    delete $keys[1];
    @keys = grep defined, @keys;

    return join('', @keys);
}

sub _getGitCommits {
    my ($self, $count) = @_;
    my $repo = Git->repository(Directory => $self->{gitRepo});

    #We can read and print 10000 git commits in less than three seconds :) good Git!
    my @commits = $repo->command('show', '--pretty=oneline', '--no-patch', '-'.$count);
    return \@commits;
}

sub _parseGitOneliner {
    my ($self, $gitLiner) = @_;

    my ($commitHash, $commitTitle) = ($1, $2) if $gitLiner =~ /^(\w{40}) (.+)$/;
    unless ($commitHash && $commitTitle) {
        print "Koha::AtomicUpdater->parseGitOneliner():> Couldn't parse Git commit '$gitLiner' to hash and title.\n"
                        if $self->{verbose} > 1;
        return();
    }
    return ($commitHash, $commitTitle);
}

sub _saveAsUpdateOrder {
    my ($self, $orderedUpdates) = @_;

    my $updateOrderFilepath = $self->{scriptDir}."/$updateOrderFilename";
    my $text = join("\n", @$orderedUpdates);
    open(my $FH, ">:encoding(UTF-8)", $updateOrderFilepath) or die "Koha::AtomicUpdater->_saveAsUpdateOrder():> Couldn't open the updateOrderFile for writing\n$!\n";
    print $FH $text;
    close $FH;
}

=head %config
Package static variable to the configurations Hash.
=cut

my $config;

sub _loadConfig {
    my ($self) = @_;

    if (-e $self->{confFile}) {
        my $yaml = File::Slurp::read_file( $self->{confFile}, { binmode => ':utf8' } ) ;
        $config = YAML::XS::Load($yaml);
    }
}

1;
