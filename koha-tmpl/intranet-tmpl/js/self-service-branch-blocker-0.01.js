'use strict';

/**
 * @version 0.0.1
 *
 * Self-Service Branch Blocker implementation
 * for more documentation about possible request-response pairs, see the Swagger-UI in
 * @see https://koha-hostname/api/v1/doc/
 *
 * @license GPL3+
 * @copyright Hypernova Oy
 */
class SSBranchBlocker {

  /**
   *
   * @param {String or URL} baseUrl
   * @param {HTMLElement} htmlRoot
   * @param {Object} options
   *                   borrowernumber: The borrower to whom the blocks are looked and created for
   *                   branches: Array of Branch-objects used to populate the branch selector,
   *                             branchcode: 'JOE_JOE',
   *                             branchname: 'Joensuun pääkirjasto',
   *                   defaultBlockDuration: In days, how long the self-service access block is by default
   *                   timezone: +02:00  the ISO8601 timezone, if not provided uses moment.js to guess it.
   *                   locale: fi  if not passed, tries to guess it
   *                   rootElementSummaries: If the borrower has blocks, display a short summary inside this element
   *                   translations: Object containing all the translation keys for this widget
   */
  constructor(baseUrl, htmlRoot, options) {
    this.checkRequirements();
    this.id = SSBranchBlocker.instances.length;
    SSBranchBlocker.instances[this.id] = this;

    /** Koha server address */
    this.baseUrl = baseUrl;
    /** Where to mount this widget */
    this.htmlRoot = htmlRoot;
    this.htmlRootElementSummaries = options.rootElementSummaries;
    /** Which borrower is chosen for blocking? */
    this.borrowernumber = options.borrowernumber;
    /** Branches available to select for self-service block targets */
    this.branches = options.branches;
    /** Translations */
    this.translations = options.translations || {};
    /** How long is the block in effect by library default settings, see syspref 'SSBlockDefaultDuration' */
    this.defaultBlockDuration = options.defaultBlockDuration;
    this.timezone = options.timezone;
    if (!this.timezone) {
      this.timezone = moment.tz.guess();
      console.log("timezone '"+this.timezone+"' guessed by moment.js");
    }
    if (options.locale && ! /^\w\w[-_]\w\w$|^\w\w$/.exec(options.locale)) {
      console.log(`Given locale '${options.locale}' is not a valid locale, like en, or fi-FI. Defaulting to fi.`);
      options.locale = 'fi';
    }
    this.locale = options.locale
    if (!this.locale) {
      this.locale = window.navigator.userLanguage || window.navigator.language;
      console.log("locale '"+this.locale+"'inferred from user browser");
    }
    moment.locale(this.locale);

    /** User-agent used to drive the HTTP-requests. Using axios */
    this.browser = axios.create({
      withCredentials: true, // This uses the existing Koha's CGISESSID
      baseURL: baseUrl+'/api/v1/',
    });

    /** All the known states this object has */
    this.states = {
      dataTableInitialized: 0,
      blockEditorShowing: 0,
    };

    // Render the HTML
    // Warning, there is no sanitation done here. Make sure you have clean data! Currently only this.id is interpolated.
    this.htmlRoot.innerHTML = `
    <table id="${this._getHtmlId('ssbb-DataTable')}">
      <caption style="min-width: 20em">${this._('Self-service blocks')}
        <a style="padding: 3px 5px 0px 5px;" id="${this._getHtmlId('ssbb-addBlock')}" class="btn btn-default btn-sm"><i class="fa fa-plus"></i></a>
      </caption>
    </table>
    <div style="margin: 1em 0em 0em 0em" id="${this._getHtmlId('ssbb-Notifications')}"/>
    `;
    document.getElementById(this._getHtmlId("ssbb-addBlock")).addEventListener('click', () => this.showBlockEditor.call(this, this.dataTable)); //Make sure the showBlockEditor is called in the context of this object instance
    this.htmlNotifications = document.getElementById(this._getHtmlId("ssbb-Notifications"));

    this.initDataTable();
  }

