stata_collectcode <- function() {
  # Message when Statamarkdown loads
  if (file.exists(file.path(dirname(find_stata(message=FALSE)), "sysprofile.do"))) {
    message("Found a 'sysprofile.do'")
  }
  if (file.exists(file.path(dirname(find_stata(message=FALSE)), "profile.do"))) {
    message("Found a 'profile.do' in the STATA executable directory.")
    message("  This prevents 'collectcode' from working.")
    message("  Please rename this 'sysprofile.do'.")
  }
  if (file.exists("profile.do")){
#    print(sys.frames())
#    print(sys.calls())
#    print(sys.nframe())
    assign("oprofile", readLines("profile.do", encoding="UTF-8"), pos=2)
#    oprofile <- readLines("profile.do")
    message("Found an existing 'profile.do'")
    message(paste("  ", oprofile, "\n"))
  }
  else {
    oprofile <- NULL
  }
  # Hook for code processing
  knitr::knit_hooks$set(collectcode = function(before, options, envir) {

    if (!before) {
        if (options$engine == "stata") {
#          print(options$engine.path$stata)
          if (file.exists(file.path(dirname(options$engine.path$stata), "profile.do"))) {
            message("Found a 'profile.do' in the STATA executable directory.")
            message("  This prevents 'collectcode' from working properly.")
            message("  Please rename this 'sysprofile.do'.")
          }
            autoexec <- file("profile.do", open="at")
            writeLines(options$code, autoexec, useBytes=T)
            close(autoexec)
#            print(sys.frames())
#            print(sys.calls())
        # 加入這個複製整個檔案
        # do.call("on.exit",
        #    list(quote(file.copy("profile.do",basename(tempfile(pattern="allcode", tmpdir=".", fileext=".do")),TRUE)), add=TRUE),
        #            envir = sys.frame(-9))
        do.call("on.exit",  list( quote(unlink("profile.do")), add=TRUE),
            envir = sys.frame(-9))
        if (!is.null(oprofile)) {
            do.call("on.exit",
                list(quote(writeLines(oprofile, "profile.do", useBytes=T)), add=TRUE),
                envir = sys.frame(-9))
        }
            # sys.frame(1) or sys.frame(-10) is rmarkdown::render()
            # sys.frame(-9) is knitr::knit()
        }
    }
})
}
