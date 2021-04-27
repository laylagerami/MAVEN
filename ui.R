# UI
source("sub/global.R")

ui = function(request) {
  fluidPage(
    useShinyjs(),
    navbarPage(theme=shinytheme("sandstone"),
      title="MAVEN",
      footer = column(12, align="center", "MAVEN-App 2021 (version: 0.1)"),
      source("sub/00_ui_welcome.R")$value,
      source("sub/01_ui_data.R")$value,
      source("sub/02_ui_targets.R")$value,
      source("sub/03_ui_analysis.R")$value,
      source("sub/04_ui_vis.R")$value,
      hr()
    ) # close navbarPage
  ) # close fluidPage
}