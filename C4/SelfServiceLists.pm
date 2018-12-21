package C4::SelfServiceLists;

# Copyright 2018 The National Library of Finland
#
# This file is part of Koha.
#

use Modern::Perl '2015';

use Try::Tiny;
use Scalar::Util qw(blessed);
use Carp::Always;

use File::Temp;
use File::Copy;
use IPC::Cmd;
use IPC::Run;

use C4::Context;
use C4::SelfService;
use C4::SelfService::BlockManager;
use C4::Encryption;
use C4::Encryption::Configuration;

use Koha::Logger;
my $logger = bless({lazyLoad => {category => __PACKAGE__}}, 'Koha::Logger');

=head2 run

Runs the whole

  extract()

  export()

  encrypt()

  deploy()

-pipeline

For arguments, see the script misc/cronjobs/self_service_lists.pl

=cut

sub run {
    my ($argv) = @_;
    $argv->{type} = BlockListType->cast($argv->{type});
    $logger->info("Starting list extraction");

    my $objects =  extract($argv->{limit});
    my $filePath = export($objects, $argv->{columns}, $argv->{type});
    $filePath =    C4::Encryption::encrypt($filePath, $argv->{encrypt}) if $argv->{encrypt};
    deploy($filePath, $argv->{file}.'.'.$argv->{type}->{suffix}.($argv->{encrypt} ? '.gpg' : ''));
}

=head2 extract

Extracts borrowers columns and merges the HasSelfServicePermission with them.
HasSelfServicePermission-column is calculated using the syspref 'SSRules'

 @param {Integer} SQL LIMIT value. Useful when testing only.
 @returns {ARRAYRef of HASHRefs} List of borrowers HASHes with the extra key HasSelfServicePermission
 @dies On bad parameter

=cut

sub extract {
    my ($limit) = @_;
    if ($limit) {
        die "Given parameter \$limit='$limit' is not an integer" unless ($limit =~ m!^\d+$!); #SQL injection protection
    }
    my $dbh = C4::Context->dbh;
    my $borrowers = $dbh->selectall_arrayref("SELECT * FROM borrowers".($limit ? " LIMIT $limit" : ""), { Slice => {} }) or die $dbh->errstr;
    $logger->debug("Found '".scalar(@$borrowers)."' borrower rows");

    my $rules = C4::SelfService::GetRules();
    my $now = DateTime->now(time_zone => C4::Context->tz());

    for (my $i=0 ; $i<@$borrowers ; $i++) {
        $logger->debug("$i processed") if $i % 100 == 0;
        my $val;
        try {
            C4::SelfService::_HasSelfServicePermission( $borrowers->[$i], undef, 'blockList' );
            $val = 1;

            if ($rules->{BranchBlock}) {
                my $blocks = C4::SelfService::BlockManager::listBlocks($borrowers->[$i], $now);
                if (@$blocks) {
                    $borrowers->[$i]->{BranchSpecificBlocks} = $blocks;
                }
            }
        }
        catch {
            if (blessed($_) && $_->isa('Koha::Exception::SelfService')) {
                $logger->debug($_); #As we are making a batch run over all borrowers, don't unnecessarily warn over all possible issues.
                $val = 0;
            }
            else {
                $logger->logdie($_);
            }
        };
        $borrowers->[$i]->{HasSelfServicePermission} = $val;
        $borrowers->[$i]->{BranchSpecificBlocks} = undef unless ($borrowers->[$i]->{BranchSpecificBlocks});
    }
    return $borrowers;
}

=head2 export

Exports a list of borrowers to a temporary file using the defined export medium.
This file is intended to be deployed somewhere, as it is automatically removed after this program exits.

 @param {ARRAYRef of HASHes} List of borrowers
 @param {ARRAYRef} List of columns to pick for export. borrowernumber is automatically prepended, HasSelfServicePermission is automatically appended. 'BranchSpecificBlocks' is appended if needed.
 @param {String} Type to export, eg. 'csv'

=cut

sub export {
    my ($borrowers, $columns, $type) = (shift, shift || [], BlockListType->cast(shift));

    my $tempFile = File::Temp->new(SUFFIX => '.'.$type->{suffix}, UNLINK => 1); #croaks on error
    binmode($tempFile, ':encoding(UTF-8)');
    $tempFile->unlink_on_destroy(0); #Do not unlink when this object goes out of scope. Unlink only when the program closes.

    unshift(@$columns, 'borrowernumber');
    push(@$columns, 'HasSelfServicePermission');
    push(@$columns, 'BranchSpecificBlocks') if C4::SelfService::GetRules()->{BranchBlock};
    $logger->info("Exporting as '$type' to '$tempFile' picking columns '@$columns'");

    if ($type eq 'csv') {
        require Text::CSV_XS;

        $_->{BranchSpecificBlocks} = '['.join(':', sort(map {$_->{branchcode}} @{$_->{BranchSpecificBlocks}})).']' for @$borrowers; #Turn C4::SelfService::Block-objects to simple branchcode string representation.

        Text::CSV_XS::csv(binary => 1, encoding => 'UTF-8', eol => "\n", headers => $columns, in => $borrowers, out => $tempFile) or die Text::CSV_XS->error_diag;
    }
    elsif ($type eq 'yml') {
        require YAML::XS;
        @$borrowers = map { #Pick only the borrower columns requested
            {%$_{@$columns}}; #Oh I love Perl 5.20 and later. This is called a HASH slice
        } @$borrowers;

        print $tempFile YAML::XS::Dump($borrowers); #Outputs octets of UTF8
        $tempFile->flush() or die ("Flushing to file '$tempFile' failed: $!"); #Flush to disk, so there is something to access with system tools
    }
    elsif ($type eq 'mv-xml') { #Mikro-Väylä has a specific XML schema to abide to
        $tempFile = exportMVXML($borrowers, $tempFile, $type);
    }
    else {
        die "Unknown export type '$type'";
    }

    return $tempFile->filename;
}

