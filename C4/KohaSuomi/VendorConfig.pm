package C4::KohaSuomi::VendorConfig;

# Copyright 2016 Vaara-kirjastot
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

use Koha::Logger;
use C4::Matcher;

use Koha::Exception::BadSystemPreference;

our $logger = Koha::Logger->get();

sub new {
    my ($class, $self) = _validateNew(@_);

    bless($self, $class);
    return $self;
}
sub _validateNew {
    my ($class, $remote) = @_;
    ##These are injected by C4::KohaSuomi::AcquisitionIntegration::getVendorConfig()
    my @mandatoryKeys = qw(configKey);
    ##These are defined in the syspref
    push(@mandatoryKeys, qw(host port username password protocol basedir encoding format fileRegexp stageFiles commitFiles matcher localStorageDir));
    foreach my $mkey (@mandatoryKeys) {
        unless (defined($remote->{$mkey})) {
            my @cc = caller(2);
            Koha::Exception::BadSystemPreference->throw(syspref => 'VaaraAcqVendorConfigurations',
                                                        error => $cc[3]."():> Missing mandatory parameter '$mkey' for vendorConfig '".($remote->{configKey} || '!NO configKey!')."' in syspref 'VaaraAcqVendorConfigurations'");
        }
    }
    $remote->{matcherCode} = $remote->{matcher};
    $remote->{matcher} = C4::Matcher->fetch(  C4::Matcher::GetMatcherId( $remote->{matcher} )  );
    unless (defined($remote->{matcher})) {
        my @cc = caller(2);
        Koha::Exception::BadSystemPreference->throw(syspref => 'VaaraAcqVendorConfigurations',
                                                    error => $cc[3]."():> No such Matcher '".$remote->{matcherCode}."' for vendorConfig '".$remote->{configKey}."' in syspref 'VaaraAcqVendorConfigurations'");
    }

    unless (length($remote->{localStorageDir}) > 0) {
        my @cc = caller(2);
        Koha::Exception::BadSystemPreference->throw(syspref => 'VaaraAcqVendorConfigurations',
                                                    error => $cc[3]."():> Mandatory parameter 'localStorageDir' '".$remote->{localStorageDir}."' is not a proper absolute path to the directory where the fetched files are stored.");
    }

    $logger->trace("Matcher '".$remote->{matcherCode}."':'".$remote->{matcher}->{id}."' instantiated") if $logger->is_trace();
    return @_;
}

sub host {
    return shift->{host};
}
sub port {
    return shift->{port};
}
sub username {
    return shift->{username};
}
sub password {
    return shift->{password};
}
sub protocol {
    return shift->{protocol};
}
sub basedir {
    return shift->{basedir};
}
sub encoding {
    return shift->{encoding};
}
sub format {
    return shift->{format};
}
sub fileRegexp {
    return shift->{fileRegexp};
}
sub stageFiles {
    return shift->{stageFiles};
}
sub commitFiles {
    return shift->{commitFiles};
}
sub matcher {
    return shift->{matcher};
}
sub localStorageDir {
    return shift->{localStorageDir};
}
sub configKey {
    return shift->{configKey};
}

1;
