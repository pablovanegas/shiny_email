library(shiny)
library(readr)
library(stringr)

ui <- fluidPage(
  
  titlePanel("File Upload"),
  
  sidebarLayout(
    
    sidebarPanel(
      fileInput("file", "Choose a File", accept = c("text/csv", "text/xlsx", "text/sql", "text/xml", ".csv", ".xlsx", ".sql", ".xml", ".txt")),
      downloadButton("Download", "Download Document")
    ), # End of sidebarPanel
    # Show the content of the file
    mainPanel(
      tableOutput("contents")
    ) # End of mainPanel
  ) # End of sidebarLayout
)  # End of fluidPage