=head2 exportMVXML

Exports a special schemaful XML for Mikro-Väylä self service / access control -devices
Refactored code from misc/cronjobs/mvssban.pl by the famous Pasi Korkalo

 @param {ARRAYref of HASHes} Borrowers to export
 @param {File::Temp} Temporary file to export to
 @param {String or BlockListType} 'mv-xml'
 @returns {File::Temp} the temporary file where the data was exported to

=cut

sub exportMVXML {
    my ($borrowers, $tempFile, $type) = (shift, shift, BlockListType->cast(shift));
    require XML::Parser;

    #Unsure if this is ever used with MV XML
    #Breaking this xml-schema from MV might break the current in-production functionality, because MV cannot receive the block lists due to schema validation issues. This needs to be discussed with MV if this is needed or desired to be made like this. Maybe a simple .yml or .csv is enough?
    #    <xs:element name="branch_blocks" type="xs:string" />
    #
    #$_->{BranchSpecificBlocks} = '['.join(':', sort(map {$_->{branchcode}} @{$_->{BranchSpecificBlocks}})).']' for @$borrowers; #Turn C4::SelfService::Block-objects to simple branchcode string representation.

    my @sb; #Using StringBuffer to reduce unnecessary String concatenation.
    # Initialize the XML blocklist
    push(@sb, << 'HEAD_END');
<?xml version="1.0" standalone="yes"?>
<NewDataSet>
  <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
    <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:MainDataTable="patronaccess" msdata:UseCurrentLocale="true">
      <xs:complexType>
        <xs:choice minOccurs="0" maxOccurs="unbounded">
          <xs:element name="patronaccess">
            <xs:complexType>
              <xs:sequence>
                <xs:element name="patronid_pac" type="xs:string" />
                <xs:element name="type_pac" type="xs:byte" minOccurs="0" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
        </xs:choice>
      </xs:complexType>
      <xs:unique name="Constraint1" msdata:PrimaryKey="true">
        <xs:selector xpath=".//patronaccess" />
        <xs:field xpath="patronid_pac" />
      </xs:unique>
    </xs:element>
  </xs:schema>
HEAD_END

    #MV BranchBlock-support could look like this.
    #push(@sb, "  <patronaccess>\n    <patronid_pac>" . $_->{borrowernumber} . "</patronid_pac>\n    <type_pac>" . $_->{HasSelfServicePermission} . "</type_pac>\n    <branch_blocks>" . $_->{BranchSpecificBlocks} . "</branch_blocks>\n  </patronaccess>\n")

    push(@sb, "  <patronaccess>\n    <patronid_pac>" . $_->{borrowernumber} . "</patronid_pac>\n    <type_pac>" . $_->{HasSelfServicePermission} . "</type_pac>\n  </patronaccess>\n")
        for @$borrowers;

    push(@sb, "</NewDataSet>\n");

    my $xml = join("\n", @sb);

    unless(XML::Parser->new->parse($xml)) {
        $logger->fatal("The XML is not valid, will not write a targetfile."); #If exporting the bad xml crashes, atleast there is some hint about what went wrong.
        my $crashFile = File::Temp->new(SUFFIX => ".invalid.$type", UNLINK => 0); #This temporary file wont be deleted after this process exits.
        binmode($crashFile, ':utf8'); #Avoid enforcing UTF-8 strictness here, otherwise crash recovery can crash on bad UTF-8
        print $crashFile $xml;
        $logger->logdie("Dumped bad XML for inspection to '$crashFile'.");
    }

    print $tempFile $xml;
    $tempFile->flush() or die ("Flushing to file '$tempFile' failed: $!");
    $logger->info("New blocklist written to '$tempFile'");

    return $tempFile;
}

=head2 deploy

Deploy the source file as the destination file.
Set file permissions.

 @param {String} File path of the source file to copy
 @param {String} File path of the destination file to copy to
 @param {String} New file permissions in the form:
                 0644 # for owner read+write, group/other read-only
                 Defaults to 0644

=cut

sub deploy {
    my ($sourceFile, $destinationFile, $mode) = (shift, shift, shift || '0644');
    $logger->info("Deploying from '$sourceFile' to '$destinationFile'");

    File::Copy::move($sourceFile, $destinationFile) or die "Copying file '$sourceFile' to '$destinationFile' failed: $!";

    $mode = oct($mode.""); #Make sure the $mode is an octal number
    chmod($mode, $destinationFile) or die "Changing file '$destinationFile' permissions failed: $!";
}

package BlockListType {

=head1 NAME

BlockListType - Simple config object for the block list type

=cut

use fields qw(fileName type suffix);
use overload fallback => 1,
             '""' => sub { return shift->{type} };

sub cast {
    my ($class, $type) = @_;
    return $type if (ref($type) eq 'BlockListType');
    return $class->new($type);
}
sub new {
    my ($class, $type) = @_;
    my $self = bless({}, $class);
    @$self{'type', 'suffix'} = ($type eq 'csv' || $type eq 'yml') ? ($type, $type) :
                               ($type eq 'mv-xml')                ? ($type, 'xml') :
                               $logger->logdie("Unsupported type '$type'");
    return $self;
}

};

1;
