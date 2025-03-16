# modules/captura_esfuerzo.R

captura_esfuerzo_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    DTOutput(ns("faena_table_output")),
    actionButton(ns("new_faena_btn"), "Nueva Faena", icon = icon("plus")),
    actionButton(ns("edit_faena_btn"), "Modificar Faena", icon = icon("edit")),
    actionButton(ns("delete_faena_btn"), "Borrar Faena", icon = icon("trash")),
    
    uiOutput(ns("faena_form_ui"))
  )
}

captura_esfuerzo_server <- function(input, output, session, central_conn) {
  ns <- session$ns
  
  # --- Mostrar tabla de Faenas ---
  output$faena_table_output <- renderDT({
    session$sendCustomMessage("loadTableData", list(table = "faena_principal"))
    NULL
  })
  
  # --- Formulario para agregar/editar faenas ---
  output$faena_form_ui <- renderUI({
    selected_row <- input$faena_table_output_rows_selected
    if (is.null(selected_row) && input$edit_faena_btn > 0) {
      return(NULL)
    }
    
    session$sendCustomMessage("showForm", list(
      table = "faena_principal",
      action = ifelse(input$edit_faena_btn > 0, "edit", "new"),
      selectedRow = ifelse(is.null(selected_row), -1, selected_row)
    ))
    
    NULL
  })
  
  # --- Guardar datos ---
  observeEvent(input$save_faena_btn, {
    session$sendCustomMessage("saveData", list(
      table = "faena_principal",
      data = session$userData$tempFormData
    ))
  })
}