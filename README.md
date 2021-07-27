# DYNASTIA
Package for comparing 4 methods of classification (for PhD demo).

## Installation

First, you must need to install devtools package which offers an easy way to download and install a package from a Github repo using the next line:

```
devtools::install_github("LuisLauM/DYNASTIA")
```

## Example

Load the DYNASTIA package:
```
require(DYNASTIA)
```

At version 0.0.1, **DYNASTIA** offers two main functions (`read_data` and `model_validation`) and some methods (`print` and `plot`) for the ouputs of them. You can ask for the documentation of each of the main functions by running `?read_data`.

### 1. Reading data
**DYNASTIA** includes an example data storaged as a .rds file on the package itself. In order to extract the relative path, you must use `system.file` function as follow:

```
purse_seine_file <- system.file("extdata", "purse_seines.rds", package = "DYNASTIA")
```

Then, you must be able to use this path on the `read_data` function:

```
purse_seine <- read_data(file = purse_seine_file)
```

The output of `read_data` will be an object of class `dynastia_data`, which has its own method for printting:

```
print(purse_seine)
```

### 2. Running models
**DYNASTIA** is prepared to receive 4 kind of models: GLM (**stats** package), random forest (**randomForest** package), SVM (**e1071** package) and neural networks (**nnet** package), so the next steps will show you the runnings of each type:

```
# GLM approach 
glm_model <- glm(is_fishing ~ distance_from_port + speed + course + lat + lon + year + month,
                 family = binomial(link = "logit"), data = purse_seine$train)
                 
# Random forest approach
require(randomForest)

rf_model <- randomForest(formula = is_fishing ~ ., data = purse_seine$train,
                         xtest = dplyr::select(purse_seine$test, !is_fishing),
                         keep.forest = TRUE)
                 
# SVM approach 
require(e1071)

svm_model <- svm(formula = is_fishing ~ ., data = purse_seine$train,
                 kernel = "polynomial", scale = TRUE, probability = TRUE, cost = 5)
                 
# Neural network approach 
require(nnet)

nnet_model <- nnet(formula = is_fishing ~ ., data = purse_seine$train,
                   size = 30, maxit = 1e3)
```

### 3. Validation results
`model_validation` function is useful to extract the main results from each running. It will return the results on an object of class `dynastia_validation`.

```
# GLM approach 
glm_results <- model_validation(model = glm_model, data_test = purse_seine$test,
                                event_level = "second")
                 
# Random forest approach
rf_results <- model_validation(model = rf_model, data_test = purse_seine$test)
                 
# SVM approach 
svm_results <- model_validation(model = svm_model, data_test = purse_seine$test)
                 
# Neural network approach 
nnet_results <- model_validation(model = nnet_model, data_test = purse_seine$test,
                                 event_level = "second")
```

### 4. Plotting validation results
Finally, `dynastia_validation` objects can be plotted by using `plot` function as follows:

```
par(mfrow = c(2, 2))

plot(x = glm_results,
     type = "l", col = "blue", lwd = 2, las = 1,
     main = "GLM approach")

plot(x = rf_results,
     type = "l", col = "blue", lwd = 2, las = 1,
     main = "Random forest approach")

plot(x = svm_results,
     type = "l", col = "blue", lwd = 2, las = 1,
     main = "SVM approach")

plot(x = nnet_results,
     type = "l", col = "blue", lwd = 2, las = 1,
     main = "Neural networks approach")
```



