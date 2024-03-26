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
    
    email_pattern <- "\\S+@\\S+"
    
    # Initialise the email list
    correos <- c()
    
    # Patterns on the column name
    nombres_columnas <- "\\S+email\\S+|\\S+correo\\S+|\\S+mail\\S+" # Patterns to search for in the column names
    
    # Iterate over all columns of the sheet
    for (col_name in names(data_sheet)) {
      # Check if the column name contains the email pattern
      if (str_detect(tolower(col_name), nombres_columnas)) {
        # Extract the emails from the column
        correos_raw = na.omit(as.character(data_sheet[[col_name]]))
        
        # Search for emails in each entry and add them to the email list
        for (entry in correos_raw) {
          correos_found <- str_extract_all(entry, email_pattern)[[1]]
          correos <- c(correos, correos_found)
        }
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
  })
}