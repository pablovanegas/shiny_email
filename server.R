library(shiny)
library(readxl)
library(stringr)
library(openxlsx)  

ui <- fluidPage(
  # Your UI components here
)

server <- function(input, output) {
  # Store the original file content
  originalFileContent <- reactiveVal(NULL)
  
  observeEvent(input$file, {
    req(input$file) # Read the file content
    
    file_type <- switch(input$file_type,
                        "CSV" = "csv",
                        "XLSX" = "xlsx",
                        "TXT" = 'txt')
    
    data_sheet <- tryCatch(
      switch(file_type,
             "csv" = {
               sep <- if (input$csv_sep != "Other") input$csv_sep else input$csv_other
               read.csv(input$file$datapath, sep = sep)
             },
             "xlsx" = {
               tryCatch(
                 read_xlsx(input$file$datapath, sheet = input$excel_sheet),
                 error = function(e) {
                   showModal(modalDialog(
                     title = "Error",
                     "La hoja de Excel especificada no existe en el archivo subido. Por favor, selecciona una hoja válida.",
                     easyClose = TRUE
                   ))
                   return(NULL)
                 }
               )
             },
             "txt" = {
               readLines(input$file$datapath)
             }
      ),
      error = function(e) {
        showModal(modalDialog(
          title = "Error",
          "El archivo no se pudo leer. Por favor, verifica que el archivo sea válido y que el tipo de archivo seleccionado sea correcto.",
          easyClose = TRUE
        ))
        return(NULL)
      }
    )
    
    file_ext <- tools::file_ext(input$file$name)
    
    if (tolower(file_ext) != tolower(input$file_type)) {
      showModal(modalDialog(
        title = "Error",
        "The file extension does not match the selected file type. Please select the correct file type or upload a file with the correct extension.",
        easyClose = TRUE
      ))
      return()
    }
    
    email_pattern <- "([_a-z0-9-]+(?:\\.[_a-z0-9-]+)*@[a-z0-9-]+(?:\\.[a-z0-9-]+)*(?:\\.[a-z]{2,63}))"
    
    correos <- c()
    
    switch(file_type,
           "csv" = {
             data_sheet <- read.csv(input$file$datapath, sep = sep)
             
             observeEvent(input$columns, {
               req(input$columns)
               for (col_name in input$columns) {
                 correos_raw <- na.omit(as.character(data_sheet[[col_name]]))
                 
                 for (entry in correos_raw) {
                   correos_found <- str_extract_all(entry, email_pattern)[[1]]
                   correos <- unique(c(correos, correos_found))
                 }
               }
               originalFileContent(correos)
               
               output$contents <- renderTable({
                 data.frame(Content = originalFileContent())
               })
             })
           },
           "xlsx" = {
             data_sheet <- read_xlsx(input$file$datapath, sheet = input$excel_sheet)
             
             observeEvent(input$columns, {
               req(input$columns)
               for (col_name in input$columns) {
                 correos_raw <- na.omit(as.character(data_sheet[[col_name]]))
                 
                 for (entry in correos_raw) {
                   correos_found <- str_extract_all(entry, email_pattern)[[1]]
                   correos <- unique(c(correos, correos_found))
                 }
               }
               originalFileContent(correos)
               
               output$contents <- renderTable({
                 data.frame(Content = originalFileContent())
               })
             })
           },
           "txt" = {
             data_sheet <- readLines(input$file$datapath)
             emails <- unlist(regmatches(data_sheet, gregexpr(email_pattern, data_sheet)))
             originalFileContent(unique(emails))
             output$contents <- renderTable({
               data.frame(Content = originalFileContent())
             })
           }
    )
    
    save_file <- function() {
      file.copy(input$file$datapath, "/home/juan/Desktop/shiny_email")
    }
    
    output$Download <- downloadHandler(
      filename = function() {
        paste(tools::file_path_sans_ext(input$file$name), "_emails", ".xlsx", sep = "")
      },
      content = function(file) {
        emails_df <- data.frame(Emails = as.character(originalFileContent()))
        write.xlsx(emails_df, file)
      }
    )
    
    output$Download2 <- downloadHandler(
      filename = function() {
        paste(tools::file_path_sans_ext(input$file$name), "_emails", ".txt", sep = "")
      },
      content = function(file) {
        write.table(originalFileContent(), file)
      }
    )
    
  }) # End of observeEvent of file upload
} # End of server function