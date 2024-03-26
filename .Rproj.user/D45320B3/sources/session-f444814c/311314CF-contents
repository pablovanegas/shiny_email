library(shiny)
library(readxl)
library(stringr)

server <- function(input, output) {
  # Store the original file content
  originalFileContent <- reactiveVal(NULL)
  
  # Observe file upload
  observeEvent(input$file, {
    req(input$file) # Read the file content
    
    data_sheet <- read_excel(input$file$datapath)
    
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
