#' Extract Text from PDF Resume
#'
#' @param file_path Character. Path to the PDF file.
#' @return Character. The extracted text.
#' @export
extract_text_from_pdf <- function(file_path) {
  if (!file.exists(file_path)) {
    stop(paste("File does not exist at path:", file_path))
  }
  
  # Ensure it is a PDF file
  if (tolower(tools::file_ext(file_path)) != "pdf") {
    stop("Input file is not a PDF.")
  }
  
  text <- tryCatch({
    # Use pdftools to extract text page by page
    pages <- pdftools::pdf_text(file_path)
    # Combine all pages into a single string
    combined_text <- paste(pages, collapse = "\n")
    combined_text
  }, error = function(e) {
    warning(paste("pdftools failed to extract text from PDF:", e$message))
    
    # Fallback to readtext if available
    fallback_text <- tryCatch({
      if (requireNamespace("readtext", quietly = TRUE)) {
        doc <- readtext::readtext(file_path)
        doc$text
      } else {
        stop("readtext package not available for fallback.")
      }
    }, error = function(e_fallback) {
      stop(paste("Failed to extract text from PDF using pdftools and fallback readtext:", 
                 e_fallback$message))
    })
    fallback_text
  })
  
  # Remove null characters or formatting glitches
  text <- gsub("\\x00", "", text)
  
  return(text)
}

#' Extract PDF Metadata
#'
#' @param file_path Character. Path to the PDF file.
#' @return List. Info like page count, author, creation date.
#' @export
extract_pdf_metadata <- function(file_path) {
  if (!file.exists(file_path)) {
    return(list(pages = 0, author = "Unknown", created = NA))
  }
  
  meta <- tryCatch({
    info <- pdftools::pdf_info(file_path)
    list(
      pages = info$pages,
      author = ifelse(is.null(info$keys$Author), "Unknown", info$keys$Author),
      created = info$created,
      modified = info$modified
    )
  }, error = function(e) {
    # Fallback
    list(pages = 1, author = "Unknown", created = NA)
  })
  
  return(meta)
}
