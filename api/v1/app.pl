#!/usr/bin/env perl

use Modern::Perl;

require Mojolicious::Commands;
Mojolicious::Commands->start_app('Koha::REST::V1');
