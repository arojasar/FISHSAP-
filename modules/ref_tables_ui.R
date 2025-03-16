# modules/ref_tables_ui.R

library(shiny)
library(DT)

ref_tables_ui <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(ns("ref_table_output")),
    uiOutput(ns("ref_form"))
  )
}



##ref_tables_ui <- function(id) {
 # ns <- NS(id)
  
 # tagList(
   # DTOutput(ns("ref_table_output")),
    #actionButton(ns("new_ref_btn"), "Nuevo", icon = icon("plus")),
    #actionButton(ns("edit_ref_btn"), "Modificar", icon = icon("edit")),
    #actionButton(ns("delete_ref_btn"), "Borrar", icon = icon("trash")),
    
    # Formulario dinámico (controlado por JavaScript)
    #uiOutput(ns("ref_form_ui"))
 # )
#}
##

