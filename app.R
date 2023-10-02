library(shiny.react)
library(jsonlite)

json_data <- fromJSON("./data.json")

CustomComponents <- tags$script(HTML("(function() {
  const React = jsmodule['react'];
  const ReactDOMServer = jsmodule['react-dom'];
  const Shiny = jsmodule['@/shiny'];
  const CustomComponents = jsmodule['CustomComponents'] ??= {};

  CustomComponents.ReactComponent = function(props) {
   const {data} = props;
    return  React.createElement('div', {style:{backgroundColor:data[0].color , padding:'20px'}}, [
      React.createElement('h1', null, data[0].name),
      React.createElement('p', null, data[0].city)
    ])
   
  };
})()"))

ReactComponent <- function(...) {
  shiny.react::reactElement(
    module = "CustomComponents",
    name = "ReactComponent",
    props = shiny.react::asProps(...),
  )
}

ui<- function(id) {
  ns <- NS(id)
   bootstrapPage(
    tagList(CustomComponents),
    navbarPage(
      title = "Dynamic Shiny.React App",
      windowTitle = "Dynamic Shiny React App",
    ),
    div(
      class = "container",
      fluidRow(
          column(
              width = 3,
              wellPanel(
                selectInput(ns("person"), label = "Choose person", choices = unique(json_data$name))
             )
          ),
          column(
              width = 9,
              div(
                  reactOutput(ns("reactComponent"))
              )
          )
      )
    )
)
}



server <- function(id) {
  moduleServer(id, function(input, output, session) {
    dataVal <- reactiveVal()

    observeEvent(input$person, {
      selected_data <- json_data[json_data$name == input$person, ]
      dataVal(selected_data)
    })
    output$reactComponent<- renderReact({
        ReactComponent(data = dataVal())
      })
  })

}

if (interactive()) {
  shinyApp(ui("app"), function(input, output) server("app"))
}