library(bslib); library(shiny)

PlotDens <- function(a = -1, b = 1, mean=0, sd=1, df=1, over=0) {
  library(ggplot2)

  PlotDens <- function(a = -1,
                       b = 1,
                       mean = 0,
                       sd = 1,
                       df = 1,
                       over = 0) {

    # Common theme
    base_theme <- theme_minimal(base_size = 14) +
      theme(
        legend.position = "top",
        plot.title = element_text(face = "bold")
      )

    # ---------------------------
    # Normal distribution plot
    # ---------------------------
    normal_plot <- ggplot() +
      stat_function(
        fun = dnorm,
        args = list(mean = mean, sd = sd),
        linewidth = 1
      ) +
      stat_function(
        fun = dnorm,
        args = list(mean = mean, sd = sd),
        xlim = c(a, b),
        geom = "area",
        fill = "red",
        alpha = 0.3
      ) +
      geom_segment(
        aes(x = a, xend = a,
            y = 0, yend = dnorm(a, mean, sd)),
        linetype = 2
      ) +
      geom_segment(
        aes(x = b, xend = b,
            y = 0, yend = dnorm(b, mean, sd)),
        linetype = 2
      ) +
      annotate("text", x = a, y = -0.01, label = "a") +
      annotate("text", x = b, y = -0.01, label = "b") +
      labs(
        title = "Normal Distribution",
        y = "Density",
        x = NULL,
        colour = paste0(
          "P(a < X < b) = ",
          round(
            pnorm(b, mean, sd) -
              pnorm(a, mean, sd),
            3
          )
        )
      ) +
      xlim(
        min(-5, mean - 3 * sd),
        max(5, mean + 3 * sd)
      ) +
      base_theme

    # ---------------------------
    # Student t plot
    # ---------------------------
    t_plot <- ggplot() +
      stat_function(
        fun = dt,
        args = list(df = df),
        linewidth = 1,
        colour = "blue"
      ) +
      stat_function(
        fun = dt,
        args = list(df = df),
        xlim = c(a, b),
        geom = "area",
        fill = "lightblue",
        alpha = 0.3
      ) +
      geom_segment(
        aes(x = a, xend = a,
            y = 0, yend = dt(a, df)),
        linetype = 2
      ) +
      geom_segment(
        aes(x = b, xend = b,
            y = 0, yend = dt(b, df)),
        linetype = 2
      ) +
      annotate("text", x = a, y = -0.01, label = "a") +
      annotate("text", x = b, y = -0.01, label = "b") +
      labs(
        title = paste("Student t Distribution (df =", df, ")"),
        y = "Density",
        x = NULL,
        colour = paste0(
          "P(a < X < b) = ",
          round(
            pt(b, df) - pt(a, df),
            3
          )
        )
      ) +
      xlim(-5, 5) +
      base_theme

    # ---------------------------
    # Output
    # ---------------------------
    if (over == 0) {

      normal_plot +
        stat_function(
          fun = dt,
          args = list(df = df),
          colour = "blue",
          linewidth = 1
        ) +
        stat_function(
          fun = dt,
          args = list(df = df),
          xlim = c(a, b),
          geom = "area",
          fill = "lightblue",
          alpha = 0.3
        ) +
        labs(
          subtitle = paste(
            "Normal vs Student t (df =", df, ")"
          )
        )

    } else if (over == 1) {

      normal_plot

    } else if (over == 2) {

      t_plot

    } else {

      stop("'over' must be 0, 1, or 2")

    }
  }
}

PlotDens(-1,1,-2,1,5,2)


runPlotDens <- function() {
  ui <- fluidPage(
    titlePanel("Normal vs Student"),
    sidebarLayout(
      sidebarPanel(
        sliderInput(
          inputId = "range",
          label = "Interval (a,b):",
          min = -5, max = 5, value = c(-1,1), step = 0.5
        ),
        sliderInput("mean", label="Mean- Normal", value=0, min=-5, max=5),
        sliderInput("sd", label="Standard deviation (`sd`)- Normal", value=1,min=0.1, 3),
        sliderInput("df", label="Degree of freedom (´df`)- Student", value=1,min=1, max=50),
        radioButtons("who", label="Output", choices=c("Overlay", "Normal", "Student"), inline=T)

      ),
      mainPanel(
        plotOutput("plot")
      ))


  )
  server <- function(input, output) {
    d= reactive({
      switch(input$who,
             "Overlay"=0,
             "Normal"=1,
             "Student"=2)
    })
    output$plot <- renderPlot({
      PlotDens(input$range[1], input$range[2], input$mean, input$sd, input$df,d())
    })
  }
  runApp(shinyApp(ui, server))
}

runPlotDens()
