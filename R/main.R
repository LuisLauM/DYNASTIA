#' Reading and preparing data for model comparing
#'
#' @param file The path of file which the data are to be read from. See Detail.
#' @param split_ratio A number from 0 to 1 which will be used to separate data
#' within train and test.
#' @param ... Extra arguments passed to main reading functions.
#'
#' @details \code{file} must be whether a csv or a rds file. If it is a csv, the
#' function will assume that it belongs to a raw data from Global Fishing Watch
#' datasets, particularly, from \link{https://globalfishingwatch.org/data-download/datasets/public-training-data-v1}.
#'
#' @return An object of class \code{dynastia_data}.
#' @export
#'
#' @examples
#' purse_seine_file <- system.file("extdata", "purse_seines.rds", package = "DYNASTIA")
#' read_data(file = purse_seine_file)
read_data <- function(file, split_ratio = 0.75, ...){

  # Extract extesion from file path
  extension <- tolower(unlist(strsplit(x = basename(file), split = "\\."))[2])

  # Read data from file
  data <- switch(extension,
                 "csv" = read.csv_dynastia(file = file, ...),
                 "rds" = readRDS(file = file, ...),
                 stop(sprintf("Sorry, we have not yet implemented any method for %s.", extension)))

  # Get index to split data
  index <- sample(x = seq(nrow(data)),
                  size = as.integer(nrow(data)*split_ratio))

  # Splitting data into train and test subsets
  data_train <- data[index,]
  data_test <- data[-index,]

  # Build output object
  output <- list(all = data,
                 train = data_train,
                 test = data_test)

  class(output) <- "dynastia_data"

  return(output)
}


#' @title Take a model and returns validation results.
#'
#' @param model A model object for which validation is desired.
#' @param data_test A data frame in which to look for variables with which to
#' predict.
#' @param event_level A single string. Either "first" or "second" to specify
#' which level of truth to consider as the "event". See Details.
#' @param ...
#'
#' @details At version 0.0.1, \code{model} must be within next classes:
#' \code{glm}, \code{randomForest}, \code{svm} or \code{nnet}.
#'
#' @return An object of class \code{dynastia_validation}.
#' @export
#'
#' @examples
#' purse_seine_file <- system.file("extdata", "purse_seines.rds", package = "DYNASTIA")
#' purse_seine <- read_data(file = purse_seine_file)
#'
#' # Running model
#' glm_model <- glm(is_fishing ~ distance_from_port + speed + course + lat + lon + year + month,
#'                  family = binomial(link = "logit"), data = purse_seine$train)
#'
# Validation
#' model_validation(model = glm_model, data_test = purse_seine$test,
#'                  event_level = "second")
model_validation <- function(model, data_test, event_level = "first", ...){

  # Probabilities and classifications from predictions by model
  if(is.element("glm", class(model))){

    predictions_probs <- predict(object = model, newdata = data_test,
                                 type = "response")

    predictions_class <- factor(x = predictions_probs > 0.5,
                                levels = c(FALSE, TRUE),
                                labels = levels(data_test$is_fishing))

  }else if(is.element("randomForest", class(model))){

    predictions_class <- predict(object = model, newdata = data_test,
                                 type = "response")

    predictions_probs <- predict(object = model, newdata = data_test,
                                 type = "prob")[,1]

  }else if(is.element("svm", class(model))){

    predictions_class <- predict(object = model, newdata = data_test,
                                 probability = TRUE)

    predictions_probs <- attr(x = predictions_class, which = "probabilities")[,2]

  }else if(is.element("nnet", class(model))){

    predictions_probs <- predict(object = model, newdata = data_test)[,1]

    predictions_class <- predict(object = model, newdata = data_test,
                                 type = "class")
    predictions_class <- factor(x = predictions_class, levels = levels(data_test$is_fishing))

  }else{
    stop("Not defined methods to extract 'predictions_class' and 'predictions_probs' for this model class.")
  }

  # Get confusion matrix
  confusion_matrix <- table(predictions_class, data_test$is_fishing)

  # Get elements from confusion matrix
  true_positives <- confusion_matrix[1, 1]
  true_negatives <- confusion_matrix[1, 2]
  false_positives <- confusion_matrix[2, 1]
  false_negatives <- confusion_matrix[2, 2]

  # Get main measures
  validation_measures <- list(Accuracy    = (true_positives + true_negatives)/(sum(confusion_matrix)),
                              Sensitivity = true_positives/(true_positives + false_negatives),
                              Specificity = true_negatives/(true_negatives + false_positives),
                              Precision   = true_positives/(true_positives + false_positives))

  # Armonic mean of precision-sensitivity
  validation_measures <- c(unlist(validation_measures),
                           "Precision-Sensitivity (HM)" = with(validation_measures,
                                                               2*Precision*Sensitivity/(Precision + Sensitivity)))

  # Get data for ROC curve
  data_ROC <- data.frame(truth = data_test$is_fishing,
                         probs = predictions_probs)

  # Calculate results for ROC curve
  roc_curve <- roc_curve(data = data_ROC, truth, probs,
                         event_level = event_level)

  # Compile results
  output <- list(predictions_class   = predictions_class,
                 predictions_probs   = predictions_probs,
                 confusion_matrix    = confusion_matrix,
                 validation_measures = validation_measures,
                 roc_curve           = roc_curve)

  class(output) <- "dynastia_validation"

  return(output)
}
