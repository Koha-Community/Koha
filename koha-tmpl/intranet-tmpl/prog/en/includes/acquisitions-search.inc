<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName | html %]</a></h1><!-- Begin Acquisitions Resident Search Box -->
<div id="header_search">
<div id="supplier_search" class="residentsearch">
	<p class="tip">Search vendors:</p>
        <form name="findsupplier" action="/cgi-bin/koha/acqui/booksellers.pl" method="post">
           <input type="text" size="25" name="supplier" id="supplier" class="focus" />
            <input type="submit" class="submit" value="Submit" /></form>
</div>
    <div id="orders_search" class="residentsearch">
	<p class="tip">Search orders:</p>
	
		<form action="/cgi-bin/koha/acqui/histsearch.pl" method="post">
        <label for="title">Title: </label> <input type="text" id="title" name="title" size="15" value="[% title | html %]" />
        <label for="searchsupplier">Vendor:</label> <input type="text" id="searchsupplier" name="name" size="15" value="[% name | html %]" />
        <input type="hidden" id="do_search" name="do_search" value="do" />
        <span class="filteraction" id="filteraction_off" style="display:none"> <a href="#" class="toggle_element" data-element="#filters,.filteraction">[-]</a></span>
        <span class="filteraction" id="filteraction_on"> <a href="#" class="toggle_element" data-element="#filters,.filteraction">[+]</a></span>
    <input value="Submit" class="submit" type="submit" /> <a href="/cgi-bin/koha/acqui/histsearch.pl">Advanced search</a>
    <p id="filters" style="display:none">
      <label for="basket">Basket: </label><input type="text" name="basket" id="basket" />
      <label for="booksellerinvoicenumber">Invoice no.: </label><input type="text" name="booksellerinvoicenumber" id="booksellerinvoicenumber" />
    </p>
	</form>
	</div>	
			<ul id="tabtriggers">
            <li><a href="#supplier_search">Vendor search</a></li>
            <li><a href="#orders_search">Orders search</a></li>
			</ul>	
</div><!-- /header_search -->
</div><!-- /gradient -->
<!-- End Acquisitions Resident Search Box -->
