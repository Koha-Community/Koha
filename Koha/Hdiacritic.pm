use utf8;
use strict;
use Text::Unaccent 'unac_string';

sub hdiacritic {
  my $char;
  my $oldchar;
  my $retstring;

  foreach (split(//, $_[0])) {
    $char=$_;
    $oldchar=$char;

    unless ( $char =~/[A-Za-z0-9ÅåÄäÖöÉéÈèÌìÍíÓóÒòÔôÎîÇçÆæÏïÜüÐðØøÞþßÕõÑñÛûÂâÊêËëÃãÝýÀàÁáÂâÚúÙùÿ]/ ) {

      $char='Z'  if $char eq 'Ʒ';
      $char='z'  if $char eq 'ʒ';
      $char='Ð'  if $char eq 'Ɖ';
      $char='Ð'  if $char eq 'Đ'; # This is not the same as above, so don't remove either one!
      $char='\'' if $char eq 'ʻ';

      $char=unac_string('utf-8', $char) if "$oldchar" eq "$char";
    }
    $retstring=$retstring . $char;
  }

  return $retstring;
}

1;
