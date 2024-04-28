
  library(shiny)
  library(readxl)
  library(stringr)
  library(openxlsx)  
  
  extract_mails <- function(file_path){
    myText <- readLines(file_path)
    
    email_regex <- "([_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,63}))"
    
    emails <- unlist(regmatches(myText, gregexpr(email_regex, myText)))
    
    return(emails)
  }
  
  server <- function(input, output) {
    
    # Store the original file content
    originalFileContent <- reactiveVal(NULL)
    
    # Observe file upload
    observeEvent(input$file, {
      req(input$file) # Read the file content
      
      # Determine the file type
      file_type <- switch(input$file_type,
                          "CSV" = "csv",
                          "XLSX" = "xlsx",
                          "SQL" = "sql",
                          "TXT" = 'txt')
      
      # Read the file based on its type
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
                 if (input$txt_checkbox) {
                   read.table(input$file$datapath, sep = input$txt_sep)
                 } else {
                   extract_mails(input$file$datapath)
                 }
               },
               "sql" = read_sql(input$file$datapath)),
        error = function(e) {
          showModal(modalDialog(
            title = "Error",
            "El archivo no se pudo leer. Por favor, verifica que el archivo sea válido y que el tipo de archivo seleccionado sea correcto.",
            easyClose = TRUE
          ))
          return(NULL)
        }
      )
      
      # Verify the file extension
      file_ext <- tools::file_ext(input$file$name)
      
      # Check if the file extension is valid
      if (tolower(file_ext) != tolower(input$file_type)) {
        showModal(modalDialog(
          title = "Error",
          "The file extension does not match the selected file type. Please select the correct file type or upload a file with the correct extension.",
          easyClose = TRUE
        ))
        return()
      }
      
      # Create checkbox group
      output$checkbox_group <- renderUI({
        checkboxGroupInput("columns", "Select columns:", choices = names(data_sheet))
      })
      
      email_pattern <- "\\S+@\\S+"
      
      # Initialise the email list
      correos <- c()
      
      # Observe column selection
      observeEvent(input$columns, {
        req(input$columns)
        
        # Iterate over selected columns of the sheet
        for (col_name in input$columns) {
          correos_raw = na.omit(as.character(data_sheet[[col_name]]))
          
          for (entry in correos_raw) {
            correos_found <- str_extract_all(entry, email_pattern)[[1]]
            correos <- c(correos, correos_found)
          }
        }
        
        originalFileContent(correos)
        
        output$contents <- renderTable({
          data.frame(Content = originalFileContent())
        })
        
        # Save the file
        save_file <- function() {
          file.copy(input$file$datapath, "/home/juan/Desktop/shiny_email")
        }
        
        # Download handler
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
        
      }) # End of observeEvent of column selection
    }) # End of observeEvent of file upload
  } # End of server function