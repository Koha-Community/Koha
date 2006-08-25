# UTF8DBI.pm re-implementation by Pavel Kudinov http://search.cpan.org/~kudinov/
# originally from: http://dysphoria.net/code/perl-utf8/

package UTF8DBI    ; use base DBI    ;
package UTF8DBI::db; use base DBI::db;
package UTF8DBI::st; use base DBI::st;

sub _utf8_() {
	use Encode;
	if    (ref $_ eq 'ARRAY'){ _utf8_() foreach        @$_  }
	elsif (ref $_ eq 'HASH' ){ _utf8_() foreach values %$_  }
	else                     {         Encode::_utf8_on($_) };
	$_;
};

sub fetch             { return _utf8_ for shift->SUPER::fetch            (@_)  };
sub fetchrow_arrayref { return _utf8_ for shift->SUPER::fetchrow_arrayref(@_)  };
sub fetchrow_hashref  { return _utf8_ for shift->SUPER::fetchrow_hashref (@_)  };
sub fetchall_arrayref { return _utf8_ for shift->SUPER::fetchall_arrayref(@_)  };
sub fetchall_hashref  { return _utf8_ for shift->SUPER::fetchall_hashref (@_)  };
sub fetchcol_arrayref { return _utf8_ for shift->SUPER::fetchcol_arrayref(@_)  };

sub fetchrow_array    {                 @{shift->       fetchrow_arrayref(@_)} };

1;
