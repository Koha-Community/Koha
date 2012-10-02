[% USE Koha %]
<div class="gradient">
<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Patrons Resident Search Box -->
<div id="header_search">
	<div id="patron_search" class="residentsearch">
	<p class="tip">Enter patron card number or partial name:</p>
	<form action="/cgi-bin/koha/members/member.pl" method="post">
    <input id="searchmember" size="25" class="focus" name="member" type="text" value="[% member %]"/>
	<span class="filteraction" id="filteraction_off"> <a href="#" onclick="$('#filters').toggle();$('.filteraction').toggle();">[-]</a></span>
	<span class="filteraction" id="filteraction_on"> <a href="#" onclick="$('#filters').toggle();$('.filteraction').toggle();">[+]</a></span>

    <input value="Search" class="submit" type="submit" />

  <div id="filters">
      <p><label for="searchfields">Search fields:</label>
            <select name="searchfields" id="searchfields">
                <option selected="selected" value=''>Standard</option>
                <option value='email,emailpro,B_email,'>Email</option>
                <option value='borrowernumber'>Borrower number</option>
                <option value='phone,phonepro,B_phone,altcontactphone,mobile'>Phone number</option>
                <option value='streettype,address,address2,city,state,zipcode,country'>Street Address</option>
                <option value='dateofbirth'>Date of birth</option>
            </select>
            <script type="text/javascript">
                [% SET dateformat = Koha.Preference('dateformat') %]
                $("#searchfields").change(function() {
                    if ( $(this).val() == 'dateofbirth' ) {
                        [% IF dateformat == 'us' %]
                            [% SET format = 'MM/DD/YYYY' %]
                        [% ELSIF dateformat == 'iso' %]
                            [% SET format = 'YYYY-MM-DD' %]
                        [% ELSIF dateformat == 'metric' %]
                            [% SET format = 'DD/MM/YYYY' %]
                        [% END %]

                        $('#searchmember').qtip({
                            content: 'Dates of birth should be entered in the format "[% format %]"',
                            style: {
                                tip: 'topLeft'
                            }
                        })
                    } else {
                        $('#searchmember').qtip('destroy');
                    }
                });
            </script>
        </p>
        <p><label for="searchtype">Search type:</label>
                <select name="searchtype" id="searchtype">
                    <option selected="selected" value=''>Starts with</option>
                    <option value='contain'>Contains</option>
                </select></p>

      <p><label for="searchorderby">Order by:</label>
            <select name="orderby" id="searchorderby">
            <option value="">Surname, Firstname</option>
            <option value="cardnumber,0">Cardnumber</option>
            </select></p>
        [% IF ( branchloop ) %] <p><label for="branchcode">Library: </label><select name="branchcode" id="branchcode">
                <option value="">Any</option>[% FOREACH branchloo IN branchloop %]
                [% IF ( branchloo.selected ) %]
                <option value="[% branchloo.value %]" selected="selected">[% branchloo.branchname %]</option>[% ELSE %]
                <option value="[% branchloo.value %]">[% branchloo.branchname %]</option>[% END %]
              [% END %]</select></p>
      [% END %]
      [% IF ( categories ) %]
        <p><label for="categorycode">Category: </label><select name="categorycode" id="categorycode">
                <option value="">Any</option>[% FOREACH categorie IN categories %]
                [% IF ( categorie.selected ) %]
                <option value="[% categorie.categorycode %]" selected="selected">[% categorie.description %]</option>[% ELSE %]
                <option value="[% categorie.categorycode %]">[% categorie.description %]</option>[% END %]
                [% END %]</select></p>
      [% END %]
  </div>
</form>
	</div>

    [% INCLUDE 'patron-search-box.inc' %]

	[% IF ( CAN_user_catalogue ) %]
    <div id="catalog_search" class="residentsearch">
	<p class="tip">Enter search keywords:</p>
		<form action="/cgi-bin/koha/catalogue/search.pl"  method="get" id="cat-search-block">
			 <input type="text" name="q" id="search-form" size="40" value="" title="Enter the terms you wish to search for." class="form-text" />
				<input type="submit" name="op" id="opac-submit" value="Submit" class="submit" />
		</form>
	</div>[% END %]
    [% IF ( CAN_user_circulate ) %]
    <div id="checkin_search" class="residentsearch">
    <p class="tip">Scan a barcode to check in:</p>
    <form method="post" action="/cgi-bin/koha/circ/returns.pl" autocomplete="off">
    <input name="barcode" id="ret_barcode" size="40" accesskey="r" />
    <input value="Submit" class="submit" type="submit" />
    </form>
    </div>
    [% END %]
			<ul>
            <li><a href="#patron_search">Search patrons</a></li>
            [% IF ( CAN_user_circulate ) %]<li><a href="#circ_search">Check out</a></li>[% END %]
    [% IF ( CAN_user_circulate ) %]<li><a href="#checkin_search">Check in</a></li>[% END %]
            [% IF ( CAN_user_catalogue ) %]<li><a href="#catalog_search">Search the catalog</a></li>[% END %]
			</ul>
</div><!-- /header_search -->
</div><!-- /gradient -->
<script type="text/javascript">//<![CDATA[
$(document).ready(function() {
    [% IF ( advsearch ) %]$("#filteraction_on").toggle();
    [% ELSE %]$("#filters").toggle();
    $("#filteraction_off").toggle();[% END %]
});
//]]>
</script>
<!-- End Patrons Resident Search Box -->
