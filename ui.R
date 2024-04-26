ui <- fluidPage(
  
  titlePanel("Email Extractor: "),
  
  sidebarLayout(
    
    sidebarPanel(
      helpText("Please select the file type first, then upload your file."),
      selectInput("file_type", "Choose File Type:", choices = c("CSV", "XLSX","SQL", "XML","TXT")),
      fileInput("file", "Choose a File", accept = c("text/csv", "text/xlsx", "text/sql", "text/xml", ".csv", ".xlsx", ".sql", ".xml", ".txt")),
      
      conditionalPanel(
        condition = "input.file_type == 'CSV'",
        selectInput("csv_sep", "CSV Separator:", choices = c("Comma" = ",", "Semicolon" = ";", "Tab" = "\t", "Space" = " ", "Other" = "Other")),
        textInput('csv_other', 'Other Separator:', ',')
      ),
    
      conditionalPanel(
        condition = "input.file_type == 'TXT'",
        textInput("txt_sep", "TXT Separator:", ",")
      ),
      
      conditionalPanel(
        condition = "input.file_type == 'XLSX'",
        numericInput("excel_sheet", "Excel Sheet Number:", 1
      )
      ),
      
      
      uiOutput("checkbox_group"), 
      downloadButton("Download", "Download xlsx", icon = icon("download")),
      downloadButton("Download2", "Download txt", icon = icon("download"))
    ), # End of sidebarPanel
    # Show the content of the file
    mainPanel(
      tableOutput("contents")
    ) # End of mainPanel
  ) # End of sidebarLayout
)  # End of fluidPage
