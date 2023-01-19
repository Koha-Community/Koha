<!-- acquisitions-search.inc -->
<div id="header_search" role="tablist">
    <div class="tab-content">
        <div id="supplier_search" role="tabpanel" class="tab-pane active">
            <form name="findsupplier" action="/cgi-bin/koha/acqui/booksellers.pl" method="post">
                <div class="form-title">
                    <label class="control-label">Vendor search</label>
                </div>

                <div class="form-content">
                    <input type="text" name="supplier" id="supplier" class="head-searchbox form-control" placeholder="Search vendors" />
                </div>
                <button type="submit"><i class="fa fa-arrow-right"></i></button>
            </form>
        </div>

        <div id="orders_search" role="tabpanel" class="tab-pane">
            <form action="/cgi-bin/koha/acqui/histsearch.pl" method="post">
                <div class="form-title">
                    <label class="control-label">Orders search</label>
                </div>

                <div class="form-content">
                    <input type="text" id="title" class="form-control" placeholder="Title" name="title" size="13" value="[% title | html %]" />
                    <input type="text" id="searchsupplier" class="form-control" placeholder="Vendor" name="name" size="13" value="[% name | html %]" />
                    <button type="button" class="form-extra-content-toggle"><i class="fa fa-sliders"></i></button>
                    <input type="hidden" id="do_search" name="do_search" value="do" />
                </div>
                <button type="submit"><i class="fa fa-arrow-right"></i></button>

                <div class="form-extra-content">
                    <div>
                        <label for="basket" class="control-label">Basket</label>
                        <input type="text" class="form-control" placeholder="Basket" name="basket" id="basket" />
                    </div>
                    <div>
                        <label for="booksellerinvoicenumber" class="control-label">Invoice number</label>
                        <input type="text" class="form-control" placeholder="Invoice number" name="booksellerinvoicenumber" id="booksellerinvoicenumber" />
                    </div>
                    <div>
                        <a href="/cgi-bin/koha/acqui/histsearch.pl">Advanced search</a>
                    </div>
                </div>
            </form>
        </div>
    </div><!-- /.tab-content -->
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active">
            <a title="Vendor search" href="#supplier_search" aria-controls="supplier_search" role="tab" aria-expanded="true" data-toggle="tab" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Vendor search</span></a>
        </li>
        <li role="presentation">
            <a title="Orders search" href="#orders_search" aria-controls="orders_search" role="tab" data-toggle="tab" class="keep_text"><i class="fa fa-download"></i> <span class="tab-title">Orders search</span></a>
        </li>
    </ul>
</div><!-- /#header_search -->
<!-- /acquisitions-search.inc -->
