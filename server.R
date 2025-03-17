# server.R

library(shiny)

server <- function(input, output, session) {
  message("Iniciando server...")

  output$sync_status <- renderText({
    "Sincronización pendiente..."
  })

  output$conflict_resolution_ui <- renderUI({
    if (!is.null(input$conflict_detected)) {
      tagList(
        h4("Conflictos detectados"),
        p("Resuelve los conflictos aquí."),
        actionButton("resolve_conflict", "Resolver"),
        tableOutput("conflict_table")
      )
    } else {
      NULL
    }
  })

  output$conflict_table <- renderTable({
    if (!is.null(input$conflict_detected)) {
      data.frame(
        Table = input$conflict_detected$table,
        Local = I(list(input$conflict_detected$local)),
        Central = I(list(input$conflict_detected$central))
      )
    }
  })

  observeEvent(input$resolve_conflict, {
    if (!is.null(input$conflict_detected)) {
      session$sendCustomMessage("resolveConflict", input$conflict_detected)
    }
  })

  observeEvent(input$ref_table, {
    message("Cambio detectado en input$ref_table, forzando renderizado...")
    ref_tables_server("ref_tables", central_conn = central_conn, table_name = reactive({ input$ref_table }))
    session$sendCustomMessage("update", "ref_tables")
  }, ignoreInit = TRUE)

  observeEvent(input$ingreso_submodule, {
    message("Cambio detectado en input$ingreso_submodule, forzando renderizado...")
    ingreso_datos_server("ingreso_datos", central_conn = central_conn, selected_submodule = reactive({ input$ingreso_submodule }))
    session$sendCustomMessage("update", "ingreso_datos")
  }, ignoreInit = TRUE)

  observeEvent(input$sync_btn, {
    session$sendCustomMessage("syncData", {})
    if (!is.null(central_conn)) {
      tryCatch({
        message("Sincronización iniciada. Implementa la lógica para leer de IndexedDB y escribir en Neon.")
      }, error = function(e) {
        message("Error en sincronización:", e$message)
      })
    } else {
      message("No hay conexión a Neon para sincronizar.")
    }
  })

  session$onSessionEnded(function() {
    if (!is.null(central_conn)) {
      tryCatch({
        dbDisconnect(central_conn)
        message("Conexión a Neon cerrada.")
      }, error = function(e) {
        message("Error al cerrar conexión a Neon:", e$message)
      })
    }
  })
}
