# modules/ingreso_datos_ui.R

library(shiny)
library(DT)

ingreso_datos_ui <- function(id) {
  ns <- NS(id) # Crear espacio de nombres para el módulo
  tagList(
    uiOutput(ns("faena_form")), # Usar ns() para el output
    DTOutput(ns("faena_table")) # Usar ns() para el output
  )
}


# modules/ingreso_datos_ui.R

#ingreso_datos_ui <- function(id) {
  #ns <- NS(id)
 # 
 # tagList(
  #  uiOutput(ns("submodule_ui"))
 # )
#}