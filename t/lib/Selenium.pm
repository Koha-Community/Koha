package t::lib::Selenium;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Carp qw( croak );

use C4::Context;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(login password base_url opac_base_url selenium_addr selenium_port driver));

sub capture {
    my ( $class, $driver ) = @_;

    $driver->capture_screenshot('selenium_failure.png');

}

sub new {
    my ( $class, $params ) = @_;
    my $self   = {};
    my $config = $class->config;
    $self->{login}         = $params->{login}         || $config->{login};
    $self->{password}      = $params->{password}      || $config->{password};
    $self->{base_url}      = $params->{base_url}      || $config->{base_url};
    $self->{opac_base_url} = $params->{opac_base_url} || $config->{opac_base_url};
    $self->{selenium_addr} = $params->{selenium_addr} || $config->{selenium_addr};
    $self->{selenium_port} = $params->{selenium_port} || $config->{selenium_port};
    $self->{driver}        = Selenium::Remote::Driver->new(
        port               => $self->{selenium_port},
        remote_server_addr => $self->{selenium_addr},
    );
    bless $self, $class;
    $self->add_error_handler;
    $self->driver->set_implicit_wait_timeout(10000);
    return $self;
}

sub add_error_handler {
    my ($self) = @_;
    $self->{driver}->error_handler(
        sub {
            my ( $driver, $selenium_error ) = @_;
            print STDERR "\nSTRACE:";
            my $i = 1;
            while ( ( my @call_details = ( caller( $i++ ) ) ) ) {
                print STDERR "\t" . $call_details[1] . ":" . $call_details[2] . " in " . $call_details[3] . "\n";
            }
            print STDERR "\n";
            $self->capture($driver);
            $driver->quit();
            croak $selenium_error;
        }
    );
}

sub remove_error_handler {
    my ($self) = @_;
    $self->{driver}->error_handler( sub { } );
}

sub config {
    return {
        login    => $ENV{KOHA_USER} || 'koha',
        password => $ENV{KOHA_PASS} || 'koha',
        base_url => ( $ENV{KOHA_INTRANET_URL} || C4::Context->preference("staffClientBaseURL") ) . "/cgi-bin/koha/",
        opac_base_url => ( $ENV{KOHA_OPAC_URL} || C4::Context->preference("OPACBaseURL") ) . "/cgi-bin/koha/",
        selenium_addr => $ENV{SELENIUM_ADDR} || 'localhost',
        selenium_port => $ENV{SELENIUM_PORT} || 4444,
    };
}

sub auth {
    my ( $self, $login, $password ) = @_;

    $login    ||= $self->login;
    $password ||= $self->password;
    my $mainpage = $self->base_url . 'mainpage.pl';

    $self->driver->get($mainpage);
    $self->fill_form( { userid => $login, password => $password } );
    my $login_button = $self->driver->find_element('//input[@id="submit-button"]');
    $login_button->click();
}

sub opac_auth {
    my ( $self, $login, $password ) = @_;

    $login    ||= $self->login;
    $password ||= $self->password;
    my $mainpage = $self->opac_base_url . 'opac-main.pl';

    $self->driver->get( $mainpage . q|?logout.x=1| );    # Logout before, to make sure we will see the login form
    $self->driver->get($mainpage);
    $self->fill_form( { userid => $login, password => $password } );
    $self->submit_form;
}

sub fill_form {
    my ( $self, $values ) = @_;
    while ( my ( $id, $value ) = each %$values ) {
        my $attr       = 'id';
        my $attr_value = $id;
        if ( $id =~ m{=} ) {
            ( $attr, $attr_value ) = split '=', $id;
        }
        my $element = $self->driver->find_element( sprintf '//*[@%s="%s"]', $attr, $attr_value );
        my $tag     = $element->get_tag_name();
        if ( $tag eq 'input' ) {
            $self->driver->find_element( sprintf '//input[@%s="%s"]', $attr, $attr_value )->send_keys($value);
        } elsif ( $tag eq 'select' ) {
            $self->driver->find_element( sprintf '//select[@%s="%s"]//option[@value="%s"]', $attr, $attr_value, $value )
                ->click;
        }
    }
}

