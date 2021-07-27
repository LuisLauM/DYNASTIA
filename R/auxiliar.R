read.csv_dynastia <- function(file, ...){

  # Read data from csv
  data <- read.csv(file = file, ...) %>%

    # Filter positive rows
    filter(as.numeric(is_fishing) > -1e-6) %>%

    # Calculating and adding variables
    mutate(timestamp = as.POSIXct(x = timestamp, origin = "1970-1-1 00:00:00"),
           year = factor(x = format(x = timestamp, format = "%Y"),
                         levels = 2012:2015),
           month = factor(x = as.numeric(format(x = timestamp, format = "%m")),
                          levels = 1:12),
           is_fishing = replace(is_fishing, is_fishing > 0, 1)) %>%

    # Converting is_fishing as a factor
    mutate(is_fishing = factor(x = is_fishing, levels = c(0, 1),
                               labels = c("no_fishing", "fishing"))) %>%

    # Keeping only this variables: distance_from_port, speed, course, lat, lon, is_fishing
    select(distance_from_port:is_fishing, year, month)

  return(data)
}
