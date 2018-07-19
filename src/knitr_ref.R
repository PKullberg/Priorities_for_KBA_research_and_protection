# Helpper functions for using cross references in knitr
# Credits: Peter Humburg, "Using knitr and pandoc to create reproducible scientific reports" 
# http://galahad.well.ox.ac.uk/repro/#keeping-track-of-references

# function for crosreferencec to figures
figRef <- local({
  tag <- numeric()
  created <- logical()
  used <- logical()
  function(label, caption, prefix = options("figcap.prefix"), 
           sep = options("figcap.sep"), prefix.highlight = options("figcap.prefix.highlight")) {
    i <- which(names(tag) == label)
    if (length(i) == 0) {
      i <- length(tag) + 1
      tag <<- c(tag, i)
      names(tag)[length(tag)] <<- label
      used <<- c(used, FALSE)
      names(used)[length(used)] <<- label
      created <<- c(created, FALSE)
      names(created)[length(created)] <<- label
    }
    if (!missing(caption)) {
      created[label] <<- TRUE
      paste0(prefix.highlight, prefix, " ", i, sep, prefix.highlight, 
             " ", caption)
    } else {
      used[label] <<- TRUE
      paste(prefix, tag[label])
    }
  }
})

options(figcap.prefix = "Figure", figcap.sep = ":", figcap.prefix.highlight = "**")

# function for crosreferencec to tables
tabRef <- local({
  tag <- numeric()
  created <- logical()
  used <- logical()
  function(label, caption, prefix = options("tabcap.prefix"), 
           sep = options("tabcap.sep"), prefix.highlight = options("tabcap.prefix.highlight")) {
    i <- which(names(tag) == label)
    if (length(i) == 0) {
      i <- length(tag) + 1
      tag <<- c(tag, i)
      names(tag)[length(tag)] <<- label
      used <<- c(used, FALSE)
      names(used)[length(used)] <<- label
      created <<- c(created, FALSE)
      names(created)[length(created)] <<- label
    }
    if (!missing(caption)) {
      created[label] <<- TRUE
      paste0(prefix.highlight, prefix, " ", i, sep, prefix.highlight, 
             " ", caption)
    } else {
      used[label] <<- TRUE
      paste(prefix, tag[label])
    }
  }
})



# this should check tha all references exists. I added te funtion part, chekc that it works like this.
chechk_captions <- function() {
  if (!all(environment(figRef)$created)) {
    missingFig <- which(!environment(figRef)$created)
    warning("Figure(s) ", paste(missingFig, sep = ", "), " with label(s) '", 
            paste(names(environment(figRef)$created)[missingFig], 
                  sep = "', '"), "' are referenced in the text but have never been created.")
  }
  if (!all(environment(figRef)$used)) {
    missingRef <- which(!environment(figRef)$used)
    warning("Figure(s) ", paste(missingRef, sep = ", "), " with label(s) '", 
            paste(names(environment(figRef)$used)[missingRef], sep = "', '"), 
            "' are present in the document but are never referred to in the text.")
  }
}