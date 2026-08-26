files <- list.files("scripts", pattern = "\\.R$", full.names = TRUE)
for (f in files) {
  raw <- readBin(f, "raw", file.info(f)$size)
  has_nul <- any(raw == as.raw(0))
  cat(f, "-", if (has_nul) "HAS NUL" else "OK", "\n")
  if (has_nul) {
    # Remove NUL bytes and rewrite
    clean <- raw[raw != as.raw(0)]
    writeBin(clean, f)
    cat("  -> Fixed:", f, "\n")
  }
}
cat("Scan complete.\n")
