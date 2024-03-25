library(shiny)
library(readxl)
library(stringr)

ui <- fluidPage(
  titlePanel("File Upload"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose a File", accept = c("text/csv", "text/xlsx", "text/sql", "text/xml", ".csv", ".xlsx", ".sql", ".xml", ".txt"))
    ),
    mainPanel(
      tableOutput("contents"),
      textOutput("columnNames")
    )
  )
)