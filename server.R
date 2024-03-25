library(shiny)
library(readxl)
library(stringr)

server <- function(input, output) {
  originalFileContent <- reactiveVal(NULL)
  
  observeEvent(input$file, {
    req(input$file)
    fileContent <- read_file(input$file$datapath)
    originalFileContent(fileContent)
    
    output$contents <- renderTable({
      data.frame(Content = originalFileContent())
    })
    
    save_file(fileContent, "/home/juan/shiny_email/input.txt")
  })
  
  # Exponer el contenido del archivo cargado
  loadedFileContent <- reactive({
    originalFileContent()
  })
  
  # Asignar el contenido del archivo cargado a un valor global
  globalFileContent <<- loadedFileContent
}

read_file <- function(file_path) {
  # ... (código sin cambios)
}

save_file <- function(fileContent, file_path) {
  # ... (código sin cambios)
}