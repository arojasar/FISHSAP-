# modules/ref_tables_server.R

library(shiny)
library(DT)

ref_tables_server <- function(id, central_conn, table_name) {
  moduleServer(id, function(input, output, session) {
    message("Entrando en ref_tables_server para ID: ", id)
    
    # Mapear nombres de tablas a nombres en IndexedDB
    table_mapping <- list(
      "Sitios de Desembarque" = "sitios",
      "Especies Comerciales" = "especies",
      "Categorías de Estado" = "estados",
      "Clasificación" = "clasifica",
      "Grupos" = "grupos",
      "Subgrupos" = "subgrupo",
      "Artes de Pesca" = "arte",
      "Método de Técnica de Pesca" = "metodo",
      "Métodos de Propulsión" = "propulsion",
      "Área de Pesca" = "area",
      "Subárea de Pesca" = "subarea",
      "Registradores de Campo" = "registrador",
      "Embarcaciones" = "embarcaciones",
      "Gastos de Faena" = "gastos",
      "Valor Mensual de los Gastos" = "valor_mensual_gastos",
      "TRM (Dólar)" = "trm_dolar"
    )
    
    # Crear un valor reactivo para almacenar los datos de la tabla
    table_data <- reactiveVal(data.frame(Message = "Esperando datos..."))
    
    # Enviar mensaje loadTableData solo cuando cambia la tabla seleccionada
    observeEvent(table_name(), {
      selected_table <- table_mapping[[table_name()]]
      if (!is.null(selected_table)) {
        message("Enviando mensaje loadTableData para tabla:", selected_table)
        session$sendCustomMessage("loadTableData", list(table = selected_table))
      }
    })
    
    # Actualizar table_data cuando lleguen nuevos datos de IndexedDB
    observeEvent(input$ref_table_output_data, {
      message("Datos recibidos de IndexedDB:", input$ref_table_output_data)
      if (is.null(input$ref_table_output_data)) {
        table_data(data.frame(Message = "No hay datos disponibles para esta tabla"))
      } else {
        table_data(as.data.frame(input$ref_table_output_data))
      }
    }, ignoreNULL = FALSE)
    
    # Renderizar la tabla
    output$ref_table_output <- renderDT({
      message("Renderizando tabla en ref_tables_server dentro de renderDT...")
      datatable(table_data(), options = list(pageLength = 5))
    })
    
    # Formulario para agregar nuevos valores
    output$ref_form <- renderUI({
      message("Renderizando formulario para:", table_name())
      selected_table <- table_mapping[[table_name()]]
      if (is.null(selected_table)) return(NULL)
      
      tagList(
        h4(paste("Agregar nuevo valor a", table_name())),
        if (selected_table == "sitios") {
          tagList(
            textInput("sitios_CODSIT", "Código"),
            textInput("sitios_NOMSIT", "Nombre"),
            actionButton("save_ref_button", "Guardar", icon = icon("save"))
          )
        } else if (selected_table == "especies") {
          tagList(
            textInput("especies_CODESP", "Código"),
            textInput("especies_Nombre_Comun", "Nombre Común"),
            textInput("especies_Nombre_Cientifico", "Nombre Científico"),
            selectInput("especies_Subgrupo_ID", "Subgrupo", choices = c("", "SUB01", "SUB02")),
            selectInput("especies_Clasificacion_ID", "Clasificación", choices = c("", "CLA01", "CLA02")),
            numericInput("especies_Constante_A", "Constante A", value = 0, step = 0.0000001),
            numericInput("especies_Constante_B", "Constante B", value = 0, step = 0.0000001),
            selectInput("especies_Clase_Medida", "Clase Medida", choices = c("cm", "mm")),
            selectInput("especies_Clasificacion_Comercial", "Clasificación Comercial", choices = c("Rojo", "Negro")),
            textInput("especies_Grupo", "Grupo"),
            actionButton("save_ref_button", "Guardar", icon = icon("save"))
          )
        } else {
          tagList(
            textInput("generic_ID", "Código"),
            textInput("generic_Nombre", "Nombre"),
            actionButton("save_ref_button", "Guardar", icon = icon("save"))
          )
        }
      )
    })
    
    # Manejar el guardado de nuevos valores
    observeEvent(input$save_ref_button, {
      message("Botón Guardar (referencia) presionado. Enviando datos a IndexedDB...")
      selected_table <- table_mapping[[table_name()]]
      if (is.null(selected_table)) return()
      
      new_data <- if (selected_table == "sitios") {
        list(
          CODSIT = input$sitios_CODSIT,
          NOMSIT = input$sitios_NOMSIT,
          Creado_Por = "system",
          Fecha_Creacion = as.character(Sys.time()),
          Modificado_Por = "system",
          Fecha_Modificacion = as.character(Sys.time()),
          Sincronizado = 0
        )
      } else if (selected_table == "especies") {
        list(
          CODESP = input$especies_CODESP,
          Nombre_Comun = input$especies_Nombre_Comun,
          Nombre_Cientifico = input$especies_Nombre_Cientifico,
          Subgrupo_ID = input$especies_Subgrupo_ID,
          Clasificacion_ID = input$especies_Clasificacion_ID,
          Constante_A = input$especies_Constante_A,
          Constante_B = input$especies_Constante_B,
          Clase_Medida = input$especies_Clase_Medida,
          Clasificacion_Comercial = input$especies_Clasificacion_Comercial,
          Grupo = input$especies_Grupo,
          Creado_Por = "system",
          Fecha_Creacion = as.character(Sys.time()),
          Modificado_Por = "system",
          Fecha_Modificacion = as.character(Sys.time()),
          Sincronizado = 0
        )
      } else {
        list(
          ID = input$generic_ID,
          Nombre = input$generic_Nombre,
          Creado_Por = "system",
          Fecha_Creacion = as.character(Sys.time()),
          Modificado_Por = "system",
          Fecha_Modificacion = as.character(Sys.time()),
          Sincronizado = 0
        )
      }
      
      session$sendCustomMessage("saveData", list(table = selected_table, data = new_data))
    })
    
    message("Saliendo de ref_tables_server para ID: ", id)
  })
}