sub submit_form {
    my ($self) = @_;

    # If there is only one submit element on the page we use it
    my @submit_elements = $self->driver->find_elements('//input[@type="submit"]');
    if ( @submit_elements == 1 ) {
        $self->click_when_visible('//input[@type="submit"]');
        return;
    }

    my $default_submit_selector = '//fieldset[@class="action"]/input[@type="submit"]';
    my @elts                    = map { my $size = $_->get_size; ( $size->{height} && $size->{width} ) ? $_ : () }
        $self->driver->find_elements($default_submit_selector);

    die "Too many forms are displayed. Cannot submit." if @elts > 1;

    return $elts[0]->click;
}

sub click {
    my ( $self, $params ) = @_;
    my $xpath_selector;
    if ( exists $params->{main} ) {
        $xpath_selector = '//div[@id="' . $params->{main} . '"]';
    } elsif ( exists $params->{main_class} ) {
        $xpath_selector = '//div[@class="' . $params->{main_class} . '"]';
    }
    if ( exists $params->{href} ) {
        if ( ref( $params->{href} ) ) {
            for my $k ( keys %{ $params->{href} } ) {
                if ( $k eq 'ends-with' ) {

                    # ends-with version for xpath version 1
                    my $ends_with = $params->{href}{"ends-with"};
                    $xpath_selector .=
                          '//a[substring(@href, string-length(@href) - string-length("'
                        . $ends_with
                        . '") + 1 ) = "'
                        . $ends_with . '"]';

                    # ends-with version for xpath version 2
                    #$xpath_selector .= '//a[ends-with(@href, "'.$ends_with.'") ]';

                } else {
                    die "Only ends-with is supported so far ($k)";
                }
            }
        } else {
            $xpath_selector .= '//a[contains(@href, "' . $params->{href} . '")]';
        }
    }
    if ( exists $params->{id} ) {
        $xpath_selector .= '//*[@id="' . $params->{id} . '"]';
    }
    $self->driver->find_element($xpath_selector)->click;
}

sub wait_for_element_visible {
    my ( $self, $xpath_selector ) = @_;

    my ( $visible, $elt );
    $self->remove_error_handler;
    my $max_retries = $self->max_retries;
    my $i;
    while ( not $visible ) {
        $elt     = eval { $self->driver->find_element($xpath_selector) };
        $visible = $elt && $elt->is_displayed;
        $self->driver->pause(1000) unless $visible;

        die "Cannot wait more for element '$xpath_selector' to be visible"
            if $max_retries <= ++$i;
    }
    $self->add_error_handler;
    return $elt;
}

sub wait_for_element_hidden {
    my ( $self, $xpath_selector ) = @_;

    my ( $hidden, $elt );
    $self->remove_error_handler;
    my $max_retries = $self->max_retries;
    my $i;
    while ( not $hidden ) {
        $elt    = eval { $self->driver->find_element($xpath_selector) };
        $hidden = $elt || !$elt->is_displayed;
        $self->driver->pause(1000) unless $hidden;

        $i++;
        $self->driver->capture_screenshot('selenium_hidden.png')
            if $max_retries <= $i;
        die "Cannot wait more for element '$xpath_selector' to be hidden"
            if $max_retries <= $i;
    }
    $self->add_error_handler;
    return $elt;
}

sub wait_for_ajax {
    my ($self) = @_;

    my $is_ready;
    my $max_retries = $self->max_retries;
    my $i;
    while ( not $is_ready ) {
        $is_ready = $self->driver->execute_script('return jQuery.active == 0');
        $self->driver->pause(1000) unless $is_ready;

        die "Cannot wait more for jQuery to be active (wait_for_ajax)"
            if $max_retries <= ++$i;
    }
}

sub get_next_alert_text {
    my ($self) = @_;

    my $alert_text;
    my $max_retries = $self->max_retries;
    my $i;
    $self->remove_error_handler;
    while ( not $alert_text ) {
        $alert_text = eval { $self->driver->get_alert_text };
        $self->driver->pause(1000) unless $alert_text;

        die "Cannot wait more for next alert (get_next_alert)"
            if $max_retries <= ++$i;
    }
    $self->add_error_handler;
    return $alert_text;
}

sub show_all_entries {
    my ( $self, $xpath_selector ) = @_;

    $self->driver->find_element( $xpath_selector . '//div[@class="dt-length"]/label/select/option[@value="-1"]' )
        ->click;
    my ( $all_displayed, $i );
    my $max_retries = $self->max_retries;
    while ( not $all_displayed ) {
        my $dt_infos = $self->driver->get_text( $xpath_selector . '//div[@class="dt-info"]' );

        if ( $dt_infos =~ m|Showing 1 to (\d+) of (\d+) entries| ) {
            $all_displayed = 1 if $1 == $2;
        }

        $self->driver->pause(1000) unless $all_displayed;

        die "Cannot show all entries from table $xpath_selector"
            if $max_retries <= ++$i;
    }
}

