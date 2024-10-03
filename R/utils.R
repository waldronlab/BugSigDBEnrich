
.getBsdbId <- function(signame)  {
    stringr::str_extract(signame, "^bsdb:\\d+/\\d+/\\d+")
}

## Button for going to the top
topButtonShape <- function() {
    "  
      /* Floating button style */
      #top_button {
        position: fixed;
        justify-content: center;
        align-items: center;
        bottom: 30px;
        right: 30px;
        z-index: 99;
        background-color: #e95420;
        color: white;
        border: none;
        width: 50px;   /* Set width */
        height: 50px;  /* Set height */
        padding: 10px 15px;
        border-radius: 50%;
        font-size: 30px;
        font-weight: bold;
        cursor: pointer;
        padding: 0; /* Remove padding to ensure perfect centering */
      }
    "
}

## Button for going to the top
topButtonAction <- function() {
    "
        // Function to scroll to the top
        function scrollToTop() {
            window.scrollTo({top: 0, behavior: 'smooth'});
        }
    "
}

labelTextBox <- function() {
    stringr::str_c(
        "Enter list of NCBI taxids, taxon names, or metaphlan names:"
    )
}

rankOptions <- function() {
    c(
        "kingdom", "phylum", "class", "order",
        "family", "genus", "species", "strain"
    )
}
