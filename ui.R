ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  titlePanel("Email Extractor: "),
  
  sidebarLayout(
    
    sidebarPanel(
      helpText("Please select the file type first, then upload your file."),
      selectInput("file_type", "Choose File Type:", choices = c("CSV", "XLSX","TXT")),
      fileInput("file", "Choose a File", accept = c("text/csv", "text/xlsx", "text/sql", ".csv", ".xlsx", ".txt")),
      
      conditionalPanel(
        condition = "input.file_type == 'CSV'",
        selectInput("csv_sep", "CSV Separator:", choices = c("Comma" = ",", "Semicolon" = ";", "Tab" = "\t", "Space" = " ", "Other" = "Other")),
        textInput('csv_other', 'Other Separator:', ',')
      ),
    
      conditionalPanel(
        condition = "input.file_type == 'XLSX'",
        numericInput("excel_sheet", "Excel Sheet Number:", 1)
      ),
      
      uiOutput("checkbox_group"), 
      downloadButton("Download", "Download xlsx", icon = icon("download")),
      downloadButton("Download2", "Download txt", icon = icon("download"))
    ), # End of sidebarPanel
    # Show the content of the file
    mainPanel(
      tableOutput("contents")
    ) # End of mainPanel
  ), # End of sidebarLayout
  #tuturial panel
  mainPanel(
    h2("Tuturial:"),
    p("This app is designed to extract email addresses from different file types."),
    p("Please select the file type first, then upload your file."),
    p("If you choose CSV or TXT, you can select the separator."),
    p("If you choose XLSX, you can input the sheet number."),
    p("#If you choose SQL, you can input the table name."),
    p("After you upload the file, you can download the extracted email addresses in xlsx and txt format.")
  ) # End of mainPanel
)  # End of fluidPage
