#!/usr/bin/perl
#
# Copyright 2014 Catalyst IT
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

use Test::More tests => 2;

use Koha::Exceptions;
use Mojo::Exception;
use DBIx::Class::Exception;

subtest 'rethrow_exception() tests' => sub {
    plan tests => 4;

    my $e = Koha::Exceptions::Exception->new(
        error => 'houston, we have a problem'
    );
    eval { Koha::Exceptions::rethrow_exception($e) };
    is(ref($@), 'Koha::Exceptions::Exception', ref($@));

    eval { DBIx::Class::Exception->throw('dang') };
    $e = $@;
    eval { Koha::Exceptions::rethrow_exception($e) };
    is(ref($@), 'DBIx::Class::Exception', ref($@));

    eval { Mojo::Exception->throw('dang') };
    $e = $@;
    eval { Koha::Exceptions::rethrow_exception($e) };
    is(ref($@), 'Mojo::Exception', ref($@));

    eval { die "wow" };
    $e = $@;
    eval { Koha::Exceptions::rethrow_exception($e) };
    like($@, qr/^wow at .*Exceptions.t line \d+\.$/, $@);
};

subtest 'to_str() tests' => sub {
    plan tests => 4;

    my $text;
    eval { Koha::Exceptions::Exception->throw(error => 'dang') };
    is($text = Koha::Exceptions::to_str($@),
       'Koha::Exceptions::Exception => dang', $text);
    eval { DBIx::Class::Exception->throw('dang') };
    like($text = Koha::Exceptions::to_str($@),
       qr/DBIx::Class::Exception => .*dang/, $text);
    eval { Mojo::Exception->throw('dang') };
    is($text = Koha::Exceptions::to_str($@),
       'Mojo::Exception => dang', $text);
    eval {
        my $exception = {
            what => 'test unknown exception',
            otherstuffs => 'whatever'
        };
        bless $exception, 'Unknown::Exception';
        die $exception;
    };
    is($text = Koha::Exceptions::to_str($@), 'Unknown::Exception => '
       .'{"otherstuffs":"whatever","what":"test unknown exception"}', $text);
};
