# A/B Test Calculator Shiny App

This repository contains the code for a Shiny application that serves as an A/B test calculator. A/B testing is a method of comparing two versions of a webpage or other user experience to determine which one performs better. It is a popular tool for website optimization.

## Features
The A/B Test Calculator Shiny App has the following features:

1. Inputs for A/B Testing Data: The app allows users to input the number of visitors and conversions for two groups (A and B).

2. Test Type Selection: Users can select the type of test to perform - either a Two-sided or a One-sided test.

3. Confidence Level Selection: Users can select the desired confidence level for the test from the options of 90%, 95%, and 99%.

4. Calculation and Results: By clicking the "Calculate" button, the app performs a chi-squared test on the input data and displays whether there is a statistically significant difference between Conversion A and Conversion B.

5. Additional Metrics: The app also calculates and displays additional metrics such as the conversion rate difference, the odds ratio, a 95% confidence interval for the odds ratio, and the expected frequencies from the chi-squared test.

## How to Use

To use the A/B Test Calculator Shiny App, follow these steps:

1. Clone this repository to your local machine.

2. Open the app.R file in RStudio.

3. Click the "Run App" button in RStudio, or run the app from the R command line using the shiny::runApp() function.

## Requirements

To run this Shiny app, you will need the following:

- R (version 3.6.0 or later)
- Shiny package (version 1.4.0 or later)

## Contributing
Contributions are welcome! Feel free to email me with your thoughts. wschoi@gallup.co.kr

## License
This project is licensed under the terms of the MIT license. See the LICENSE file for details.
