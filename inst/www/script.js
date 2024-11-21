// Open singature links in table
$(document).on('click', '.signature-link', function(e) {
    e.preventDefault();
    var id = $(this).attr('id');
    Shiny.setInputValue('clicked_signature', id, {priority: 'event'});
});

// Handle URLs inside the app
$(document).ready(function() {
    var urlParams = new URLSearchParams(window.location.search);
    var tabName = urlParams.get('tab');
    var anchor = urlParams.get('anchor');
    
    if (tabName) {
        $('a[data-value=\"' + tabName + '\"]').tab('show');
        if (anchor) {
            setTimeout(function() {
                var element = $('#' + anchor);
                if (element.length) {
                    $('html, body').animate({
                        scrollTop: element.offset().top
                    }, 500);
                }
            }, 300);
        }
    }
    
    // Update URL when changing tabs
    $('a[data-toggle=\"tab\"]').on('shown.bs.tab', function (e) {
        var tabName = $(e.target).attr('data-value');
        var newUrl = updateUrlParameter(window.location.href, 'tab', tabName);
        newUrl = updateUrlParameter(newUrl, 'anchor', null);
        history.pushState(null, '', newUrl);
    });
});

// Use in combination with the function above
function updateUrlParameter(url, param, value) {
    var regex = new RegExp('([?&])' + param + '=.*?(&|$)', 'i');
    var separator = url.indexOf('?') !== -1 ? '&' : '?';
    if (url.match(regex)) {
        return value ? url.replace(regex, '$1' + param + '=' + value + '$2') : url.replace(regex, '$1').replace(/&$/, '');
    } else {
        return value ? url + separator + param + '=' + value : url;
    }
}

// Clossing tabs opened in resuts
$(document).on('click', '.close-tab', function(e) {
    e.preventDefault();
    e.stopPropagation();  // Prevent event from bubbling up
    var tabId = $(this).closest('li').find('a').attr('data-value');
    Shiny.setInputValue('close_tab', tabId, {priority: 'event'});
});

// Deactivate Exact in BugSigDB options when two or more ranks are selected
$(document).on('shiny:inputchanged', function(event) {
    if (event.name === 'bsdb_rank') {
        const checkedCount = $('input[name=\"bsdb_rank\"]:checked').length; 
        if (checkedCount > 1) {
            $('input[name=\"bsdb_exact\"][value=\"FALSE\"]').prop('disabled', true);
            $('input[name=\"bsdb_exact\"][value=\"TRUE\"]').prop('checked', true);
        } else {
            $('input[name=\"bsdb_exact\"][value=\"FALSE\"]').prop('disabled', false);
        }
    }
});

// This is for the reset button
Shiny.addCustomMessageHandler('resetURL', function(message) {
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        window.history.replaceState({}, document.title, '/');
    } else {
        window.history.replaceState({}, document.title, 'https://shiny.sph.cuny.edu/BugSigDBEnrich/');
    }
});


// Deactivate semantic
$(document).on('shiny:inputchanged', function(event) {
    if (event.name === 'bsdb_type' || event.name === 'bugphyzz_type') {
        const value = event.value;
        if (value !== 'ncbi') {
            $('input[name=\"semantic\"][value=\"TRUE\"]').prop('disabled', true);
            $('input[name=\"semantic\"][value=\"FALSE\"]').prop('checked', true);
        } else {
            $('input[name=\"semantic\"][value=\"TRUE\"]').prop('disabled', false);
        }
    }
});
