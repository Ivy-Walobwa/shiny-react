library(shiny.react)

colors <- list("Gold", "Lavender", "Salmon")
selectedColor <- reactiveVal("Gold")

CustomComponents <- tags$script(HTML("(function() {
  const React = jsmodule['react'];
  const Shiny = jsmodule['@/shiny'];
  const CustomComponents = jsmodule['CustomComponents'] ??= {};

  CustomComponents.ReactComponent = function(props) {
    const {value} = props;
    return React.createElement('div', {className:'nav', style:{backgroundColor: value, height:'120px', padding:'20px'}},`You have selected the color ${value}.`)
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
                selectInput(ns("color"), label = "Background color", choices = colors),
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
    selectedColor <- reactiveVal("Gold")
    observeEvent(input$color, {
        selectedColor(input$color)
    })
    output$reactComponent<- renderReact({
        ReactComponent( value = selectedColor())
      })
  })

}

if (interactive()) {
  shinyApp(ui("app"), function(input, output) server("app"))
}