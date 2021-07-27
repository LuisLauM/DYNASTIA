#' @method plot dynastia_validation
#' @export
plot.dynastia_validation <- function(x, ...){

  # Get information for plotting
  roc_curve <- x$roc_curve

  # Plotting ROC curve
  plot(x = 1 - roc_curve$specificity, y = roc_curve$sensitivity,
       xlab = "1 - Specificity", ylab = "Sensitivity", ...)

  # Add reference line
  abline(a = 0, b = 1, lty = "dashed", col = "gray70")

  # Extract validation measures from x
  validation_measures <- x$validation_measures

  for(i in seq_along(validation_measures)){

    # Prepare label
    measureLab <- sprintf("%s: %s", names(validation_measures)[i],
                          format(x = validation_measures[i], digits = 3,
                                 decimal.mark = ","))

    # Including label on plot
    mtext(text = measureLab, side = 1, line = -i, cex = 0.8, adj = 0.99)
  }

  return(invisible())
}

#' @method print dynastia_validation
#' @export
print.dynastia_validation <- function(x, n = 6L, ...){

  cat("\nclass: dynastia_validation\n")

  for(i in seq_along(x)){
    data <- x[[i]]

    if(is.data.frame(data)){
      cat(sprintf("\nNames: %s\nDimensions: %s x %s", toupper(names(x)[i]), nrow(data), ncol(data)))
      cat("\nValues:\n\n")

      print(head(x = as.data.frame(data), n = n))

      if(nrow(data) > n){
        cat(sprintf("\n(*)We are omitting %s rows\n", nrow(data) - n))
      }
    }else if(is.factor(data)){
      cat(sprintf("\n%s\nLevels: %s", toupper(names(x)[i]), paste(levels(data), collapse = "; ")))
      cat("\nCounts:\n\n")

      print(table(data))
    }else if(is.table(data)){
      cat(sprintf("\n%s\nDimensions: %s x %s", toupper(names(x)[i]), nrow(data), ncol(data)))
      cat("\nTable:\n\n")

      print(data)
    }else{
      cat(sprintf("\n%s\nLength: %s\n",
                  toupper(names(x)[i]), length(data)))
      cat("\nValues:\n")

      print(head(data))

      if(length(data) > n){
        cat(sprintf("\n(*)We are omitting %s values\n", length(data) - n))
      }
    }

    cat("\n-----------------------------------------------\n")
  }

  return(invisible())
}
