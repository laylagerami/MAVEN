# UI
source("sub/global.R")

ui = function(request) {
  fluidPage(
    useShinyjs(),
    navbarPage(theme=shinytheme("flatly"),
      title="MAVEN",
      footer = column(12, align="center", "MAVEN-App 2021 (version: 0.1)"),
      source("sub/01_ui_data.R")$value,
      source("sub/02_ui_targets.R")$value,
      hr()
    ) # close navbarPage
  ) # close fluidPage
}