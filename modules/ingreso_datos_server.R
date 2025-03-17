# modules/ingreso_datos_server.R

ingreso_datos_server <- function(id, central_conn = NULL, selected_submodule) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$faena_form <- renderUI({
      req(selected_submodule())
      tagList(
        textInput(ns("registro"), "Registro"),
        actionButton(ns("save_button"), "Guardar")
      )
    })

    output$faena_table <- renderDT({
      req(input$faena_table_data)  # Esperar datos desde IndexedDB
      input$faena_table_data       # Mostrar datos dinámicos
    })

    observeEvent(input$save_button, {
      # Preparar datos para guardar
      form_data <- list(
        registro = input$registro,
        Sincronizado = 0  # Estado inicial: no sincronizado
      )
      print("Guardando datos de faena en IndexedDB:", form_data)

      # Guardar en IndexedDB
      session$sendCustomMessage("saveData", list(table = "faena_principal", data = form_data))

      # Intentar sincronizar con Neon si hay conexión
      if (!is.null(central_conn)) {
        tryCatch({
          form_df <- data.frame(registro = input$registro, Sincronizado = 0, stringsAsFactors = FALSE)
          dbWriteTable(central_conn, "faena_principal", form_df, append = TRUE)
          print("Datos guardados en Neon:", form_df)

          # Actualizar estado de sincronización en IndexedDB
          session$sendCustomMessage("updateSyncStatus", list(table = "faena_principal", registro = input$registro, Sincronizado = 1))
        }, error = function(e) {
          print("Error al guardar en Neon:", e$message)
        })
      } else {
        print("No hay conexión a Neon; datos guardados solo en IndexedDB.")
      }
    })
  })
}
