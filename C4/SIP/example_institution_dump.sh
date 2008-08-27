#!/bin/bash

perl -I ./ -e 'use Data::Dumper; use ILS; use Sip::Configuration; $conf=Sip::Configuration->new("SIPconfig.xml");  print Dumper($conf->{institutions}->{"MAIN"}),"\n";'
