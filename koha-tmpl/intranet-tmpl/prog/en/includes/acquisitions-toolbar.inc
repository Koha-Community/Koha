<div id="toolbar">
	<ul class="toolbar">
		<li><a href="/cgi-bin/koha/acqui/supplier.pl?op=enter">New Supplier</a></li>
		<!-- TMPL_IF NAME="id" -->
		<li><a href="/cgi-bin/koha/acqui/basket.pl?supplierid=<!-- TMPL_VAR NAME="id" -->">New Order</a></li>
		<li><a href="/cgi-bin/koha/acqui/supplier.pl?supplierid=<!--TMPL_VAR Name="id"-->&amp;op=enter">Edit Supplier</a></li>
		<li><a href="/cgi-bin/koha/acqui/booksellers.pl?supplier=<!--TMPL_VAR Name="id"-->">Manage Orders</a></li>
		<li><a href="/cgi-bin/koha/acqui/parcels.pl?supplierid=<!--TMPL_VAR Name="id"-->">Receive Parcel</a></li>
		<!-- /TMPL_IF -->
	</ul>
<br clear="all" />
</div>