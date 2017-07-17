package t::lib::Page;

# Copyright 2015 Open Source Freedom Fighters
#
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

use Modern::Perl;
use Test::More;

use C4::Context;

use t::lib::WebDriverFactory;

use Koha::Exception::BadParameter;
use Koha::Exception::SystemCall;

=head NAME t::lib::Page

=head SYNOPSIS

PageObject-pattern parent class. Extend this to implement specific pages shown to our users.

PageObjects are used to make robust and reusable integration test components to test
various front-end features. PageObjects load a Selenium::Remote::Driver implementation,
phantomjs by default and use this to do scripted user actions in the browser,
eg. clicking HTML-elements, accepting popup dialogs, entering text to input fields.

PageObjects encapsulate those very low-level operations into clear and easily usable
actions or services, like doPasswordLogin().
PageObjects also seamlessly deal with navigation from one page to another, eg.
    my $mainpage = t::lib::Page::Mainpage->new();
    $mainpage->doPasswordLogin('admin', '1234')->gotoPatrons()->
               searchPatrons({keywordSearch => "Jane Doe"});

=head Class variables

Selenium::Remote::Driver driver, contains the driver implementation used to run these tests
t::Page::Common::Header  header, the header page component (not implemented)
t::Page::Common::Footer  footer, the footer page component (not implemented)
Scalar                   userInteractionDelay, How many milliseconds to wait for javascript
                                               to stop processing by default after user actions?

=head DEBUGGING

Set Environment value
    $ENV{KOHA_PAGEOBJECT_DEBUG} = 1;
Before creating the first PageObject to enable debugging.
Debugging output is written to /tmp/PageObjectDebug/ by default, but you can change it
using the same environment variable
    $ENV{KOHA_PAGEOBJECT_DEBUG} = "/tmp/generalDebugging/";

=cut

sub new {
    my ($class, $params) = @_;
    $params = _mergeDefaultConfig($params);

    my $self = {};
    bless($self, $class);
    unless ($params->{driver}) {
        my ($driver) = t::lib::WebDriverFactory::getUserAgentDrivers({phantomjs => $params});
        $self->{driver} = $driver;
    }
    $self->{type}     = $params->{type}; #This parameter is mandatory. _mergeDefaultConfig() dies without it.
    $self->{resource} = $params->{resource} || '/';
    $self->{resource} .= "?".join('&', @{$params->{getParams}}) if $params->{getParams};
    $self->{header}   = $params->{header}   || undef;
    $self->{footer}   = $params->{footer}   || undef;

    $self->{userInteractionDelay} = $params->{userInteractionDelay} || 500;

    $self->{driver}->set_window_size(1280, 960);
    $self->{driver}->get( $self->{resource} );

    $self->debugSetEnvironment(); #If debugging is enabled

    return $self;
}

=head rebrandFromPageObject
When we are getting redirected from one page to another we rebrand the existing PageObject
as another PageObject to have the new page's services available.

@RETURNS The desired new PageObject Page
=cut

sub rebrandFromPageObject {
    my ($class, $self) = @_;
    bless($self, $class);
    my $d = $self->getDriver();
    $d->pause(250); #Wait for javascript to load.
    $self->debugTakeSessionSnapshot();
    ok(1, "Navigated to $class");
    return $self;
}

=head _mergeDefaultConfig

@THROWS Koha::Exception::BadParameter
=cut

sub _mergeDefaultConfig {
    my ($params) = @_;
    unless (ref($params) eq 'HASH' && $params->{type}) {
        Koha::Exception::BadParameter->throw(error => "t::lib::Page:> When instantiating Page-objects, you must define the 'type'-parameter.");
    }

    my $testServerConfigs = C4::Context->config('testservers');
    my $conf = $testServerConfigs->{ $params->{type} };
    Koha::Exception::BadParameter->throw(error => "t::lib::Page:> Unknown 'type'-parameter '".$params->{type}."'. Values 'opac', 'staff' and 'rest' are supported.")
                unless $conf;

    unless ($conf->{base_url} =~ /:\/\//) {
        warn 't::lib::Page:> Missing protocol definition at '.
            "KOHA_CONF.testservers.$params->{type}.base_url";
    }

    #Merge given $params-config on top of the $KOHA_CONF's testservers-directives
    @$conf{keys %$params} = values %$params;
    return $conf;
}

