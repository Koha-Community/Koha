[% IF ( dateformat == "us" ) %](MM/DD/YYYY)[% ELSIF ( dateformat == "metric" ) %](DD/MM/YYYY)[% ELSIF ( dateformat == "dmydot" ) %](DD.MM.YYYY)[% ELSE %](YYYY-MM-DD)[% END %]
