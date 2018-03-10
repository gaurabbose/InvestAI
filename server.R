library(shiny)
source("code.R")
# Define server logic for slider examples
shinyServer(function(input, output) {

#to make changes to vars - 1) change input fields, 2)change server.R fields, 3) code.R clean, create new vars and change total.var value

  inputvals <- reactive({
    calc(c(input$price,input$YTD,input$age,input$er,input$divyield,input$peratio, input$beta),
         c(input$price.weight,input$ytd.weight,input$age.weight,input$er.weight,input$divyield.weight, input$peratio.weight,input$beta.weight),
         c(input$yourage, input$yourincome, input$invgoals))})
  
  # Show the values using an HTML table
  output$main <- renderTable({
    inputvals()
    })
  
  
    observeEvent(input$optimize, 
                 output$optimizedTable <- renderTable({
                   optimizeResults(inputvals(), c(input$yourage, input$yourincome, input$invgoals))}))

    
    observeEvent(input$start, {
      

      insertUI(
        selector = "#start",
        where = "afterEnd",
        ui = tagList(textInput("response", "Enter Response"),
          h3(textOutput("THIS IS MY RESPONSE")))
      )
      

    })
   

})


    


