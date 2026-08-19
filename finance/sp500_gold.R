# Load necessary libraries
library(tidyquant)
library(tidyverse)
library(lubridate)
library(purrr) # Explicitly load purrr for map_* functions

# --- 1. Parameter Settings ---
TICKERS <- c(
  "S&P 500" = "^GSPC",
  "Gold" = "GC=F",
  "IBIT" = "IBIT",
  "ETHA" = "ETHA",
  "NASDAQ 100" = "^IXIC"
)

end_date <- today()
start_date <- end_date - years(1)

print(paste0("Data retrieval period: ", start_date, " to ", end_date))

# --- 2. Data Acquisition and Processing (Modified) ---

# Function to safely retrieve data for a single ticker
get_ticker_data <- function(ticker_symbol) {
  # Use tq_get to download data
  data <- tq_get(ticker_symbol, 
                 get = "stock.prices", 
                 from = start_date, 
                 to = end_date) %>%
    select(date, adjusted) %>% 
    rename(Price = adjusted)
  
  # NOTE: The line 'data$Ticker <- ticker_symbol' has been removed from here 
  # to prevent issues with map_dfr combining the results.
  
  return(data)
}

# Apply the function to all tickers using map to get a list of results
# The .id = "Name" parameter is now inside map_dfr for reliable naming.
# We map the list of ticker symbols, not the named vector.
ticker_symbols_list <- as.list(TICKERS)
names(ticker_symbols_list) <- names(TICKERS)

# Safely run the data fetching for each ticker
# The output is a list where each element is the result of get_ticker_data or an error.
safely_results <- map(ticker_symbols_list, safely(get_ticker_data))

# Extract the successful results (the 'result' element in the list)
successful_results_list <- safely_results %>%
  keep(~ is.null(.x$error)) %>% # Keep only entries where error is NULL
  map("result") # Extract the successful data frame (the 'result' component)

# Check if any data was successfully retrieved
if (length(successful_results_list) == 0) {
  print("❌ No data was successfully retrieved for any ticker. Exiting.")
  stop()
}

# Combine all successful results into a single data frame
successful_data <- bind_rows(successful_results_list, .id = "Name")


# Pivot the data to wide format for easy calculation and alignment
# The 'Name' column now correctly uses the list names (S&P 500, Gold, etc.)
wide_data <- successful_data %>%
  pivot_wider(names_from = Name, values_from = Price)

# Drop rows with any NA values to ensure the earliest common trading date
aligned_data <- wide_data %>%
  drop_na()

if (nrow(aligned_data) == 0) {
  print("No common data found for the specified period and tickers after dropping NAs. Exiting.")
  stop()
}

# --- 3. Calculate Normalized Index (Index to 100) ---
initial_prices <- as.list(aligned_data[1, -1]) 

indexed_data <- aligned_data %>%
  # Use mutate(across(...)) to apply the normalization formula to all price columns
  mutate(across(-date, ~ (.x / initial_prices[[cur_column()]]) * 100))

# --- 4. Visualization ---
# Convert the wide indexed data back to a long format for ggplot2
plot_data <- indexed_data %>%
  pivot_longer(cols = -date, names_to = "Asset", values_to = "Indexed_Value")

# Generate the plot
performance_plot <- ggplot(plot_data, aes(x = date, y = Indexed_Value, color = Asset)) +
  geom_line(linewidth = 1) + 
  geom_hline(yintercept = 100, color = "red", linetype = "dashed", alpha = 0.8) + 
  labs(
    title = 'Performance Comparison: S&P 500, Gold, IBIT, ETHA, NASDAQ 100 (Last 1 Year)',
    x = 'Date',
    y = 'Indexed Performance (Base Date=100)',
    color = 'Assets'
  ) +
  scale_y_continuous(labels = scales::comma) + 
  theme_minimal() + 
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

# Display the plot
print(performance_plot)