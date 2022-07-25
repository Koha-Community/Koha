<!-- Begin Acquisitions Resident Search Box -->

<div id="header_search" class="navbar-form navbar-left">
    <div id="supplier_search" class="residentsearch">
        <form name="findsupplier" action="/cgi-bin/koha/acqui/booksellers.pl" method="post">
            <span class="form-title">
                <label class="control-label">Vendor search</label>
            </span>
            <span class="form-content">
                <input type="text" name="supplier" id="supplier" class="head-searchbox form-control" placeholder="Search vendors" />
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    <div id="orders_search" class="residentsearch">
        <form action="/cgi-bin/koha/acqui/histsearch.pl" method="post">
            <span class="form-title">
                <label class="control-label">Orders search</label>
            </span>
            <span class="form-content">
                <input type="text" id="title" class="form-control" placeholder="Title" name="title" size="13" value="[% title | html %]" />
                <input type="text" id="searchsupplier" class="form-control" placeholder="Vendor" name="name" size="13" value="[% name | html %]" />
                <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
                <input type="hidden" id="do_search" name="do_search" value="do" />
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>

            <div class="form-extra-content">
                <div>
                    <label for="basket" class="control-label">Basket</label>
                    <input type="text" class="form-control" placeholder="Basket" name="basket" id="basket" />
                </div>
                <div>
                    <label for="booksellerinvoicenumber" class="control-label">Basket</label>
                    <input type="text" class="form-control" placeholder="Invoice number" name="booksellerinvoicenumber" id="booksellerinvoicenumber" />
                </div>
            </div>
        </form>
    </div>

    <ul>
        <li><a title="Vendor search" href="#supplier_search"><i class="fa fa-upload"></i></a></li>
        <li><a title="Orders search" href="#orders_search"><i class="fa fa-download"></i></a></li>
    </ul>
</div><!-- /header_search -->

<!-- End Main page Resident Search Box -->
