[% USE Koha %]
<!-- Begin ERM Resident Search Box -->
<div id="header_search">
    <div id="agreement_search" class="residentsearch">
        <form action="/cgi-bin/koha/erm/agreements" method="get">
            <span class="form-title">
                <label class="control-label">Agreement search</label>
            </span>
            <span class="form-content">
                <input type="text" name="q" id="agreement_filter" class="head-searchbox form-control" placeholder="Enter search keywords" size="40" />
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    <div id="package_search" class="residentsearch">
        <form action="/cgi-bin/koha/erm/eholdings/local/packages" method="get">
            <span class="form-title">
                <label class="control-label">Package search</label>
            </span>
            <span class="form-content">
                <input type="text" name="package_name" id="package_name_filter" class="head-searchbox form-control" placeholder="Enter search keywords" size="40" />
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    <div id="title_search" class="residentsearch">
        <form action="/cgi-bin/koha/erm/eholdings/local/titles" method="get">
            <span class="form-title">
                <label class="control-label">Title search</label>
            </span>
            <span class="form-content">
                <input type="text" name="publication_title" id="title_filter" class="head-searchbox form-control" placeholder="Enter search keywords" size="40" />
            </span>
            <button type="submit"><i class="fa fa-arrow-right"></i></button>
        </form>
    </div>

    <ul>
        <li><a title="Search agreements" href="#agreement_search" class="keep_text"><i class="fa fa-upload"></i> <span class="tab-title">Search agreements</span></a></li>
        <li><a title="Search packages" href="#package_search" class="keep_text"><i class="fa fa-file-text-o"></i> <span class="tab-title">Search packages</span></a></li>
        <li><a title="Search titles" href="#title_search" class="keep_text"><i class="fa fa-file-text-o"></i> <span class="tab-title">Search titles</span></a></li>
    </ul>
</div>
<!-- End ERM Resident Search Box -->