sub click_when_visible {
    my ( $self, $xpath_selector ) = @_;

    my $elt = $self->wait_for_element_visible($xpath_selector);

    my $clicked;
    $self->remove_error_handler;
    while ( not $clicked ) {
        eval { $self->driver->find_element($xpath_selector)->click };
        $clicked = !$@;
        $self->driver->pause(1000) unless $clicked;
    }
    $self->add_error_handler;
    $elt->click unless $clicked;    # finally Raise the error
}

sub max_retries { 10 }

=head1 NAME

t::lib::Selenium - Selenium helper module

=head1 SYNOPSIS

    my $s = t::lib::Selenium->new;
    my $driver = $s->driver;
    my $base_url = $s->base_url;
    $s->auth;
    $driver->get($s->base_url . 'mainpage.pl');
    $s->fill_form({ input_id => 'value' });

=head1 DESCRIPTION

The goal of this module is to group the different actions we need
when we use automation test using Selenium

=head1 METHODS

=head2 new

    my $s = t::lib::Selenium->new;

    Constructor - Returns the object Selenium
    You can pass login, password, base_url, selenium_addr, selenium_port
    If not passed, the environment variables will be used
    KOHA_USER, KOHA_PASS, KOHA_INTRANET_URL, SELENIUM_ADDR SELENIUM_PORT
    Or koha, koha, syspref staffClientBaseURL, localhost, 4444

=head2 auth

    $s->auth;

    Will login into Koha.

=head2 fill_form

    $driver->get($url)
    $s->fill_form({
        input_id => 'value',
        element_id => 'other_value',
    });

    Will fill the different elements of a form.
    The keys must be element ids (input and select are supported so far)
    The values must a string.

=head2 submit_form

    $s->submit_form;

    It will submit the form using the submit button present in in the fieldset with a clas="action".
    It should be the default way. If it does not work you should certainly fix the Koha interface.

=head2 click

    $s->click($xpath_selector);

    This is a bit dirty for now but will evolve depending on the needs
    3 parameters possible but only the following 2 forms are used:
    $s->click({ href => '/module/script.pl?foo=bar', main => 'doc3' }); # Sometimes we have doc or doc3. To make sure we are not going to hit a link in the header
    $s->click({ id => 'element_id });

=head2 wait_for_element_visible

    $s->wait_for_element_visible($xpath_selector)

    Wait 10s for an element to be visible

=head2 wait_for_element_hidden

    $s->wait_for_element_hidden($xpath_selector)

    Wait 10s for an element to be hidden

=head2 wait_for_ajax

    $s->wait_for_ajax;

    Wait 10s for all the current AJAX requests to be received.

=head2 get_next_alert_text

    $s->get_next_alert_text;

    Retrieve the next alert text.

=head2 show_all_entries

    $s->show_all_entries($xpath_selector);

    Select the "All" entries of the DataTables present in the selector.

=head2 click_when_visible

    $c->click_when_visible

    Should always be called to avoid the "An element could not be located on the page" error

=head2 capture
    $c->capture

Capture a screenshot and upload it using the excellent lut.im service provided by framasoft
The url of the image will be printed on STDERR (it should be better to return it instead)

=head2 add_error_handler
    $c->add_error_handler

Add our specific error handler to the driver.
It will displayed a trace as well as capture a screenshot of the current screen.
So only case you should need it is after you called remove_error_handler

=head2 remove_error_handler
    $c->remove_error_handler

Do *not* call this method if you are not aware of what it will do!
It will remove any kinds of error raised by the driver.
It can be useful in some cases, for instance if you want to make sure something will not happen and that could make the driver exploses otherwise.
You certainly should call it for only one statement then must call add_error_handler right after.

=head2 config

Missing POD for config.

=head2 opac_auth

Missing POD for opac_auth.

=head2 max_retries

Missing POD for max_retries.

=head1 AUTHORS

Jonathan Druart <jonathan.druart@bugs.koha-community.org>

Alex Buckley <alexbuckley@catalyst.net.nz>

Koha Development Team

=head1 COPYRIGHT

Copyright 2017 - Koha Development Team

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Koha; if not, see <https://www.gnu.org/licenses>.

=cut

1;
