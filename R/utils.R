
.getID <- function(signame)  {
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
    # box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
      # top_button:hover {
      #   background-color: #0056b3;
      # }
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