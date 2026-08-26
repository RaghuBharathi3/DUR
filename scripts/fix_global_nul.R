f <- "global.R"
raw <- readBin(f, "raw", file.info(f)$size)
nul_pos <- which(raw == as.raw(0))
cat("NUL byte positions in global.R:", length(nul_pos), "\n")
if (length(nul_pos) > 0) {
  cat("Positions:", paste(nul_pos, collapse=", "), "\n")
  clean <- raw[raw != as.raw(0)]
  writeBin(clean, f)
  cat("Fixed global.R\n")
}

f2 <- "scripts/run_app.R"
raw2 <- readBin(f2, "raw", file.info(f2)$size)
nul_pos2 <- which(raw2 == as.raw(0))
cat("NUL byte positions in run_app.R:", length(nul_pos2), "\n")
if (length(nul_pos2) > 0) {
  clean2 <- raw2[raw2 != as.raw(0)]
  writeBin(clean2, f2)
  cat("Fixed run_app.R\n")
}

cat("Done.\n")
