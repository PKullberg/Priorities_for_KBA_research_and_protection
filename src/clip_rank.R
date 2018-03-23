### KBA_priority project: clip rank function
# Author: Peter Kullberg, peter.kullberg@helsinki.fi

# Make clipped rank maps (rescaled priority for unprotected KBAs), trying to avoid tempfiles
clip_rank <- function(ir, br, path, m_value = NA) {
  if (missing(path)) {
    path <- sub("rank.compressed", "rank.compressed.KBA_rescaled", slot(ir@file, "name"))
  }
  temp_path <- sub("rank.compressed", "temp", slot(ir@file, "name"))
  
  cr <- mask(ir, br, maskvalue = m_value, updatevalue = NA, filename = path, options = "compression = deflate", format = "GTiff", overwrite = T)
  min_v <- min(cr[], na.rm = T)
  cr0 <- calc(cr,  fun = function(x) x - min_v,  filename = temp_path, options = "compression = deflate", format = "GTiff", overwrite = T)
  max_v <- max(cr0[], na.rm = T)
  scr <- calc(cr0,  fun = function(x) x / max_v,  filename = path, options = "compression = deflate", format = "GTiff", overwrite = T)
  
  system(paste("rm", temp_path))
  
  return(scr)
}