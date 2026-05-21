/**
 * EDIFACT Display Module
 */
const EdifactDisplay = (() => {
    "use strict";

    const defaults = {
        modalId: "#EDI_modal",
        modalBodySelector: ".modal-body",
        jsonEndpoint: "/cgi-bin/koha/acqui/edimsg.pl",
        expandByDefault: true,
    };

    const extractFocusOptions = element => {
        const options = {};
        const basketno = element.dataset.basketno;
        const basketname = element.dataset.basketname;
        const invoicenumber = element.dataset.invoicenumber;

        if (basketno) options.basketno = basketno;
        if (basketname) options.basketname = basketname;
        if (invoicenumber) options.invoicenumber = invoicenumber;

        return Object.keys(options).length > 0 ? options : null;
    };

    const init = (options = {}) => {
        const settings = { ...defaults, ...options };

        document.body.addEventListener("click", e => {
            if (e.target.closest(".view_edifact_message")) {
                e.preventDefault();
                const button = e.target.closest(".view_edifact_message");
                const messageId = button.dataset.messageId;
                const customUrl = button.dataset.url;
                const focusOptions = extractFocusOptions(button);

                if (messageId) {
                    showMessage(messageId, settings, focusOptions);
                } else if (customUrl) {
                    showMessageFromUrl(customUrl, settings, focusOptions);
                }
            }

            if (e.target.closest(".view_message_enhanced")) {
                e.preventDefault();
                const link = e.target.closest(".view_message_enhanced");
                const href = link.getAttribute("href");
                const focusOptions = extractFocusOptions(link);

                showMessageFromUrl(href, settings, focusOptions);
            }
        });

        initializeModal(settings);
    };

    const showMessage = (messageId, settings, focusOptions) => {
        const url = `${settings.jsonEndpoint}?id=${encodeURIComponent(messageId)}`;
        showMessageFromUrl(url, settings, focusOptions);
    };

    const showMessageFromUrl = (url, settings, focusOptions) => {
        const modal = $(settings.modalId);
        const modalContent = modal.find(".modal-content");
        const modalBody = modal.find(settings.modalBodySelector);
        const loadingHtml = `<div class="edi-loading">
            <img src="/intranet-tmpl/${window.theme || "prog"}/img/spinner-small.gif" alt="" />
            Loading
        </div>`;

        // Remove any existing EDIFACT navbars
        modalContent.find(".edi-main-navbar, .edi-tree-toolbar").remove();

        modalBody.html(loadingHtml);
        modal.modal("show");

        const jsonUrl = url + (url.includes("?") ? "&" : "?") + "format=json";

        $.ajax({
            url: jsonUrl,
            type: "GET",
            dataType: "json",
            success: data => {
                // Build components separately
                const mainNavbar = createMainNavbar();
                const treeToolbar = createTreeToolbar();
                const treeView = buildEdiTree(data, settings, focusOptions);
                const rawView = buildEdiRaw(data, settings, focusOptions);
                rawView.classList.add("hidden");

                // Add class for identification
                mainNavbar.classList.add("edi-main-navbar");

                // Insert navbar between header and body
                modalBody.before(mainNavbar);

                // Insert tree toolbar between navbar and body
                modalBody.before(treeToolbar);

                // Insert views directly into modal body
                modalBody.empty();
                modalBody.addClass("edi-content");
                modalBody.append(treeView, rawView);

                // Re-run initialization since DOM structure changed
                setTimeout(() => {
                    initializeViewToggle(modalContent[0], data);
                    initializeExpandCollapse(modalContent[0]);
                    initializeSearch(modalContent[0]);

                    if (focusOptions) {
                        applyFocusOptions(modalContent[0], focusOptions);
                    }
                }, 0);
            },
            error: () => {
                modalBody.html(
                    '<div class="alert alert-danger">Failed to load message</div>'
                );
            },
        });
    };

    const createMainNavbar = () => {
        const nav = document.createElement("nav");
        nav.className = "navbar navbar-light bg-light border-bottom py-2";
        nav.innerHTML = `
            <div class="container-fluid align-items-center">
                <!-- Left: View toggle buttons -->
                <div class="btn-group me-2" role="group" aria-label="Display style">
                    <button type="button" class="btn btn-outline-secondary active" data-view="tree" title="Tree view">
                        <i class="fa fa-sitemap fa-fw"></i>
                    </button>
                    <button type="button" class="btn btn-outline-secondary" data-view="raw" title="Raw view">
                        <i class="fa fa-file-text fa-fw"></i>
                    </button>
                </div>

                <!-- Center: Search form -->
                <form class="d-flex flex-grow-1 mx-2 edi-search-form" role="search">
                    <input class="form-control me-2 edi-search-input" type="search" placeholder="Search segments..." aria-label="Search segments">
                    <button class="btn btn-outline-secondary me-1 edi-search-prev" type="button" title="Previous result" disabled>
                        <i class="fa fa-chevron-up"></i>
                    </button>
                    <button class="btn btn-outline-secondary edi-search-next" type="button" title="Next result" disabled>
                        <i class="fa fa-chevron-down"></i>
                    </button>
                </form>

                <!-- Right: Search results -->
                <div class="text-muted small text-nowrap">
                    <span class="edi-search-count">0 results</span>
                </div>
            </div>`;
        return nav;
    };

    const createTreeToolbar = () => {
        const toolbar = document.createElement("div");
        toolbar.className =
            "navbar navbar-light bg-light border-bottom py-2 edi-tree-toolbar";
        toolbar.innerHTML = `
            <div class="container-fluid d-flex flex-row-reverse">
                <div class="btn-group btn-group-sm" role="group" aria-label="Tree controls">
                    <button type="button" class="btn btn-outline-secondary expand-all-btn" title="Expand all sections">
                        <i class="fa fa-expand me-1"></i>Expand all
                    </button>
                    <button type="button" class="btn btn-outline-secondary collapse-all-btn" title="Collapse all sections">
                        <i class="fa fa-compress me-1"></i>Collapse all
                    </button>
                </div>
            </div>`;
        return toolbar;
    };

    const buildEdiRaw = (data, settings, focusOptions) => {
        const rawDiv = document.createElement("div");
        rawDiv.className = "edi-raw-view";

        const lines = [];

        if (data.header) {
            lines.push(
                `<div class="segment-line"><span class="segment-tag">UNB</span>${data.header.substring(3)}</div>`
            );
        }

        data.messages.forEach((message, messageIndex) => {
            const isMessageFocused =
                focusOptions &&
                messageMatchesFocusOptions(message, focusOptions);
            const focusClass = isMessageFocused
                ? " edi-focused-segment-line"
                : "";
            const messageAttr = ` data-message-index="${messageIndex}"`;

            if (message.header) {
                lines.push(
                    `<div class="segment-line${focusClass}"${messageAttr}><span class="segment-tag">UNH</span>${message.header.substring(3)}</div>`
                );
            }

            message.segments.forEach(segment => {
                const tag = segment.tag || "";
                const content = (segment.raw || "").substring(tag.length);
                lines.push(
                    `<div class="segment-line${focusClass}"${messageAttr}><span class="segment-tag">${tag.escapeHtml()}</span>${content.escapeHtml()}</div>`
                );
            });

            if (message.trailer) {
                lines.push(
                    `<div class="segment-line${focusClass}"${messageAttr}><span class="segment-tag">UNT</span>${message.trailer.substring(3)}</div>`
                );
            }
        });

        if (data.trailer) {
            lines.push(
                `<div class="segment-line"><span class="segment-tag">UNZ</span>${data.trailer.substring(3)}</div>`
            );
        }

        rawDiv.innerHTML = lines.join("");
        return rawDiv;
    };

    const initializeViewToggle = (container, data) => {
        const toggleButtons = container.querySelectorAll("button[data-view]");
        const treeView = container.querySelector(".edi-tree");
        const rawView = container.querySelector(".edi-raw-view");
        const treeToolbar = container.querySelector(".edi-tree-toolbar");

        container.edifactData = data;

        toggleButtons.forEach(button => {
            button.addEventListener("click", () => {
                const viewType = button.dataset.view;

                // Update button states
                toggleButtons.forEach(btn => btn.classList.remove("active"));
                button.classList.add("active");

                // Toggle views and tree toolbar
                if (viewType === "tree") {
                    treeView.classList.remove("hidden");
                    rawView.classList.add("hidden");
                    treeToolbar.classList.remove("d-none");
                } else {
                    treeView.classList.add("hidden");
                    rawView.classList.remove("hidden");
                    treeToolbar.classList.add("d-none");
                }

                // Re-execute search if active
                if (container.searchFunctions) {
                    const searchInput =
                        container.querySelector(".edi-search-input");
                    if (searchInput?.value.trim()) {
                        container.searchFunctions.performSearch(
                            searchInput.value.trim()
                        );
                    }
                }

                // Re-apply focus highlighting
                if (container.focusOptions) {
                    setTimeout(() => {
                        const focusTarget =
                            viewType === "tree"
                                ? container.querySelector(
                                      '[data-focus-message="true"].edi-focused-message'
                                  )
                                : rawView.querySelector(
                                      ".edi-focused-segment-line"
                                  );

                        focusTarget?.scrollIntoView({
                            behavior: "smooth",
                            block: "start",
                        });
                    }, 100);
                }
            });
        });
    };

    const initializeExpandCollapse = container => {
        const treeView = container.querySelector(".edi-tree");

        container
            .querySelector(".expand-all-btn")
            ?.addEventListener("click", () => {
                const collapseElements = treeView.querySelectorAll(".collapse");
                collapseElements.forEach(el => {
                    el.classList.add("show");
                    if (typeof bootstrap !== "undefined") {
                        bootstrap.Collapse.getOrCreateInstance(el)?.show();
                    }
                });
            });

        container
            .querySelector(".collapse-all-btn")
            ?.addEventListener("click", () => {
                const collapseElements = treeView.querySelectorAll(".collapse");
                collapseElements.forEach(el => {
                    if (typeof bootstrap !== "undefined") {
                        bootstrap.Collapse.getOrCreateInstance(el).hide();
                    } else {
                        el.classList.remove("show");
                    }
                });
            });
    };

    const initializeSearch = container => {
        const searchInput = container.querySelector(".edi-search-input");
        const searchCount = container.querySelector(".edi-search-count");
        const searchPrev = container.querySelector(".edi-search-prev");
        const searchNext = container.querySelector(".edi-search-next");
        const treeView = container.querySelector(".edi-tree");
        const rawView = container.querySelector(".edi-raw-view");

        let currentResults = [];
        let currentIndex = -1;
        let searchTimeout = null;

        const performSearch = query => {
            clearSearch(false);

            if (!query || query.length < 2) {
                updateSearchUI(0, -1);
                return;
            }

            const activeView = container.querySelector(".edi-tree:not(.hidden)")
                ? "tree"
                : "raw";
            const searchTargets =
                activeView === "tree"
                    ? treeView.querySelectorAll(".segment")
                    : rawView.querySelectorAll(".segment-line");

            const regex = new RegExp(escapeRegExp(query), "i");

            searchTargets.forEach(element => {
                const textContent = element.textContent || element.innerText;
                if (regex.test(textContent)) {
                    highlightMatches(element, query);
                    currentResults.push({ element, view: activeView });
                }
            });

            if (activeView === "tree") {
                smartExpandCollapseForSearch(currentResults);
            }

            updateSearchUI(currentResults.length, currentIndex);

            if (currentResults.length > 0) {
                navigateToResult(0);
            }
        };

        const highlightMatches = (element, query) => {
            const regex = new RegExp(`(${escapeRegExp(query)})`, "gi");
            const walker = document.createTreeWalker(
                element,
                NodeFilter.SHOW_TEXT
            );

            const textNodes = [];
            let node;
            while ((node = walker.nextNode())) {
                textNodes.push(node);
            }

            textNodes.forEach(textNode => {
                if (regex.test(textNode.textContent)) {
                    const highlightedHTML = textNode.textContent.replace(
                        regex,
                        '<mark class="edi-search-highlight">$1</mark>'
                    );
                    const wrapper = document.createElement("span");
                    wrapper.innerHTML = highlightedHTML;
                    textNode.parentNode.replaceChild(wrapper, textNode);
                }
            });
        };

        const smartExpandCollapseForSearch = results => {
            setTimeout(() => {
                const allCollapseElements =
                    treeView.querySelectorAll(".collapse");
                const elementsWithResults = new Set();

                results.forEach(result => {
                    let current = result.element;
                    while (current && current !== treeView) {
                        if (current.classList?.contains("collapse")) {
                            elementsWithResults.add(current);
                        }
                        current = current.parentElement;
                    }
                });

                allCollapseElements.forEach(collapseElement => {
                    const collapse =
                        typeof bootstrap !== "undefined"
                            ? bootstrap.Collapse.getOrCreateInstance(
                                  collapseElement,
                                  { toggle: false }
                              )
                            : null;

                    if (elementsWithResults.has(collapseElement)) {
                        collapse
                            ? collapse.show()
                            : collapseElement.classList.add("show");
                    } else {
                        collapse
                            ? collapse.hide()
                            : collapseElement.classList.remove("show");
                    }
                });
            }, 50);
        };

        const navigateResults = direction => {
            if (currentResults.length === 0) return;

            let newIndex = currentIndex + direction;
            if (newIndex >= currentResults.length) newIndex = 0;
            if (newIndex < 0) newIndex = currentResults.length - 1;

            navigateToResult(newIndex);
        };

        const navigateToResult = index => {
            if (index < 0 || index >= currentResults.length) return;

            currentResults[currentIndex]?.element.classList.remove(
                "edi-search-current"
            );

            currentIndex = index;
            const result = currentResults[currentIndex];

            result.element.classList.add("edi-search-current");
            result.element.scrollIntoView({
                behavior: "smooth",
                block: "center",
            });

            updateSearchUI(currentResults.length, currentIndex);
        };

        const clearSearch = (clearInput = true) => {
            if (clearInput && searchInput) {
                searchInput.value = "";
            }

            container
                .querySelectorAll(".edi-search-highlight, .edi-search-current")
                .forEach(el => {
                    if (el.classList.contains("edi-search-highlight")) {
                        el.parentNode.replaceChild(
                            document.createTextNode(el.textContent),
                            el
                        );
                    } else {
                        el.classList.remove("edi-search-current");
                    }
                });

            container.querySelectorAll("span:not([class])").forEach(wrapper => {
                if (
                    wrapper.children.length === 0 ||
                    (wrapper.children.length === 1 &&
                        wrapper.children[0].tagName === "MARK")
                ) {
                    wrapper.parentNode.replaceChild(
                        document.createTextNode(wrapper.textContent),
                        wrapper
                    );
                }
            });

            currentResults = [];
            currentIndex = -1;
            updateSearchUI(0, -1);
        };

        const updateSearchUI = (totalResults, currentIdx) => {
            if (searchCount) {
                searchCount.textContent =
                    totalResults === 0
                        ? "0 results"
                        : `${currentIdx + 1} of ${totalResults}`;
            }

            const hasResults = totalResults > 0;
            if (searchPrev) searchPrev.disabled = !hasResults;
            if (searchNext) searchNext.disabled = !hasResults;
        };

        const escapeRegExp = string =>
            string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

        // Event listeners
        searchInput?.addEventListener("input", () => {
            clearTimeout(searchTimeout);
            const value = searchInput.value.trim();

            // If field was cleared (native clear button or manual), clear search
            if (value === "") {
                clearSearch(false); // Don't clear input since it's already empty
            } else {
                searchTimeout = setTimeout(() => performSearch(value), 500);
            }
        });

        searchInput?.addEventListener("keydown", e => {
            if (e.key === "Enter") {
                e.preventDefault();
                navigateResults(e.shiftKey ? -1 : 1);
            }
        });

        // Prevent form submission
        const searchForm = container.querySelector(".edi-search-form");
        searchForm?.addEventListener("submit", e => e.preventDefault());

        searchPrev?.addEventListener("click", () => navigateResults(-1));
        searchNext?.addEventListener("click", () => navigateResults(1));

        container.searchFunctions = {
            performSearch,
            clearSearch,
            navigateResults,
        };
    };

    const messageMatchesFocusOptions = (message, focusOptions) => {
        if (!message.segments || !focusOptions) return false;

        // Check if basketno is a whole number and pad it
        if (/^\d+$/.test(String(focusOptions.basketno))) {
            const strVal = String(focusOptions.basketno);
            if (11 > strVal.length) {
                focusOptions.basketno = strVal.padStart(11, "0");
            }
        }

        return message.segments.some(segment => {
            // Check basketno/invoicenumber in BGM segments
            if (segment.tag === "BGM" && segment.elements?.length > 1) {
                const bgmValue = String(segment.elements[1]);

                if (
                    (focusOptions.basketno &&
                        bgmValue === String(focusOptions.basketno)) ||
                    (focusOptions.invoicenumber &&
                        bgmValue === String(focusOptions.invoicenumber))
                ) {
                    return true;
                }
            }

            // Check basketname/invoicenumber in RFF segments
            if (segment.tag === "RFF" && segment.elements?.length >= 2) {
                const refType = segment.elements[0];
                const refValue = String(segment.elements[1]);

                if (
                    focusOptions.basketname &&
                    refType === "ON" &&
                    refValue === String(focusOptions.basketname)
                ) {
                    return true;
                }

                if (
                    focusOptions.invoicenumber &&
                    (refType === "IV" || refType === "VN") &&
                    refValue === String(focusOptions.invoicenumber)
                ) {
                    return true;
                }
            }

            return false;
        });
    };

    const applyFocusOptions = (container, focusOptions) => {
        container.focusOptions = focusOptions;

        setTimeout(() => {
            const focusedMessage = container.querySelector(
                '[data-focus-message="true"]'
            );
            if (focusedMessage) {
                focusedMessage.classList.add("edi-focused-message");

                const treeView = container.querySelector(".edi-tree");
                if (treeView && !treeView.classList.contains("hidden")) {
                    focusedMessage.scrollIntoView({
                        behavior: "smooth",
                        block: "start",
                    });
                }

                container.setAttribute("data-has-focused-message", "true");
            }

            const rawView = container.querySelector(".edi-raw-view");
            if (rawView && !rawView.classList.contains("hidden")) {
                const firstFocusedLine = rawView.querySelector(
                    ".edi-focused-segment-line"
                );
                firstFocusedLine?.scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                });
            }
        }, 200);
    };

    const buildEdiTree = (data, settings, focusOptions) => {
        const rootUl = document.createElement("ul");
        rootUl.className = "edi-tree list-unstyled";

        const hasMatchingMessage =
            focusOptions &&
            data.messages &&
            data.messages.some(msg =>
                messageMatchesFocusOptions(msg, focusOptions)
            );

        const effectiveFocusOptions =
            focusOptions && !hasMatchingMessage ? null : focusOptions;
        const effectiveSettings =
            focusOptions && !hasMatchingMessage
                ? { ...settings, expandByDefault: true }
                : settings;

        const interchangeLi = buildInterchangeLevel(
            data,
            effectiveSettings,
            effectiveFocusOptions
        );
        rootUl.appendChild(interchangeLi);

        return rootUl;
    };

    const buildInterchangeLevel = (data, settings, focusOptions) => {
        const interchangeLi = document.createElement("li");
        const interchangeId = `interchange_${Date.now()}`;
        const shouldExpand = focusOptions ? true : settings.expandByDefault;

        const headerDiv = createSegmentDiv(
            "header",
            data.header,
            shouldExpand,
            true,
            interchangeId
        );
        interchangeLi.appendChild(headerDiv);

        const messagesUl = document.createElement("ul");
        messagesUl.id = interchangeId;
        messagesUl.className = `collapse${shouldExpand ? " show" : ""}`;

        data.messages.forEach((message, i) => {
            const messageLi = buildMessageLevel(
                message,
                i,
                settings,
                focusOptions
            );
            messagesUl.appendChild(messageLi);
        });

        const trailerDiv = createSegmentDiv(
            "trailer",
            data.trailer,
            false,
            true
        );

        interchangeLi.append(messagesUl, trailerDiv);
        return interchangeLi;
    };

    const buildMessageLevel = (message, index, settings, focusOptions) => {
        const messageLi = document.createElement("li");
        const messageId = `message_${index}_${Date.now()}`;

        const shouldFocusMessage =
            focusOptions && messageMatchesFocusOptions(message, focusOptions);
        const shouldExpand = focusOptions
            ? shouldFocusMessage
            : settings.expandByDefault;

        const headerDiv = createSegmentDiv(
            "header",
            message.header || "UNH",
            shouldExpand,
            true,
            messageId
        );
        messageLi.appendChild(headerDiv);

        if (shouldFocusMessage) {
            messageLi.setAttribute("data-focus-message", "true");
        }

        const segmentsUl = document.createElement("ul");
        segmentsUl.id = messageId;
        segmentsUl.className = `collapse${shouldExpand ? " show" : ""}`;

        const groupedSegments = groupSegmentsByLineId(message.segments);

        groupedSegments.forEach((group, i) => {
            if (group.isLineGroup) {
                const lineGroupLi = buildLineGroup(
                    group,
                    settings,
                    `${messageId}_line_${i}`
                );
                segmentsUl.appendChild(lineGroupLi);
            } else {
                const relatedGrouping = groupRelatedSegments(group.segments);

                relatedGrouping.forEach(relatedItem => {
                    if (relatedItem.type === "group") {
                        const groupLi = document.createElement("li");
                        const groupDiv = document.createElement("div");
                        groupDiv.className = "segment-group related-segments";
                        groupDiv.setAttribute(
                            "data-relationship",
                            relatedItem.relationship
                        );

                        relatedItem.segments.forEach(segment => {
                            const segmentDiv = createSegmentDiv(
                                "content",
                                segment.raw,
                                false,
                                true
                            );
                            if (segment.line_id)
                                segmentDiv.dataset.lineId = segment.line_id;
                            groupDiv.appendChild(segmentDiv);
                        });

                        groupLi.appendChild(groupDiv);
                        segmentsUl.appendChild(groupLi);
                    } else {
                        const segmentLi = buildSegmentElement(
                            relatedItem.segment,
                            settings
                        );
                        segmentsUl.appendChild(segmentLi);
                    }
                });
            }
        });

        const trailerDiv = createSegmentDiv(
            "trailer",
            message.trailer || "UNT",
            false,
            true
        );

        messageLi.append(segmentsUl, trailerDiv);
        return messageLi;
    };

    const buildLineGroup = (group, settings, lineId) => {
        const lineGroupLi = document.createElement("li");
        const linSegment = group.segments[0];

        const headerDiv = createSegmentDiv(
            "header",
            linSegment.raw,
            settings.expandByDefault,
            true,
            lineId
        );
        lineGroupLi.appendChild(headerDiv);

        const lineSegmentsUl = document.createElement("ul");
        lineSegmentsUl.id = lineId;
        lineSegmentsUl.className = `collapse${settings.expandByDefault ? " show" : ""}`;

        const lineSegments = group.segments.slice(1);
        const groupedSegments = groupRelatedSegments(lineSegments);

        groupedSegments.forEach(groupItem => {
            if (groupItem.type === "group") {
                const groupLi = document.createElement("li");
                const groupDiv = document.createElement("div");
                groupDiv.className = "segment-group related-segments";
                groupDiv.setAttribute(
                    "data-relationship",
                    groupItem.relationship
                );

                groupItem.segments.forEach(segment => {
                    const segmentDiv = createSegmentDiv(
                        "content",
                        segment.raw,
                        false,
                        true
                    );
                    if (segment.line_id)
                        segmentDiv.dataset.lineId = segment.line_id;
                    groupDiv.appendChild(segmentDiv);
                });

                groupLi.appendChild(groupDiv);
                lineSegmentsUl.appendChild(groupLi);
            } else {
                const segmentLi = buildSegmentElement(
                    groupItem.segment,
                    settings
                );
                lineSegmentsUl.appendChild(segmentLi);
            }
        });

        lineGroupLi.appendChild(lineSegmentsUl);
        return lineGroupLi;
    };

    const buildSegmentElement = (segment, settings) => {
        const segmentLi = document.createElement("li");
        const segmentDiv = createSegmentDiv(
            "content",
            segment.raw,
            false,
            true
        );

        if (segment.line_id) {
            segmentDiv.dataset.lineId = segment.line_id;
        }

        if (settings.showElementDetails && segment.elements) {
            const detailsDiv = document.createElement("div");
            detailsDiv.className = "segment-details";
            detailsDiv.innerHTML = `<small>Elements: ${JSON.stringify(segment.elements)}</small>`;
            segmentDiv.appendChild(detailsDiv);
        }

        segmentLi.appendChild(segmentDiv);
        return segmentLi;
    };

    const groupRelatedSegments = segments => {
        const grouped = [];
        let i = 0;

        const relationships = {
            ALC: ["MOA", "TAX"],
            PRI: ["MOA"],
            QTY: ["MOA"],
            DTM: ["MOA"],
            TAX: ["MOA"],
            RFF: ["DTM"],
        };

        while (i < segments.length) {
            const segment = segments[i];
            const relatedTags = relationships[segment.tag];

            if (relatedTags) {
                const relatedSegments = [segment];
                let j = i + 1;

                while (
                    j < segments.length &&
                    relatedTags.includes(segments[j].tag)
                ) {
                    relatedSegments.push(segments[j]);
                    j++;
                }

                if (relatedSegments.length > 1) {
                    grouped.push({
                        type: "group",
                        relationship: `${segment.tag}_group`,
                        segments: relatedSegments,
                    });
                    i = j;
                } else {
                    grouped.push({ type: "single", segment });
                    i++;
                }
            } else {
                grouped.push({ type: "single", segment });
                i++;
            }
        }

        return grouped;
    };

    const createSegmentDiv = (
        type,
        content,
        expandByDefault,
        boldTag,
        targetId
    ) => {
        const div = document.createElement("div");
        div.className = `segment ${type}`;

        if (type === "header" && targetId) {
            div.setAttribute("data-bs-toggle", "collapse");
            div.setAttribute("data-bs-target", `#${targetId}`);
            div.setAttribute(
                "aria-expanded",
                expandByDefault ? "true" : "false"
            );
            div.setAttribute("aria-controls", targetId);
            div.style.cursor = "pointer";

            if (boldTag && content && content.length >= 3) {
                const tag = content.substring(0, 3);
                const rest = content.substring(3);
                div.innerHTML = `<i class="fa fa-chevron-down me-1"></i> <span class="segment-tag">${tag.escapeHtml()}</span>${rest.escapeHtml()}`;
            } else {
                div.innerHTML = `<i class="fa fa-chevron-down me-1"></i> ${content.escapeHtml()}`;
            }
        } else if (boldTag && content && content.length >= 3) {
            const tag = content.substring(0, 3);
            const rest = content.substring(3);
            div.innerHTML = `<span class="segment-tag">${tag.escapeHtml()}</span>${rest.escapeHtml()}`;
        } else {
            div.textContent = content;
        }

        return div;
    };

    const groupSegmentsByLineId = segments => {
        const groups = [];
        let currentGroup = null;

        segments.forEach(segment => {
            if (segment.tag === "LIN") {
                if (currentGroup) groups.push(currentGroup);
                currentGroup = {
                    isLineGroup: true,
                    lineId: segment.line_id,
                    segments: [segment],
                };
            } else if (
                currentGroup &&
                segment.line_id === currentGroup.lineId
            ) {
                currentGroup.segments.push(segment);
            } else {
                if (currentGroup) {
                    groups.push(currentGroup);
                    currentGroup = null;
                }
                groups.push({ isLineGroup: false, segments: [segment] });
            }
        });

        if (currentGroup) groups.push(currentGroup);
        return groups;
    };

    const initializeModal = settings => {
        const modal = $(settings.modalId);

        modal.on("hidden.bs.modal", function () {
            const modalContent = $(this).find(".modal-content");
            const modalBody = $(this).find(settings.modalBodySelector);

            // Remove focus highlighting and navbar
            modalContent
                .find(".edi-focused-message")
                .removeClass("edi-focused-message");
            modalContent.find(".edi-main-navbar").remove();

            // Remove scrolling class and reset modal body content
            modalBody.removeClass("edi-content");
            modalBody.html(`
                <div class="edi-loading">
                    <img src="/intranet-tmpl/${window.theme || "prog"}/img/spinner-small.gif" alt="" />
                    Loading
                </div>
            `);
        });
    };

    return {
        init,
        showMessage,
        showMessageFromUrl,
        buildEdiTree,
    };
})();

if (typeof $ !== "undefined") {
    $(document).ready(() => {
        // Individual pages handle initialization
    });
}
