# modules/ingreso_datos_server.R

library(shiny)
library(DT)

ingreso_datos_server <- function(id, central_conn, submodule) {
  moduleServer(id, function(input, output, session) {
    message("Entrando en ingreso_datos_server para ID: ", id)
    
    output$faena_table <- renderDT({
      message("Renderizando tabla en ingreso_datos_server dentro de renderDT...")
      datatable(data.frame(Test = c("Faena 1", "Faena 2")), options = list(pageLength = 5))
    })
    
    output$faena_form <- renderUI({
      message("Renderizando formulario en ingreso_datos_server dentro de renderUI...")
      tagList(
        h4("Ingreso de Datos de Faena"),
        textInput("registro_input", "Registro"),
        actionButton("save_button", "Guardar", icon = icon("save"))
      )
    })
    
    message("Saliendo de ingreso_datos_server para ID: ingreso_datos")
  })
}