library(shiny)

shinyUI(fluidPage(theme = "bootstrap.min.css",
  
  title = "Welcome to InvestAI",
  
  #CHOOSE FIRST OPTION
  actionButton("manualoption", "Use the Hand's On ETF Tool (Advanced User)"),
  conditionalPanel(
    condition = "input.manualoption == true",

      fluidRow(
        column(3, id="personal",
               h2("InvestAI"),
               h4("A project by Gaurab Bose"),
               sliderInput('yourage', 'Your Age', 
                           min=21, max=90, value=50),
               textInput('yourincome', 'Your Annual Income'),
               selectInput('invgoals', 'Your Investment Goals', 
                           choices=c("Retirement Planning", "Life Events (i.e. College)", "Rainy Day Funds"))),
        column(3,
               sliderInput('price', 'Approx. ETF Price', 
                           min=1, max=350, value=100),
               sliderInput('price.weight', 'Relevance', 
                           min=0, max=3, value=2),
               hr(),
               sliderInput('YTD', 'YTD Return %', 
                           min=-20, max=20, value=5),
               sliderInput('ytd.weight', 'Relevance', 
                           min=0, max=3, value=2)),
        
        column(3,
               
               sliderInput('age', 'ETF Age', 
                           min=0, max=30, value=4),
               sliderInput('age.weight', 'Relevance', 
                           min=0, max=3, value=0),
               hr(),
               
               sliderInput('beta', 'Beta Value', 
                           min=-1, max=1, value=0.5),
               sliderInput('beta.weight', 'Relevance', 
                           min=0, max=3, value=0),
               hr(),
               
               sliderInput('er', 'Expense Ratio', 
                           min=0, max=5, value=1),
               sliderInput('er.weight', 'Relevance', 
                           min=0, max=3, value=0)
        ),
        column(3,
               sliderInput('divyield', 'Annual Dividend Yield', 
                           min=0, max=5, value=2),
               sliderInput('divyield.weight', 'Relevance', 
                           min=0, max=3, value=0),
               hr(),
               
               sliderInput('peratio', 'Approximate PE Ratio', 
                           min=0, max=70, value=15),
               sliderInput('peratio.weight', 'Importance', 
                           min=0, max=3, value=0)),
        hr(),
        tableOutput("main"),
        actionButton("optimize", "I'm Done, Optimize My Results"),
        tableOutput("optimizedTable")
        
      
    )),
  
  #SECOND OPTION
  actionButton("aioption", "Talk To Our Artificial Intelligence"),
  conditionalPanel(
    condition = "input.aioption == true",
    h4("Hi! My name is Charlie and I'm an expert on Exchange Traded Funds. I'm here to help you out. As I learn your objectives and preferences, I will be able to recommend the best ETFs for you. Are you ready?"),
    textInput("first", "Ready?"),
    actionButton("start", "SEND")
    )
  
  
))

# ===== MODULE PACKAGING =======