=head quit
Wrapper for Selenium::Remote::Driver->quit(),
Delete the session & close open browsers.

When ending this browser session, it is polite to quit, or there is a risk of leaving
floating test browsers floating around.
=cut

sub quit {
    my ($self) = @_;
    $self->getDriver()->quit();
}

=head pause
Wrapper for Selenium::Remote::Driver->pause(),
=cut

sub pause {
    my ($self, $pauseMillis) = @_;
    $self->getDriver()->pause($pauseMillis);
    return $self;
}

=head
Wrapper for Selenium::Remote::Driver->refresh()
=cut

sub refresh {
    my ($self) = @_;
    $self->getDriver()->refresh();
    $self->debugTakeSessionSnapshot();
    return $self;
}

=head poll
Polls anonymous subroutine $func at given rate $pauseMillis for given times $polls or
until $func succeeds without exceptions.

In case of an exception, optional anonymous subroutine $success is called to confirm
whether or not the action was successful. If this subroutine is not defined or it returns
false, polling continues.

Default pause for polling is 50ms and the polling runs by default for 20 times.

@PARAM1 $func                  Anonymous subroutine to be polled
@PARAM2 $success      OPTIONAL Success function to check if action was successful
@PARAM3 $polls        OPTIONAL Defines the times polling will be ran
@PARAM4 $pauseMillis  OPTIONAL Defines the wait between two polls

@RETURNS 1 if polling was success, otherwise die
=cut

sub poll {
    my ($self, $func, $success, $polls, $pauseMillis) = @_;

    # initialize default values if not given
    $polls = 20 unless defined $polls;
    $pauseMillis = 50 unless defined $pauseMillis;

    for (my $i = 0; $i < $polls; $i++){
        eval {
            &$func();
        };
        if ($@) {
            return 1 if defined $success and &$success();
            $self->getDriver()->pause($pauseMillis);
            next;
        }
        return 1 unless $@; # if no errors, return true
    }
    die $@;
}

=head mockConfirmPopup

Workaround to a missing feature in PhantomJS v1.9
Confirm popup's cannot be negotiated with. This preparatory method makes confirm dialogs
always return 'true' or 'false' without showing the actual dialog.

@PARAM1 Boolean, the confirm popup dialog's return value.

=cut

sub mockConfirmPopup {
    my ($self, $retVal) = @_;
    my $d = $self->getDriver();

    my $script = q{
        var retVal = (arguments[0] == 1) ? true : false;
        var callback = arguments[arguments.length-1];
        window.confirm = function(){return retVal;};
        callback();
    };
    $d->execute_async_script($script, ($retVal ? 1 : 0));
}

=head mockPromptPopup

Workaround to a missing feature in PhantomJS v1.9
Prompt popup's cannot be negotiated with. This preparatory method makes prompt dialogs
always return 'true' or 'false' without showing the actual dialog.

@PARAM1 Boolean, the prompt popup dialog's return value.

=cut

sub mockPromptPopup {
    my ($self, $retVal) = @_;
    my $d = $self->getDriver();

    my $script = q{
        var callback = arguments[arguments.length-1];
        window.prompt = function(){return arguments[0];};
        callback();
    };
    $d->execute_async_script($script, ($retVal ? 1 : 0));
}

=head mockAlertPopup

Workaround to a missing feature in PhantomJS v1.9
Alert popup's cannot be negotiated with and they freeze PageObject testing.
This preparatory method makes alert dialogs always return NULL without showing
the actual dialog.

=cut