  checkRequirements() {
    if(typeof jQuery === 'undefined') {
      throw new Error("jQuery https://jquery.com/ is not available");
    }
    if(! jQuery().datepicker) {
      throw new Error("jQuery DatePicker http://api.jqueryui.com/datepicker/ is not available");
    }
    if(! jQuery().dataTable) {
      throw new Error("jQuery DataTable https://datatables.net/ is not available");
    }
    if(typeof axios === 'undefined') {
      throw new Error("axios.js https://github.com/axios/axios is not available");
    }
    if(typeof moment === 'undefined') {
      throw new Error("moment.js https://momentjs.com/ is not available");
    }
    if(typeof moment.tz === 'undefined') {
      throw new Error("moment-timezone.js https://momentjs.com/timezone/ is not available");
    }
    if(typeof filterXSS === 'undefined') {
      throw new Error("xss.js https://jsxss.com/en/index.html is not available");
    }
  }

  initDataTable() {
    this.listBlocks()
    .then((blocks) => {
      if (blocks) {
        this.createDataTable(blocks);
        this.createSummary(blocks);
        this._loadBlocksToDataTable(blocks);
      }
    });
  }

  createDataTable(blocks) {
    this.dataTable = $(this._getHtmlId('#ssbb-DataTable')).DataTable({
      /* TEST DATA
      data: [
        {
          "borrower_ss_block_id":89,
          "borrowernumber":7350,
          "branchcode":"CPL",
          "created_by":7349,
          "created_on":"2018-12-22 12:40:48",
          "expirationdate":"2018-12-21 15:40:05",
          "notes":"noteno note"
        },
        {
          "borrower_ss_block_id":90,
          "borrowernumber":7350,
          "branchcode":"FPL",
          "created_by":7349,
          "created_on":"2018-12-22 12:40:48",
          "expirationdate":"2018-12-22 13:58:51",
          "notes":"notena nante"
        }
      ],*/
      columns: [
        { name: "borrower_ss_block_id", title: this._("Id"),              data: "borrower_ss_block_id" },
        { name: "borrowernumber",       title: this._("Borrower"),        data: "borrowernumber", visible: false },
        { name: "branch",               title: this._("Branch"),          data: "branchcode" },
        { name: "expirationdate",       title: this._("Expiration date"), data: "expirationdate",
          render: (data, type, full, meta) => {
            if (/^</.test(data)) {
              return data;
            } else {
              return moment.tz(data, this.timezone).format('L');
            }
          }
        },
        { name: "notes",            title: this._("Notes"),           data: "notes" },
        { name: "createdby",        title: this._("Created by"),      data: "created_by" },
        { name: "createdon",        title: this._("Created on"),      data: "created_on",
          render: (data, type, full, meta) => {
            if (/^</.test(data)) {
              return data;
            } else if (!data) {
              return "";
            } else {
              return moment.tz(data, this.timezone).format('L');
            }
          }
        },
        { name: "actions", title: this._("Actions"),
          render: (data, type, full, meta) => {
            if (!(full.borrower_ss_block_id === SSBranchBlocker._emptyIdString)) { // This is just another Block-row
              return `<a onclick="SSBranchBlocker.dispatcher(${this.id}, 'removeRow', '${full.borrower_ss_block_id}')" class="remove_restriction btn btn-default btn-xs"><i class="fa fa-trash"></i> ${this._('Remove')}</a>`;
            }
            else { // This is a block editor -row, so dispay a Save-button instead
              return `<a onclick="SSBranchBlocker.dispatcher(${this.id}, 'saveRow', '${full.borrower_ss_block_id}')" class="remove_restriction btn btn-default btn-xs"><i class="fa fa-save"></i> ${this._('Save')}</a>`;
            }
          }
        },
      ],
      rowId: (data) => this._getRowId(data.borrower_ss_block_id),
      dom: 't',
      drawCallback: (settings) => {
        let defaultDate = $( this._getHtmlId("#new-expirationdate") ).val();
          $( this._getHtmlId("#new-expirationdate") ).datepicker({
            defaultDate: new Date(defaultDate),
            dateFormat: moment.localeData()._longDateFormat.L.toLowerCase().replace('yyyy', 'yy'),
          });
        },
    });

    //Create Branch selector in a way we can export it as pure html text. DataTables must receive the contents as text to be able to properly render the results.
    this.htmlBranchSelectorContainer = document.createElement('div');
    this.htmlBranchSelectorContainer.innerHTML = filterXSS(`
      <select id="${this._getHtmlId('new-branchcode')}">
        ${this.branches.map(b => `<option value="${b.branchcode}">${b.branchname}</option>`)}
      </select>
    `, {
      whiteList: {
        select: ['id'],
        option: ['value'],
      }
    });

    this.states.dataTableInitialized = 1;
  }

