library(DYNASTIA)

# Reading data ------------------------------------------------------------

purse_seine_file <- system.file("extdata", "purse_seines.rds", package = "DYNASTIA")
purse_seine <- read_data(file = purse_seine_file)

purse_seine


# GLM approach ------------------------------------------------------------

# Running model
glm_model <- glm(is_fishing ~ distance_from_port + speed + course + lat + lon + year + month,
                 family = binomial(link = "logit"), data = purse_seine$train)

# Validation
glm_results <- model_validation(model = glm_model, data_test = purse_seine$test,
                                event_level = "second")

glm_results


# Random forest approach --------------------------------------------------

require(randomForest)

# Running model
rf_model <- randomForest(formula = is_fishing ~ ., data = purse_seine$train,
                         xtest = dplyr::select(purse_seine$test, !is_fishing),
                         keep.forest = TRUE)

# Validation
rf_results <- model_validation(model = rf_model, data_test = purse_seine$test)


# SVN approach ------------------------------------------------------------

require(e1071)

# Running model
svm_model <- svm(formula = is_fishing ~ ., data = purse_seine$train,
                 kernel = "polynomial", scale = TRUE, probability = TRUE, cost = 5)

# Validation
svm_results <- model_validation(model = svm_model, data_test = purse_seine$test)


# Neural networks ---------------------------------------------------------

require(nnet)

# Running model
nnet_model <- nnet(formula = is_fishing ~ ., data = purse_seine$train,
                   size = 30, maxit = 1e3)

# Validation
nnet_results <- model_validation(model = nnet_model, data_test = purse_seine$test,
                                 event_level = "second")


# Plotting and comparing --------------------------------------------------

# Organize plot space on 2x2
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