sub mockAlertPopup {
    my ($self, $retVal) = @_;
    my $d = $self->getDriver();

    my $script = q{
        var callback = arguments[arguments.length-1];
        window.alert = function(){return;};
        callback();
    };
    $d->execute_async_script($script);
}

################################################
  ##  INTRODUCING OBJECT ACCESSORS  ##
################################################
sub setDriver {
    my ($self, $driver) = @_;
    $self->{driver} = $driver;
}
sub getDriver {
    my ($self) = @_;
    return $self->{driver};
}

################################################
  ##  INTRODUCING TESTING HELPERS  ##
################################################
sub debugSetEnvironment {
    my ($self) = @_;
    if ($ENV{KOHA_PAGEOBJECT_DEBUG}) {
        $self->{debugSessionId} = sprintf("%03i",rand(999));
        $self->{debugSessionTmpDirectory} = "/tmp/PageObjectDebug/";
        $self->{debugSessionTmpDirectory} = $ENV{KOHA_PAGEOBJECT_DEBUG} if (not(ref($ENV{KOHA_PAGEOBJECT_DEBUG})) && length($ENV{KOHA_PAGEOBJECT_DEBUG}) > 1);
        my $error = system(("mkdir", "-p", $self->{debugSessionTmpDirectory}));
        Koha::Exception::SystemCall->throw(error => "Trying to create a temporary directory for PageObject debugging session '".$self->{debugSessionId}."' failed:\n  $?")
                if $error;
        $self->{debugInternalCounter} = 1;

        print "\n\n--Starting PageObject debugging session '".$self->{debugSessionId}."'\n\n";
    }
}

sub debugTakeSessionSnapshot {
    my ($self) = @_;
    if ($ENV{KOHA_PAGEOBJECT_DEBUG}) {
        my ($actionIdentifier, $actionFile) = $self->_debugGetSessionIdentifier(2);

        $self->_debugWriteHTML($actionIdentifier, $actionFile);
        $self->_debugWriteScreenshot($actionIdentifier, $actionFile);
        $self->{debugInternalCounter}++;
    }
}

sub _debugGetSessionIdentifier {
    my ($self, $callerDepth) = @_;
    $callerDepth = $callerDepth || 2;
    ##Create a unique and descriptive identifier for this program state.
    my ($package, $filename, $line, $subroutine) = caller($callerDepth); #Get where we are called from
    $subroutine = $2 if ($subroutine =~ /(::|->)([^:->]+)$/); #Get the last part of the package, the subroutine name.
    my $actionIdentifier = "[session '".$self->{debugSessionId}."', counter '".sprintf("%03i",$self->{debugInternalCounter})."', caller '$subroutine']";
    my $actionFile = $self->{debugSessionId}.'_'.sprintf("%03i",$self->{debugInternalCounter}).'_'.$subroutine;
    return ($actionIdentifier, $actionFile);
}

sub _debugWriteHTML {
    require Data::Dumper;
    my ($self, $actionIdentifier, $actionFile) = @_;
    my $d = $self->getDriver();

    ##Write the current Response data
    open(my $fh, ">:encoding(UTF-8)", $self->{debugSessionTmpDirectory}.$actionFile.'.html')
                or die "Trying to open a filehandle for PageObject debugging output $actionIdentifier:\n  $@";
    print $fh $d->get_title()."\n";
    print $fh "ALL COOKIES DUMP:\n".Data::Dumper::Dumper($d->get_all_cookies());
    print $fh $d->get_page_source()."\n";
    close $fh;
}

sub _debugWriteScreenshot {
    my ($self, $actionIdentifier, $actionFile) = @_;
    my $d = $self->getDriver();

    ##Write a screenshot of the view to file.
    my $ok = $d->capture_screenshot($self->{debugSessionTmpDirectory}.$actionFile.'.png');
    Koha::Exception::SystemCall->throw(error => "Cannot capture a screenshot for PageObject $actionIdentifier")
                unless $ok;
}
1; #Make the compiler happy!
