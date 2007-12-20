
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl"><!-- TMPL_VAR NAME="LibraryName" --></a></h1><!-- Begin Acquisitions Resident Search Box -->
<div id="header_search">
<div id="supplier_search" class="residentsearch">
	<p class="tip">Search suppliers:</p>
        <form name="findsupplier" action="/cgi-bin/koha/acqui/booksellers.pl" method="post">
           <input type="text" size="25" name="supplier" id="supplier" class="focus" />
            <input type="submit" value="Search" /></form>
</div>
	<div id="orders_search" class="residentsearch">
	<p class="tip">Search orders:</p>
	
		<form action="/cgi-bin/koha/acqui/histsearch.pl" method="post">
		<label for="title">Title: </label><input type="text" id="title" name="title" size="15" value="<!-- TMPL_VAR name="title"-->" /> <label for="searchsupplier">Supplier:</label> <input type="text" id="searchsupplier" name="name" size="15" value="<!-- TMPL_VAR name="name" -->" />
	<input value="Submit" class="submit" type="submit" /> <a href="/cgi-bin/koha/acqui/histsearch.pl">Advanced Search</a>
	</form>
	</div>	
			<ul>
			<li><a href="/cgi-bin/koha/acqui/booksellers.pl#supplier_search">Supplier Search</a></li>
			<li><a href="/cgi-bin/koha/acqui/histsearch.pl#orders_search">Orders Search</a></li>
			</ul>	
</div>
<!-- End Acquisitions Resident Search Box -->
