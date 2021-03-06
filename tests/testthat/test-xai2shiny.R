library(ranger)
library(shinytest)

shinytest::installDependencies()

data <- DALEX::titanic_imputed

mod_glm <- glm(survived ~ ., data, family = "binomial")
explainer_glm <- DALEX::explain(mod_glm, data = data[,-8], y=data$survived)

xai2shiny(explainer_glm, directory = getwd(), run = FALSE)

test_that("All files are created",{
  expect_true("xai2shiny" %in% list.files())
  expect_true("app.R" %in% list.files("xai2shiny"))
  expect_true("exp1.rds" %in% list.files("xai2shiny"))
})

app <- ShinyDriver$new("xai2shiny/")

test_that("The application runs",{
  output_pred <- app$getValue(name = "textPred")
  pred_base <- substr(output_pred, 9, 12)
  expect_equal(pred_base, "0.06")
  output_performance <- app$getValue(name = "textid3")
  expect_equal(output_performance, "")
  output_bd_description <- app$getValue(name = "textid1")
  expect_equal(output_bd_description, "")
  output_cp_description <- app$getValue(name = "textid2")
  expect_equal(output_cp_description, "")
  app$setInputs(text_yesno = TRUE)
  output_performance <- app$getValue(name = "textid3")
  performance_base <- substr(output_performance, 1, 11)
  expect_equal(performance_base, "Performance")
  output_bd_description <- app$getValue(name = "textid1")
  bd_description_base <- substr(output_bd_description, 1, 2)
  expect_equal(bd_description_base, "Lm")
  output_cp_description <- app$getValue(name = "textid2")
  cp_description_base <- substr(output_cp_description, 1, 3)
  expect_equal(cp_description_base, "For")
})

app$stop()

test_that("The selected_variables parameter functions properly",{
  expect_true({
    xai2shiny(explainer_glm, selected_variables = "age", run = FALSE)
    TRUE
  })
})

unlink("xai2shiny", recursive = TRUE)
