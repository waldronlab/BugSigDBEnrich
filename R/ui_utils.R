
urlHandler <- function() {
    ## This function requires the urlHandlerServer function
    htmltools::tags$head(
        htmltools::tags$script(htmltools::HTML("
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

      function updateUrlParameter(url, param, value) {
        var regex = new RegExp('([?&])' + param + '=.*?(&|$)', 'i');
        var separator = url.indexOf('?') !== -1 ? '&' : '?';
        if (url.match(regex)) {
          return value ? url.replace(regex, '$1' + param + '=' + value + '$2') : url.replace(regex, '$1').replace(/&$/, '');
        } else {
          return value ? url + separator + param + '=' + value : url;
        }
      }
    "))
    )
}

helpIcon <- function(inputId) {
    shiny::actionLink(
        inputId = inputId,
        label = bsicons::bs_icon("question-circle")
    ) 
}
