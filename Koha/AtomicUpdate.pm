package Koha::AtomicUpdate;

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
use File::Basename;

use Koha::Database;

use base qw(Koha::Object);

use Koha::Exception::BadParameter;
use Koha::Exception::Parse;
use Koha::Exception::File;


sub _type {
    return 'Atomicupdate';
}

=head new

    my $atomicUpdate = Koha::AtomicUpdate->new({filename => 'Bug54321-FixItPlease.pl'});

Creates a Koha::AtomicUpdate-object from the given parameters-HASH
@PARAM1 HASHRef of object parameters:
        'filename' => MANDATORY, The filename of the atomicupdate-script without the path-component.
        'issue_id' => OPTIONAL, the desired issue_id. It is better to let the module
                                find this from the filename, but is useful for testing purposes.
@RETURNS Koha::AtomicUpdate-object
@THROWS Koha::Exception::Parse from getIssueIdentifier()
@THROWS Koha::Exception::File from _validateFilename();
=cut

sub new {
    my ($class, $params) = @_;
    $class->_validateParams($params);

    my $self = {};
    bless($self, $class);
    $self->set($params);
    return $self;
}

sub _validateParams {
    my ($class, $params) = @_;

    my @mandatoryParams = ('filename');
    foreach my $mp (@mandatoryParams) {
        Koha::Exception::BadParameter->throw(
            error => "$class->_validateParams():> Param '$mp' must be given.")
                unless($params->{$mp});
    }
    $params->{filename} = $class->_validateFilename($params->{filename});

    $params->{issue_id} = getIssueIdentifier($params->{filename});
}

=head _validateFilename

Makes sure the given file is a valid AtomicUpdate-script.
Currently simply checks for naming convention and file suffix.

NAMING CONVENTION:
    Filename must contain one of the unique issue identifier prefixes from this
    list @allowedIssueIdentifierPrefixes immediately followed by the numeric
    id of the issue, optionally separated by any of the following [ :-]
    Eg. Bug-45453, #102, #:53

@PARAM1 String, filename of validatable file, excluding path.
@RETURNS String, the koha.atomicupdates.filename if the given file is considered a well formed update script.
                 Removes the full path if present and returns only the filename component.

@THROWS Koha::Exception::File, if the given file doesn't have a proper naming convention

=cut

sub _validateFilename {
    my ($self, $fileName) = @_;

    Koha::Exception::File->throw(error => __PACKAGE__."->_validateFilename():> Filename '$fileName' has unknown suffix")
            unless $fileName =~ /\.(sql|perl|pl)$/;  #skip other files

    $fileName = File::Basename::basename($fileName);

    return $fileName;
}

=head getIssueIdentifier
@STATIC

Extracts the unique issue identifier from the atomicupdate DB upgrade script.

@PARAM1 String, filename, excluding path.
        OR
@PARAM2 String, Git commit title.
@RETURNS String, The unique issue identifier

@THROWS Koha::Exception::Parse, if the unique identifier couldn't be parsed.
=cut

sub getIssueIdentifier {
    my ($fileName, $gitTitle) = @_;

    Koha::Exception::BadParameter->throw(error => "Either \$gitTitle or \$fileName must be given!") unless ($fileName || $gitTitle);

    my ($prefix, $issueNumber, $followupNumber, $issueDescription, $file_type);
    ($prefix, $issueNumber, $followupNumber, $issueDescription, $file_type) =
            getFileNameElements($fileName)
                if $fileName;
    ($prefix, $issueNumber, $followupNumber, $issueDescription, $file_type) =
            getGitCommitTitleElements($gitTitle)
                if $gitTitle;

    $prefix = uc $prefix if length $prefix <= 2;
    $prefix = ucfirst(lc($prefix)) if length $prefix > 2;

    my @keys = ($prefix, $issueNumber);
    push(@keys, $followupNumber) if $followupNumber;
    return join('-', @keys);
}

=head2 getFileNameElements
@STATIC

Parses the given file name for atomicupdater markers.

@PARAM1 String, base filename of the atomicupdate-file
@RETURNS ($prefix, $issueNumber, $followupNumber, $issueDescription, $fileType)
@THROWS Koha::Exception::Parse, if the fileName couldn't be parsed.

=cut

sub getFileNameElements {
    my ($fileName) = @_;

    Koha::Exception::File->throw(error =>
        __PACKAGE__."->getIssueNameElements($fileName):> \$fileName cannot contain the comment-character '\x23'.".
        " It will screw up the make build chain.") if $fileName =~ /\x23/;

    if ($fileName =~ /^([a-zA-Z]{1,3})(?:\W|[_])?(\d+)(?:(?:\W|[_])(\d+))?(?:(?:\W|[_])(.+?))?\.(\w{1,5})$/) {
        return ($1, $2, $3, $4, $5);
    }

    Koha::Exception::Parse->throw(error => __PACKAGE__."->getIssueNameElements($fileName):> Couldn't parse the given \$fileName");
}

=head2 getGitCommitTitleElements
@STATIC

Parses the given Git commit title for atomicupdater markers.

@PARAM1 String, git commit title
@RETURNS ($prefix, $issueNumber, $followupNumber, $issueDescription)
@THROWS Koha::Exception::Parse, if the title couldn't be parsed.

=cut

sub getGitCommitTitleElements {
    my ($title) = @_;

    Koha::Exception::File->throw(error =>
        __PACKAGE__."->getGitCommitTitleElements($title):> \$prefix cannot contain the comment-character '\x23'.".
        " It will screw up the make build chain.") if $title =~ /^.{0,2}\x23.{0,2} ?\W ?/;

    if ($title =~ /^(\w{1,3})(?: ?\W ?)(\d+)(?:(?:\W)(\d+))?(?: ?\W? ?)(.+?)$/) {

        #my ($prefix, $issueNumber, $followupNumber, $issueDescription) = ($1, $2, $3, $4);
        #return ($prefix, $issueNumber, $followupNumber, $issueDescription);
        return ($1, $2, $3, $4);
    }

    Koha::Exception::Parse->throw(error => __PACKAGE__."->getGitCommitTitleElements($title):> Couldn't parse the given \$title");
}

1;
