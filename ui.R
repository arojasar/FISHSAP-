library(shiny)

ui <- fluidPage(
  titlePanel("SIPEIN - Sistema de Información Pesquera"),
  
  # Incluir Dexie desde la copia local
  tags$script(src = "dexie.min.js"),
  
  # Incluir otros scripts y estilos
  tags$script(src = "indexeddb.js"),
  tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
  
  h2("¡Bienvenido a SIPEIN!"),
  p("Si ves este texto, la UI se está renderizando correctamente."),
  
  actionButton("sync_btn", "Sincronizar", icon = icon("sync")),
  textOutput("sync_status"),
  
  uiOutput("conflict_resolution_ui"),
  
  sidebarLayout(
    sidebarPanel(
      # Cambiar selectInput por radioButtons para una mejor experiencia visual
      radioButtons(
        "module", 
        "Seleccione un módulo:",
        choices = c("Tablas de Referencia", "Ingreso de Datos"),
        selected = "Tablas de Referencia",
        inline = FALSE
      ),
      # Mostrar el selector de tablas solo si se selecciona "Tablas de Referencia"
      conditionalPanel(
        condition = "input.module == 'Tablas de Referencia'",
        selectInput(
          "ref_table", 
          "Seleccionar tabla:",
          choices = c(
            "Sitios de Desembarque", 
            "Especies Comerciales", 
            "Categorías de Estado",
            "Clasificación", 
            "Grupos", 
            "Subgrupos", 
            "Artes de Pesca",
            "Método de Técnica de Pesca", 
            "Métodos de Propulsión", 
            "Área de Pesca",
            "Subárea de Pesca", 
            "Registradores de Campo", 
            "Embarcaciones",
            "Gastos de Faena", 
            "Valor Mensual de los Gastos", 
            "TRM (Dólar)"
          ),
          selected = "Sitios de Desembarque"
        )
      ),
      # Mostrar el selector de submódulo solo si se selecciona "Ingreso de Datos"
      conditionalPanel(
        condition = "input.module == 'Ingreso de Datos'",
        selectInput(
          "ingreso_submodule", 
          "Seleccionar submódulo:",
          choices = c("Captura y Esfuerzo")
        )
      )
    ),
    
    mainPanel(
      # Mostrar solo el contenido de "Tablas de Referencia" si está seleccionado
      conditionalPanel(
        condition = "input.module == 'Tablas de Referencia'",
        h3("Tablas de Referencia (deberías ver una tabla aquí):"),
        ref_tables_ui("ref_tables")
      ),
      # Mostrar solo el contenido de "Ingreso de Datos" si está seleccionado
      conditionalPanel(
        condition = "input.module == 'Ingreso de Datos'",
        h3("Ingreso de Datos (deberías ver un formulario y tabla aquí):"),
        ingreso_datos_ui("ingreso_datos")
      )
    )
  )
)