  /**
   * Renders a summary of the given blocks to the optional summary html element
   * If no blocks or the summary target html is given during construction, does nothing.
   * @param {Array of Blocks} blocks
   */
  createSummary(blocks) {
    if (! (this.htmlRootElementSummaries && blocks)) return;

    let names = [];
    blocks.forEach((b) => names.push(this._getBranch(b.branchcode).branchname));
    this.htmlRootElementSummaries.innerHTML = filterXSS(`<ul><li>${this._('Self-service blocks in')} ${names.map((n) => n).join(', ')}</li></ul>`);
  }

  showBlockEditor() {
    if (this.states.blockEditorShowing) {
      return;
    }
    if (! this.states.dataTableInitialized) this.createDataTable();

    this.states.blockEditorShowing = 1;
    let expirationdate = "";
    if (this.defaultBlockDuration) {
      expirationdate = moment.tz(new Date(), this.timezone);
      expirationdate.add(this.defaultBlockDuration, 'days');
      expirationdate = expirationdate.format('L');
    }
    this.dataTable.rows.add([ {
      borrower_ss_block_id: SSBranchBlocker._emptyIdString,
      borrowernumber:       this.borrowernumber,
      branchcode:           this.htmlBranchSelectorContainer.innerHTML, // DataTables must receive text
      expirationdate:       `<input id="${this._getHtmlId('new-expirationdate')}" size="8" type="text" value="${expirationdate}"/>`,
      notes:                `<input id="${this._getHtmlId('new-notes')}" size="20" type="text" value=""/>`,
      created_by:           "",
      created_on:           "",
    } ]).draw();
  }

  removeRow(borrower_ss_block_id) {
    let rowId = this._getRowId(borrower_ss_block_id);

    if (! window.confirm(_("Are you sure you want to delete the block number")+" '"+borrower_ss_block_id+"' ?")) return;

    this.browser.delete('/borrowers/'+this.borrowernumber+'/ssblocks/'+borrower_ss_block_id)
    .then((response) => {
      this.dataTable.row("#"+rowId).remove().draw();
      this._successHandler(`${this._('Deleted')} '${response.data.deleted_count}' ${this._('block')}`);
    })
    .catch((error) => {
      this._errorHandler(this._('Deleting a Block failed'), error);
    });
  }

  saveRow(borrower_ss_block_id) {
    let rowId = this._getRowId(borrower_ss_block_id);

    let row = this.dataTable.row("#"+rowId);
    let data = row.data();
    let block = this._validateBlock(data);

    this.browser.post('/borrowers/'+this.borrowernumber+'/ssblocks', block)
    .then((response) => {
      this.states.blockEditorShowing = 0;
      let row = this.dataTable.row("#"+rowId);
      row.remove();
      this.dataTable.row.add(response.data);
      this.dataTable.draw();
      this._successHandler(this._('Block added'));
    })
    .catch((error) => {
      this._errorHandler(this._('Adding a Block failed'), error);
    });
  }

  /**
   * Lists all blocks for the active borrower to the currently loaded DataTable, if exists
   * Returns a Promise with the borrower's self-service blocks
   */
  listBlocks() {
    return this.browser.get('/borrowers/'+this.borrowernumber+'/ssblocks')
    .then((response) => {
      if (this.states.dataTableInitialized) {
        this._loadBlocksToDataTable(response.data);
      }
      return Promise.resolve(response.data);
    })
    .catch((error) => {
      if (error.response.data.error === "No self-service blocks") { //Ignore the 404 error of no blocks found
        return;
      }
      this._errorHandler(`${this._('Getting borrower')} '${this.borrowernumber}' ${this._('blocks failed')}`, error);
      return Promise.reject(error);
    });
  }
  _loadBlocksToDataTable(blocks) {
        // Flush the DataTable and recreate rows, this is a bit slow, but using the ajax-method of populating the table didn't feel very nice either.
        // This way no need to have two different ways of accessing the REST API.
        this.dataTable.rows().remove();
        blocks.forEach((b, i) => {
          this.dataTable.row.add(b);
        });
        this.dataTable.draw();
  }

