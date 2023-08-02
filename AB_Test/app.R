library(shiny)
library(ggplot2)
library(pwr)
library(pwrAB)

ui <- fluidPage(
  titlePanel("A/B Test Calculator"),
  sidebarLayout(
    sidebarPanel(
      numericInput("visitors_a", "Number of Visitors A", value = 0),
      numericInput("conversions_a", "Number of Conversions A", value = 0),
      numericInput("visitors_b", "Number of Visitors B", value = 0),
      numericInput("conversions_b", "Number of Conversions B", value = 0),
      radioButtons("test_type", "Type of Test", choices = c("Two-sided", "One-sided"), selected = "Two-sided"),
      selectInput("confidence_level", "Confidence Level", choices = c("90%", "95%", "99%"), selected = "95%"),
      actionButton("calculate", "Calculate")
    ),
    mainPanel(
      textOutput("result"),
      plotOutput("distPlot"),
      fluidRow(
        column(4, textOutput("conversion_rate_a")),
        column(4, textOutput("conversion_rate_b")),
        column(4, textOutput("relative_uplift"))
      ),
      fluidRow(
        column(4, textOutput("observed_power")),
        column(4, textOutput("p_value")),
        column(4, textOutput("z_score"))
      ),
      fluidRow(
        column(4, textOutput("standard_error_a")),
        column(4, textOutput("standard_error_b")),
        column(4, textOutput("standard_error_diff"))
      )
    )
  )
)

server <- function(input, output) {
  observeEvent(input$calculate, {
    data <- matrix(c(input$conversions_a, input$visitors_a - input$conversions_a,
                     input$conversions_b, input$visitors_b - input$conversions_b), nrow = 2)
    test <- chisq.test(data)
    
    # Adjust p-value for one-sided test
    if (input$test_type == "One-sided") {
      test$p.value <- test$p.value / 2
    }
    
    # Adjust p-value for confidence level
    alpha <- switch(input$confidence_level,
                    "90%" = 0.1,
                    "95%" = 0.05,
                    "99%" = 0.01)
    
    if (test$p.value < alpha) {
      result <- "There is a statistically significant difference between Conversion A and Conversion B!"
    } else {
      result <- "There is not a statistically significant difference between Conversion A and Conversion B!"
    }
    
    output$result <- renderText(result)
    
    # Calculate additional metrics
    conversion_rate_a <- input$conversions_a / input$visitors_a
    conversion_rate_b <- input$conversions_b / input$visitors_b
    relative_uplift <- (conversion_rate_b - conversion_rate_a) / conversion_rate_a
    standard_error_a <- sqrt((conversion_rate_a * (1 - conversion_rate_a)) / input$visitors_a)
    standard_error_b <- sqrt((conversion_rate_b * (1 - conversion_rate_b)) / input$visitors_b)
    standard_error_diff <- sqrt(standard_error_a^2 + standard_error_b^2)
    z_score <- (conversion_rate_b - conversion_rate_a) / standard_error_diff
    p_value <- 2 * (1 - pnorm(abs(z_score)))
    observed_power_result <- power.prop.test(
      p1 = conversion_rate_a,
      p2 = conversion_rate_b,
      n = input$visitors_a+input$visitors_b, # or input$visitors_b if the sample sizes are equal
      sig.level = alpha,
      alternative = if (input$test_type == "One-sided") "one.sided" else "two.sided"
    )
    observed_power <- observed_power_result$power
    
    # Display results
    output$conversion_rate_a <- renderText(paste0("Conversion Rate A: ", round(conversion_rate_a, 4)))
    output$conversion_rate_b <- renderText(paste0("Conversion Rate B: ", round(conversion_rate_b, 4)))
    output$relative_uplift <- renderText(paste0("Relative Uplift: ", round(relative_uplift, 4)))
    output$standard_error_a <- renderText(paste0("Standard Error A: ", round(standard_error_a, 4)))
    output$standard_error_b <- renderText(paste0("Standard Error B: ", round(standard_error_b, 4)))
    output$standard_error_diff <- renderText(paste0("Standard Error of Difference: ", round(standard_error_diff, 4)))
    output$z_score <- renderText(paste0("Z-Score: ", round(z_score, 4)))
    output$p_value <- renderText(paste0("P Value: ", round(p_value, 4)))
    output$observed_power <- renderText(paste0("Observed Power: ", round(observed_power, 4)))
    
    # Plot distributions
    output$distPlot <- renderPlot({
      data_a <- rbinom(10000, input$visitors_a, conversion_rate_a)
      data_b <- rbinom(10000, input$visitors_b, conversion_rate_b)
      df <- data.frame(Conversion = c(data_a, data_b), Variation = rep(c("A", "B"), each = 10000))
      ggplot(df, aes(x = Conversion, fill = Variation)) + geom_density(alpha = 0.5) + theme_minimal() + labs(title = "The expected distributions of variation A and B")
    })
  })
}

shinyApp(ui = ui, server = server)
