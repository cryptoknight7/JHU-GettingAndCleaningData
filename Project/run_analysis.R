require(knitr)
require(markdown)

# Set working directory.
setwd("C:\\Users\\Achilles\\Documents\\Education\\MOOC\\JHUDataScience\\03 - Getting and Cleaning Data course\\Project")

# Knit the primary Rmd for the project.
knit("run_analysis.Rmd", encoding="ISO8859-1")

# Construct HTML from the markdown output.
markdownToHTML("run_analysis.md", "run_analysis.html")