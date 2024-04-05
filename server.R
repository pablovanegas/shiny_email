library(shiny)
library(readxl)
library(stringr)

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
                        "XML" = "xml",
                        "TXT" = 'txt')
    
    # Read the file based on its type
    data_sheet <- switch(file_type,
                         "csv" = read.csv(input$file$datapath, sep = input$csv_sep),  # Use the user-specified delimiter for CSV files
                         "xlsx" = read_xlsx(input$file$datapath, sheet = input$excel_sheet),  # Use the user-specified sheet for Excel files
                         "txt" = read.table(input$file$datapath, sep = input$txt_sep),  # Use the user-specified delimiter for TXT files
                         "sql" = read_sql(input$file$datapath),  # No adjustments needed for SQL files
                         "xml" = read_xml(input$file$datapath))  # No adjustments needed for XML files

    # Verify the file extension
    file_ext <- tools::file_ext(input$file$name)
    
    # Check if the file extension is valid
    if (tolower(file_ext) != tolower(input$file_type)) {
      # If not, show an error message and stop the execution
      showModal(modalDialog(
        title = "Error",
        "The file extension does not match the selected file type. Please select the correct file type or upload a file with the correct extension.",
        easyClose = TRUE
      ))
      return()  # Use return() instead of stop()
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
        # Extract the emails from the column
        correos_raw = na.omit(as.character(data_sheet[[col_name]]))
        
        # Search for emails in each entry and add them to the email list
        for (entry in correos_raw) {
          correos_found <- str_extract_all(entry, email_pattern)[[1]]
          correos <- c(correos, correos_found)
        }
      }
      
      # Update the reactive value with the emails found
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
          paste(tools::file_path_sans_ext(input$file$name), "_emails", ".txt", sep = "")
        },
        content = function(file) {
          writeLines(as.character(originalFileContent()), con = file)
        }
      )
    }) # End of observeEvent
  }) # End of observeEvent
} # End of server function
