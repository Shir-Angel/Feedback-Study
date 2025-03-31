# Load libraries ----------------------------------------------------------

library(readr)
library(lme4)
library(lmerTest)
library(emmeans)
library(tidyr)
library(dplyr)
library(ggplot2)
library(see)

# Paths -------------------------------------------------------------------

vis_path <- "C:\\Users\\USER\\Documents\\lab\\analyses\\bigTable\\vis\\bigTableAll.csv"
ves_path <- "C:\\Users\\USER\\Documents\\lab\\analyses\\bigTable\\ves\\bigTableAll.csv"
output_path <- "C:\\Users\\USER\\Documents\\lab\\analyses\\bigTable\\"

# Helper function to fit and analyze models --------------------------------

fit_model <- function(data) {
  # Fit the model
  mdl <- glmer(
    Response ~ 1 + CurrStim + PrevStim + PrevChoice + PrevChoice:FeedbackType +
      (1 + CurrStim + PrevStim + PrevChoice + PrevChoice:FeedbackType | SubjNum),
    data = data, family = "binomial", nAGQ = 1, verbose = 1,
    control = glmerControl(optimizer = "bobyqa")
  )
  
  # Print model summary
  summary(mdl)
  
  # Extract emmeans for PrevChoice per FeedbackType
  means <- emtrends(mdl, ~ FeedbackType, var = "PrevChoice", nesting = NULL)
  print(summary(means))
  
  # Compute pairwise contrasts with Bonferroni correction
  contrast_results <- contrast(means, method = "pairwise", adjust = "bonferroni")
  print(summary(contrast_results))
  
  # Extract coefficients (random + fixed)
  coefs <- coef(mdl)$SubjNum
  coefs$SubjNum <- row.names(coefs)
  
  # Return outputs
  list(
    mdl = mdl,
    means = means,
    contrast_results = contrast_results,
    coefs = coefs
  )
}

# Load and process data ---------------------------------------------------

# Load VIS data
vis_bigTable <- read_csv(vis_path)
vis_bigTable$SubjNum <- factor(vis_bigTable$SubjNum)
vis_bigTable$FeedbackType <- factor(vis_bigTable$FeedbackType, levels = c("NoFeedback", "Cor", "Incor"))

# Load VES data
ves_bigTable <- read_csv(ves_path)
ves_bigTable$SubjNum <- factor(ves_bigTable$SubjNum)
ves_bigTable$FeedbackType <- factor(ves_bigTable$FeedbackType, levels = c("NoFeedback", "Cor", "Incor"))

# Fit models --------------------------------------------------------------

# VIS model
vis_results <- fit_model(vis_bigTable)
vis_coefs <- vis_results$coefs
vis_coefs$modality <- "vis"

# VES model
ves_results <- fit_model(ves_bigTable)
ves_coefs <- ves_results$coefs
ves_coefs$modality <- "ves"

# Save coefficients -------------------------------------------------------

write.csv(vis_coefs, file.path(output_path, "vis_coefs.csv"), row.names = FALSE)
write.csv(ves_coefs, file.path(output_path, "ves_coefs.csv"), row.names = FALSE)

# Combine coefficients ----------------------------------------------------

all_coefs <- rbind(vis_coefs, ves_coefs)

# Adjust coefficients for plotting
all_coefs$`PrevChoice:FeedbackTypeCor` <- all_coefs$`PrevChoice:FeedbackTypeCor` + all_coefs$`PrevChoice`
all_coefs$`PrevChoice:FeedbackTypeIncor` <- all_coefs$`PrevChoice:FeedbackTypeIncor` + all_coefs$`PrevChoice`

# Reshape to long format
all_coefs_long <- all_coefs %>%
  rename(
    'PrevChoice:NoFeedback' = `PrevChoice`,
    'PrevChoice:CorFeedback' = `PrevChoice:FeedbackTypeCor`,
    'PrevChoice:IncorFeedback' = `PrevChoice:FeedbackTypeIncor`
  ) %>%
  pivot_longer(
    cols = -c("SubjNum", "modality"),
    names_to = "coefficient"
  )

# Filter relevant coefficients
all_coefs_long <- subset(
  all_coefs_long,
  coefficient %in% c('PrevChoice:NoFeedback', 'PrevChoice:CorFeedback', 'PrevChoice:IncorFeedback')
)

# Order factors for plotting
all_coefs_long$coefficient <- factor(
  all_coefs_long$coefficient,
  levels = c('PrevChoice:NoFeedback', 'PrevChoice:CorFeedback', 'PrevChoice:IncorFeedback')
)

# Save combined coefficients ----------------------------------------------

write.csv(all_coefs_long, file.path(output_path, "all_coefs_for_JASP.csv"), row.names = FALSE)
write.csv(all_coefs, file.path(output_path, "all_coefs_for_MATLAB.csv"), row.names = FALSE)

# Plot results ------------------------------------------------------------

ggplot(all_coefs_long, aes(x = coefficient, y = value, fill = modality, color = modality)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_violinhalf(width = 2, trim = TRUE, scale = "width", alpha = 1, position = position_dodge(0.6), flip = c(1,3,5)) +
  # Jitter plot
  #geom_point(alpha = 0.6, size = 1.5, position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.2)) +
  # Boxplot
  geom_boxplot(width = 0.15, position = position_dodge(width = 0.3), alpha = 0.2, outlier.shape = 21, outlier.alpha = 1, linewidth=0.8) +
  scale_fill_manual(values = c("blue", "red"), labels = c("Vestibular", "Visual")) +
  scale_color_manual(values = c("blue", "red"), labels = c("Vestibular", "Visual")) +
  theme_classic() +  
  theme_modern() +
  labs(x = "Condition",  y = expression(beta ~ "Prev. Choice [A.U.]"), fill = "Modality", color = "Modality")+
  scale_x_discrete(labels = c('PrevChoice:NoFeedback' = 'No Feedback',
                              'PrevChoice:CorFeedback' = 'Feedback\nCorrect Choices',
                              'PrevChoice:IncorFeedback' = 'Feedback\nIncorrect Choices'))+ 
  scale_y_continuous(breaks = c(1.5, 1, 0.5, 0, -0.5, -1, -1.5, -2), limits = c(-1.5, 1.5))

