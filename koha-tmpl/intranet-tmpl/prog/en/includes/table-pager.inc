<div class="pager"><form class="formpager" action=""><label>Page(s):
	<img src="[% interface %]/prog/img/first.png" alt="" class="first"/>
	<img src="[% interface %]/prog/img/prev.png" alt="" class="prev"/>
	<input type="text" size="5" class="pagedisplay"/></label>
	<img src="[% interface %]/prog/img/next.png" alt="" class="next"/>
	<img src="[% interface %]/prog/img/last.png" alt="" class="last"/>
	<label>Entries/page:
	<select class="pagesize">
	[% IF ( perpage == 10) %]<option value="10" selected="selected">10</option>[% ELSE %]<option value="10">10</option>[% END %]
	[% IF ( perpage == 20) %]<option value="20" selected="selected">20</option>[% ELSE %]<option value="20">20</option>[% END %]
	[% IF ( perpage == 30) %]<option value="30" selected="selected">30</option>[% ELSE %]<option value="30">30</option>[% END %]
	[% IF ( perpage == 40) %]<option value="40" selected="selected">40</option>[% ELSE %]<option value="40">40</option>[% END %]
	[% IF ( perpage == 50) %]<option value="50" selected="selected">50</option>[% ELSE %]<option value="50">50</option>[% END %]
	[% IF ( perpage == 100) %]<option value="100" selected="selected">100</option>[% ELSE %]<option value="100">100</option>[% END %]
	[% IF ( perpage == 200) %]<option value="200" selected="selected">200</option>[% ELSE %]<option value="200">200</option>[% END %]
	</select></label>
</form></div>