  _validateBlock(data) {
    let block = {};
    block.borrower_ss_block_id = data.borrower_ss_block_id;
    if (block.borrower_ss_block_id === SSBranchBlocker._emptyIdString) {
      block.borrower_ss_block_id = undefined;
    }
    else {
      if (!(Number.isInteger(block.borrower_ss_block_id) && block.borrower_ss_block_id > 0)) {
        this._errorHandler ("borrower_ss_block_id '"+block.borrower_ss_block_id+"' is not a valid positive integer");
        throw new TypeError("borrower_ss_block_id '"+block.borrower_ss_block_id+"' is not a valid positive integer");
      }
    }
    block.borrowernumber = data.borrowernumber;
    if (!(Number.isInteger(block.borrowernumber) && block.borrowernumber > 0)) {
      this._errorHandler ("borrowernumber '"+block.borrowernumber+"' is not a valid positive integer");
      throw new TypeError("borrowernumber '"+block.borrowernumber+"' is not a valid positive integer");
    }
    block.branchcode = document.getElementById(this._getHtmlId('new-branchcode')).value;
    if (!block.branchcode) {
      this._errorHandler ("branchcode '"+block.branchcode+"' is not defined");
      throw new TypeError("branchcode '"+block.branchcode+"' is not defined");
    }
    block.expirationdate = document.getElementById(this._getHtmlId('new-expirationdate')).value;
    if (block.expirationdate) {
      block.expirationdate = moment(block.expirationdate, moment.localeData()._longDateFormat.L).tz(this.timezone);
      block.expirationdate = block.expirationdate.format();
    }
    else {
      block.expirationdate = undefined;
    }
    block.notes = filterXSS(document.getElementById(this._getHtmlId('new-notes')).value);

    //created_by and created_on are automatically set by the API. There is no reason to override those.

    return block;
  }

  /**
   * Using globalize.js would be more reasonable, but not doing anything more complicated than absolutely necessary due to Koha not having any modern user interface infrastructure to support dynamic anything.
   *
   * _() might look like a bad naming convention at first, but this is how GNU gettext is used on the serverside.
   * @param {String} msg to translate
   */
  _(msg) {
    if (this.translations[msg]) return this.translations[msg];
    return `UNTRANSLATEABLE"${msg}"`;
  }

  /**
   * Translate a branchcode to a Branch-object
   * @param {String} branchcode
   * @returns {Branch}
   */
  _getBranch(branchcode) {
    let branch = this.branches.find((br) => br.branchcode === branchcode);
    if (! branch) throw new Error(`No branch found with branchcode '${branchcode}'`);
    return branch;
  }

  _getRowId(borrower_ss_block_id) {
    return 'ssbb_row_'+borrower_ss_block_id;
  }
  _getHtmlId(elemId) {
    return elemId+this.id;
  }

  _successHandler(msg) {
    $(this.htmlNotifications).fadeOut(1);
    $(this.htmlNotifications).text(msg)
    .css("background-image","linear-gradient(#d7e5d7, #bcdbbc)")
    .css("border","#0003 1px solid")
    .addClass('dialog alert')
    .fadeIn(250);
  }
  _errorHandler(msg, error) {
    console.log(msg);
    if (error) {
      console.log(error && error.response ? error.response : error)
      msg += ': '+this._errorPayload(error);
    }

    $(this.htmlNotifications).fadeOut(1);
    $(this.htmlNotifications).text(msg)
    .css("background-image","linear-gradient(#f8b379, #d89b9b)")
    .css("border","#0003 1px solid")
    .addClass('dialog alert')
    .fadeIn(250);
  }
  _errorPayload(error) { return error && error.response && error.response.data ? error.response.data.error : '' }
}
/** STATIC ATTRIBUTES */
/** Id to be used to denote an empty borrower_ss_block_id.
 * Needed so we can properly sort by the row id, and that the row being added sorts to the bottom of the DataTable
 */
SSBranchBlocker._emptyIdString = '_';

/**
 * Due to the nature of DataTables, we cannot inject reference to the SSBranchBlocker-instance directly when rows are rendered.
 * Use a dynamic dispatcher to transparently route requests to the correct SSBranchBlocker-instance
 */
SSBranchBlocker.dispatcher = (ssbranchblockerId, method, ...params) => SSBranchBlocker.instances[ssbranchblockerId][method](...params);

/**
 * Track the created instances, so we don't get html id collisions with element ids.
 */
SSBranchBlocker.instances = [];
