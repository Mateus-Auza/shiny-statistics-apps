library(ggplot2); library(bslib); library(shiny)

ui= fluidPage(
  titlePanel("Comparison between Binomial and Poisson"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("A", label=" Choose the type of distribution", choices=c("Binomial", "Poisson")),
      uiOutput("B")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("PDF", plotOutput("C")),
        tabPanel("CDF", plotOutput("D"))
      )
    )
  )
)


server= function(input, output){
  output$B= renderUI({
    switch(input$A,
           "Binomial"= tagList(
             sliderInput("B1", label="Choose the number of observations", min=1, max=50, value=20),
             sliderInput("B2", label="Choose the probability", min=0, max=1, value=0.5)
           ),
           "Poisson"= sliderInput("B3", label="Choose your lambda", min=0.1,max=30, value=15)
    )

  })

  d= reactive({
    switch(input$A,
           "Binomial"= {bin_data <- data.frame(
             x = 0:input$B1,
             y = dbinom(x = 0:input$B1, size=input$B1, prob=input$B2)
           )

           # 2. Plot with geom_col() for height and geom_point() for clarity
           ggplot(bin_data, aes(x = x, y = y)) +
             geom_col(fill = "steelblue", alpha = 0.5, width = 0.7) +
             geom_point(color = "darkred", size = 2.5) +
             scale_x_continuous(breaks = 0:input$B1) + # Enforce exact integer ticks
             labs(
               title = "Binomial Distribution",
               subtitle = paste("n=", input$B1, "and p=",input$B2),
               x = "Number of events",
               y = "Probability"
             )},
           "Poisson"= {pois_data <- data.frame(
             x = 0:(2*input$B3),
             y = dpois(x = 0:(2*input$B3), lambda = input$B3)
           )

           # 2. Plot with geom_col() for height and geom_point() for clarity
           ggplot(pois_data, aes(x = x, y = y)) +
             geom_col(fill = "steelblue", alpha = 0.5, width = 0.7) +
             geom_point(color = "darkred", size = 2.5) +
             scale_x_continuous(breaks = 0:(2*input$B3)) + # Enforce exact integer ticks
             labs(
               title = "Poisson Distribution",
               subtitle = paste("lamda=",input$B3),
               x = "Number of events",
               y = "Probability"
             ) }
    )

  })

  e= reactive({
    switch(input$A,
           "Binomial"= {ggplot(data.frame(x = c(0, input$B1)), aes(x)) +
               stat_function(
                 fun = pbinom,
                 args = list(size=input$B1, prob=input$B2),
                 geom = "step",
                 pad = FALSE,
                 linewidth = 1.2,
                 color = "blue"
               ) +
               scale_x_continuous(breaks = 0:input$B1) +
               labs(
                 title = paste("Theoretical Binomial CDF (n =",input$B1, ") and p =", input$B2),
                 x = "Number of events (k)",
                 y = "Cumulative probability P(X <= k)"
               ) +
               theme_minimal()},
           "Poisson"={ggplot(data.frame(x = c(0, 2*input$B3)), aes(x)) +
               stat_function(
                 fun = ppois,
                 args = list(lambda = input$B3),
                 geom = "step",
                 pad = FALSE,
                 linewidth = 1.2,
                 color = "blue"
               ) +
               scale_x_continuous(breaks = 0:(2*input$B3)) +
               labs(
                 title = paste("Theoretical Poisson CDF (Lambda =", input$B3, ")"),
                 x = "Number of events (k)",
                 y = "Cumulative probability P(X <= k)"
               ) +
               theme_minimal()})
  })

  output$C= renderPlot({d()})
  output$D= renderPlot({e()})
}


shinyApp(ui, server)
