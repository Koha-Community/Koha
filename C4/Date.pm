#!/usr/bin/perl -w

package C4::Date;

use strict;
use C4::Context;
use Date::Manip;

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
             &display_date_format
             &format_date
             &format_date_in_iso
);


sub get_date_format
{
	#Get the database handle
	my $dbh = C4::Context->dbh;
	return C4::Context->preference('dateformat');
}

sub display_date_format
{
	my $dateformat = get_date_format();
	
	if ( $dateformat eq "us" )
	{
		return "mm/dd/yyyy";
	}
	elsif ( $dateformat eq "metric" )
	{
		return "dd/mm/yyyy";
	}
	elsif ( $dateformat eq "iso" )
	{
		return "yyyy-mm-dd";
	}
	else
	{
		return "Invalid date format: $dateformat. Please change in system preferences";
	}
}


sub format_date
{
	my $olddate = shift;
	my $newdate;

	my $dateformat = get_date_format();
	
	if ( $dateformat eq "us" )
	{
		Date_Init("DateFormat=US");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%m/%d/%Y');
	}
	elsif ( $dateformat eq "metric" )
	{
		Date_Init("DateFormat=metric");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%d/%m/%Y');
	}
	elsif ( $dateformat eq "iso" )
	{
		Date_Init("DateFormat=iso");
		$olddate = ParseDate($olddate);
		$newdate = UnixDate($olddate,'%Y-%m-%d');
	}
	else
	{
		return "Invalid date format: $dateformat. Please change in system preferences";
	}
}

sub format_date_in_iso
{
        my $olddate = shift;
        my $newdate;
                
        my $dateformat = get_date_format();

        if ( $dateformat eq "us" )
        {
                Date_Init("DateFormat=US");
                $olddate = ParseDate($olddate);
        }
        elsif ( $dateformat eq "metric" )
        {
                Date_Init("DateFormat=metric");
                $olddate = ParseDate($olddate);
        }
        elsif ( $dateformat eq "iso" )
        {
                Date_Init("DateFormat=iso");
                $olddate = ParseDate($olddate);
        }
        else
        {
                return "9999-99-99";
        }

	$newdate = UnixDate($olddate, '%Y-%m-%d');

	return $newdate;
}
1;
