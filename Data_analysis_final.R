## ---- include=FALSE------------------------------------------------------
# options(knitr.purl.inline = TRUE)
library(papaja)
library(bookdown)


purl("Data_analysis_final.rmd")
library(RCurl)
library(tikzDevice)
library(MANOVA.RM)
library(nnet)
library(survey)
library(surveydata)
library(formatR)
# library(tidydice)
library(magrittr)
library(tcltk)
library(tcltk2)
# library(aplpack)
# library(shiny)
library(ggplot2)
# library(esquisse)
library(Publish)
library(tidyverse)
library(modelr)
library(equatiomatic)
library(rstatix)
library(ez)
library(psych)
# library(lme4)
library(Publish)
library(data.table)
# library(radiant)
library(dplyr)
library(statsExpressions)
library(ggstatsplot)
library(tidyr)
library(broom)
library(equatiomatic)
library(ggpubr)
library(ggsci)
library(methods)
library(gridExtra)
library(ggsignif)
library(rmarkdown)
library(TeachingDemos)
library(citr)
library(knitr)
library(here)
library(fs)
library(usethis)

# library(MASS)
# library(pander)
# library(pandoc)
library(jmv)
library(jtools)


## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = FALSE)


## ------------------------------------------------------------------------
setwd("C:/Users/heini/Desktop/R_projects/Sara_data")
r_refs("references.bib")


## ----loading data, echo=FALSE, tidy=TRUE---------------------------------


# dataAsNumerical = read.csv(
#   "RawData/RawDataAsNumerical.csv",
#   na.strings = "Na",
#   header = T,
#   sep = ",",
#   
# )


x <- getURL("https://raw.githubusercontent.com/Epineph/Data_analysis_Sara_thesis_English/main/RawDataAsNumerical.csv")
y <- read.csv(text = x)



data = data.frame(y)


# Recoding Sex, SubjectID and Sabbatical as factors

data$Sex = as.factor(data$Sex)

data$SubjectID = as.factor(data$SubjectID)

data$sabbatical = as.factor(data$sabbatical)

# Recoding likert-scale questions and age to numeric variables

recoded_columns = data.frame(data[, 5:22])


recoded_columns = lapply(recoded_columns, as.numeric)

recoded_columns = as.data.frame(recoded_columns)

data = data[, 1:4]
data[5:22] = recoded_columns

data$Age = as.numeric(data$Age)

# Removing Na's from column "Sex"

data = subset(data, data$Sex != "Na")

# Dummy-coding Sex, so that it can be used in linear-models

data_sexDummycoded = data %>%
  mutate(data, Sex = 
           recode_factor(Sex, "Male" = 0, "Female" = 1))

rm(recoded_columns)

colnames(data)[5:8] = c(
  "SP_EnglishReadingAbility",
  "SP_EnglishSpeakingAbility",
  "SP_EnglishWritingAbility",
  "SP_EnglishAbilityInGeneral"
)

d = data

d = subset(d, d$SP_EnglishReadingAbility!= "Na")

d = d %>%
  mutate(d, Sex_as_num = recode_factor(
    Sex, "Male" = 0, "Female" = 1))

colnames(d)[3] = "gender"



## ------------------------------------------------------------------------

# 
# t_test(data = data, formula = SP_EnglishReadingAbility ~ Sex, var.equal = F)


## ---- results='markup', echo=FALSE---------------------------------------
DemonstrationOfLawOfLargeNumbers = function(num_flips = 10) {
  coin <- c('heads', 'tails')
  flips <- sample(coin, size = num_flips, replace = TRUE)
  heads_freq <- cumsum(flips == 'heads') / 1:num_flips
  plot(
    heads_freq,
    # vector
    type = 'l',
    # line type
    lwd = 2,
    # width of line
    col = 'tomato',
    # color of line
    las = 1,
    # orientation of tick-mark labels
    ylim = c(0, 1),
    # range of y-axis
    xlab = "number of tosses",
    # x-axis label
    ylab = "relative frequency"
  )  # y-axis label
  abline(h = 0.5, col = 'gray50')
}



## ---- results='asis'-----------------------------------------------------
par(mfrow = c(2,2), 
    mar = c(0,0,2,1))
P_15tosses = DemonstrationOfLawOfLargeNumbers(25)
P_100tosses = DemonstrationOfLawOfLargeNumbers(100)
P_1000tosses = DemonstrationOfLawOfLargeNumbers(1000)
P_5000tosses = DemonstrationOfLawOfLargeNumbers(5000)


## ---- tidy=TRUE, results='asis', echo=TRUE-------------------------------
#Removing Na's, i.e., people
#who did not submit an answer
d = subset(d, d$SP_EnglishReadingAbility != "Na")

#Calculating the length of the
#vector of answers, giving us
#the sample size
n = length(d$SP_EnglishReadingAbility)
cat("Sample =", d[1:5, "SP_EnglishReadingAbility"], "\n")
cat("n =", n)


## ---- tidy=TRUE, results='markup', echo=TRUE, highlight=TRUE-------------

SP_EngReadAbility_sum = sum(
  d$SP_EnglishReadingAbility)


SP_EngReadAbility_n = length(
  d$SP_EnglishReadingAbility)

SP_EngReadAbility_average = 
  SP_EngReadAbility_sum * (1 / SP_EngReadAbility_n)

SP_EngReadAbility_average = round(SP_EngReadAbility_average, digits = 2)

cat(
  "The mean of self-perceived
  English reading ability
  across all subjects =",
  SP_EngReadAbility_average)


## ---- tidy=TRUE, results='asis', echo=TRUE, highlight=TRUE---------------
SP_EngReadAbility_mean = round(mean(d$SP_EnglishReadingAbility),digits = 2)

cat(
  "The mean of self-perceived
  English reading ability
  across all subjects =",
  SP_EngReadAbility_mean
)


## ---- echo=TRUE, results='asis'------------------------------------------
ggplot(d, 
       aes(SP_EnglishReadingAbility)) +
  geom_histogram(
    aes(y = after_stat(count)), 
    bins = 35) + theme_bw()


## ---- echo=TRUE, results='asis'------------------------------------------
# creating a vector for females
d_fem_EngReadAbility = 
  subset(d, d$gender == "Female")
# creating a vector for males
d_male_EngReadAbility = 
  subset(d, d$gender == "Male")
# remove Na's
d_fem_EngReadAbility = subset(d_fem_EngReadAbility, d_fem_EngReadAbility$SP_EnglishReadingAbility != "Na")

d_male_EngReadAbility = subset(d_male_EngReadAbility, d_male_EngReadAbility$SP_EnglishReadingAbility!= "Na")
# calculate sample size for males and females
d_fem_EngReadAbility_n = length(
  d_fem_EngReadAbility[
    ,"SP_EnglishReadingAbility"])
d_males_EngReadAbility_n = length(
  d_male_EngReadAbility$SP_EnglishReadingAbility)
cat("The first five observations for
    males are:", d_male_EngReadAbility[1:5, "SP_EnglishReadingAbility"], "and the sample
    size for males is:",
    d_males_EngReadAbility_n, "The first
    five observations for females are:",
    d_fem_EngReadAbility[
      1:5, "SP_EnglishReadingAbility"],
    "and the sample size for females is:",
    d_fem_EngReadAbility_n)

## ---- echo=TRUE, results='asis', highlight=TRUE--------------------------
d_male_EngReadAbility_mean = round(mean(
  d_male_EngReadAbility$SP_EnglishReadingAbility)
  , digits = 2)
d_fem_EngReadAbility_mean =
  round(mean(
    d_fem_EngReadAbility$SP_EnglishReadingAbility)
    , digits = 2)
cat("the mean for males and females is:", d_male_EngReadAbility_mean, "and", d_fem_EngReadAbility_mean, "respectively.")


## ---- fig.width=7.6, fig.height=5.8, fig.align='center',results='asis',highlight=TRUE, tidy=TRUE, echo=FALSE----
# d$residuals = residuals(MAP.Age)
# d$predicted = predict(MAP.Age)
load("SCD.rda")
d2 = data.frame(SCD)

#calculating the Mean Arterial Pressure,
# which is mathematically defines as
# the diastolic blood pressure plus
# one-thid times the difference between
# the systolic and diastolic blood pressure
d2$MAP = d2$Pdias + (1/3) * (d2$Psys - d2$Pdias)

# fitting the data to a linear model (lm), where
# MAP is the dependent variable modelled as a function
# of age
MAP.Age = lm(MAP~age, data = d2)

#plotting the data
library(ggplot2)
ggplot(data = d2, aes(x = age, y = MAP)) + 
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE, color= ggplot2::alpha('red3', alpha = 0.8)) +
  geom_segment(aes(xend = age, yend = predict(MAP.Age)), color = "antiquewhite3") +
  geom_point() +
  geom_point(aes(y = predict(MAP.Age)), shape = 1) +
  theme_bw()


## ------------------------------------------------------------------------
lm_ReadAbil_by_gender2 = lm(SP_EnglishReadingAbility ~ gender, data = d)

lm_ReadAbil_by_gender2_apa_print = apa_print(lm_ReadAbil_by_gender2)



## ---- echo=FALSE, results='asis', tidy=TRUE, fig.align='center', fig.height=5.0, fig.width=6.0----


gghistogram(d, "SP_EnglishReadingAbility", facet.by = "gender", binwidth = 0.3, color = "gender", palette = "aaas")



## ------------------------------------------------------------------------
var_fem_SP_engReadAbility = var(d_fem_EngReadAbility$SP_EnglishReadingAbility)

var_male_SP_engReadAbility = var(d_male_EngReadAbility$SP_EnglishReadingAbility)

cat("The variance for females and males is:", var_fem_SP_engReadAbility, "and", var_male_SP_engReadAbility, "respectively.")


## ---- fig.height=7.0, fig.width=7.0, results='asis'----------------------


ReadAbil_by_gender_t.test = d %>%
  t_test(
    SP_EnglishReadingAbility ~ gender,
    detailed = TRUE,
    var.equal = F,
    
  ) %>%
  add_significance()

stat.test <- d %>% 
  t_test(SP_EnglishReadingAbility ~ gender, detailed = T, var.equal = F, ) %>%
  add_significance()

ReadAbil_by_gender_t.test_kruskals_test = d %>%
kruskal_test(SP_EnglishReadingAbility ~ gender)


pwc = d %>% tukey_hsd(SP_EnglishReadingAbility ~ gender)

stat.test = stat.test %>% add_xy_position(x = "gender")
ggbarplot(d, x = "gender", y = "SP_EnglishReadingAbility", color = "gender", palette = "aaas", add = c("jitter", "mean_ci"), shape = "gender", error.plot = "errorbar", bxp.errorbar.width = 4.5, ylab = "Self-perceived English Reading Ability", ggtheme = theme_bw(), sort.by.groups = T, label = T, lab.nb.digits = 3,lab.size = 4.5, lab.vjust = 10.4, lab.col = ggplot2::alpha("darkslategray", alpha = 10), position = position_dodge(), fill = "snow2", xlab = "gender", title = "Self-perceived English reading ability gender difference") +
  stat_pvalue_manual(stat.test, hide.ns = TRUE, color = "turquoise4", size = 5, bracket.size = 0.8) +
  labs(
    subtitle = get_test_label(stat.test, detailed = TRUE, type = c("expression", "text")),
    caption = get_pwc_label(stat.test)
    )


## ----sumary stats, echo=FALSE, tidy=TRUE---------------------------------



d_summary = d
d_summary = d_summary %>%
  dplyr::select(
    columnNames = c(
      "SP_EnglishReadingAbility",
      "SP_EnglishSpeakingAbility",
      "SP_EnglishWritingAbility",
      "SP_EnglishAbilityInGeneral",
      "ComfortWithPresentEnglishAbilities",
      "FrequencyOfReadingListeningWatchingEnglishMaterial_InNonEnglishClasses",
      "ParticipatedInInterdisciplinaryCollaborationBetweenEnglishandOtherClasses",
      "ConsideredStudyingAbroadWhereTeachingIsInEnglish",
      "ToWhichDegreeEnglishImportantToYouInFutureStudies",
      "ToWhichDegreeExpectToReadTextsInEnglish",
      "ToWhichDegreeExpectCommunicationInEnglish",
      "ComfortableWithEnglishTeachingAndMaterialsInFutureStudies",
      "SelfPerceivedPreparednessInPotentialTeachingIsInEnglishInFutureStudies",
      "WouldRequireExtraSupportReadingWritingSpeakingUnderstandingEnglishInThisContext",
      "DoesSchoolSufficientlyPrepareStudentsToStudyInEnglishEnvironments",
      "ImportanceOfEnglishToForFindingWork",
      "DegreeOfExpectancyOfReadingEnglishTextInFutureWork",
      "DegreeOfExpectancyOfEnglishCommunicationInFutureWork")
  )

colnames(d_summary)[1:18] = c(
      "SP_EnglishReadingAbility",
      "SP_EnglishSpeakingAbility",
      "SP_EnglishWritingAbility",
      "SP_EnglishAbilityInGeneral",
      "ComfortWithPresentEnglishAbilities",
      "FreqReadWatchingEngInNonEngClasses",
      "CollaborationBetweenEngVSnonEngClasses",
      "ConsideredStudiesWithEngTeaching",
      "ImportanceofEngToYouInFutureStudies",
      "ExpectationsOfLikelihoodToReadEngTexts",
      "ToWhichDegreeExpectCommunicationInEnglish",
      "ComfortableWithEngTeachingMaterials",
      "PreparednessForPotentialEngTeachingLater",
      "WouldRequireExtraSupportForEng",
      "DoesSchoolSufficientlyPrepareforEngTeachingLater",
      "ImportanceOfEnglishToForFindingWork",
      "RatedLikelihoodToReadEngTextsFutureWork",
      "RatedLikelihoodOfEngCommunicationFutureWork")

d_summary$gender = d$gender

summary_stats_all = get_summary_stats(d_summary, type = "full", show = c("n", "mean", "sd", "se"))

d_summary_fem = subset(d_summary, d_summary$gender == "Female")

d_summary_male = subset(d_summary, d_summary$gender == "Male")


summary_stats_fem = get_summary_stats(d_summary_fem, type = "full", show = c("n", "mean", "sd", "se"))

summary_stats_male = get_summary_stats(d_summary_male, type = "full", show = c("n", "mean", "sd", "se"))

colnames(summary_stats_all)[1] = "All_subjects"

colnames(summary_stats_fem)[1] = "Females"

colnames(summary_stats_male)[1] = "Males"

acrossGenders_sum_stats = cbind(summary_stats_fem, summary_stats_male)

apa_table(summary_stats_all, placement = "h")





## ------------------------------------------------------------------------

apa_table(summary_stats_fem, placement = "h")
apa_table(summary_stats_male, placement = "h")


## ------------------------------------------------------------------------
# jmv_lm_test = jmv::anovaOneW(d, deps = SP_EnglishReadingAbility, group = gender, descPlot = T, phFlag = TRUE, qq = TRUE, phTest = TRUE, phMeanDif = TRUE, desc = TRUE, eqv = TRUE, norm = TRUE, welchs = TRUE)
# jmv_lm_test_anova = jmv_lm_test$anova$asDF
# jmv_lm_test_desc = jmv_lm_test$desc
# lm_read = jtools::j_summ(lm_ReadAbil_by_gender2)


## ------------------------------------------------------------------------
d2 = subset(d, select = -c(SubjectID, Age, sabbatical, Sex_as_num))


mydata.long <- d2 %>%
  pivot_longer(-gender, names_to = "variables", values_to = "value")

stat.test <- mydata.long %>%
  group_by(variables) %>%
  t_test(value ~ gender, detailed = T, var.equal = F) %>%
  adjust_pvalue(method = "BH") %>%
  add_significance()

stat.test = as.data.frame(stat.test)

apa_table(stat.test, placement = "h")




table3a = cbind(stat.test$variables, stat.test$n1, stat.test$n2,stat.test$p ,stat.test$p.adj, stat.test$p.adj.signif)

table3a = as.data.frame(table3a)
table3a[1:18,1] = c( "ComfortWithPresentEnglishAbilities",
      "ComfortableWithEngTeachingMaterials",
      "ConsideredStudiesWithEngTeaching", "ToWhichDegreeExpectCommunicationInEnglish", "ExpectationsOfLikelihoodToReadEngTexts", "DoesSchoolSufficientlyPrepareforEngTeachingLater", "FreqReadWatchingEngInNonEngClasses", "ImportanceOfEnglishToForFindingWork", "CollaborationBetweenEngVSnonEngClasses", "SP_EnglishAbilityInGeneral", "SP_EnglishReadingAbility", "SP_EnglishSpeakingAbility", "SP_EnglishReadingAbility", "PreparednessForPotentialEngTeachingLater", "ImportanceOfEnglishToForFindingWork", "RatedLikelihoodOfEngCommunicationFutureWork", "RatedLikelihoodToReadEngTextsFutureWork", "WouldRequireExtraSupportForEng")
colnames(table3a)[1:6] = c("Outcome", "n1", "n2", "p", "p_adj", "signif")

apa_table(table3a)

kable(table3a)



  





## ---- fig.height=7.0, fig.width=7.0, results='asis'----------------------
lm_comfortpresentEng_t = lm(ComfortWithPresentEnglishAbilities ~ gender, data = d)


pwc_comf = d %>% tukey_hsd(ComfortWithPresentEnglishAbilities ~ gender)



comf_by_gender_t.test = d %>%
  t_test(
    ComfortWithPresentEnglishAbilities ~ gender,
    detailed = TRUE,
    var.equal = F
  ) %>%
  add_significance()

pwc_comf = pwc_comf %>% add_xy_position(x = "gender")
ggbarplot(d, x = "gender", y = "ComfortWithPresentEnglishAbilities", color = "gender", palette = "aaas", add = c("jitter", "mean_ci"), shape = "gender", error.plot = "errorbar", bxp.errorbar.width = 4.5, ylab = "Comfort With Present Eng Abilities", ggtheme = theme_bw(), sort.by.groups = T, label = T, lab.nb.digits = 3,lab.size = 4.5, lab.vjust = 10.4, lab.col = ggplot2::alpha("darkslategray", alpha = 10), position = position_dodge(), fill = "snow2", xlab = "gender", title = "Comfort with present English Abilities") +
  stat_pvalue_manual(pwc_comf, hide.ns = TRUE, color = "turquoise4", size = 5, bracket.size = 0.8) +
  labs(
    subtitle = get_test_label(comf_by_gender_t.test, detailed = TRUE, type = c("expression", "text")),
  caption = get_pwc_label(pwc_comf)
    )
pwc_comf


## ---- fig.height=7.0, fig.width=7.0, results='asis'----------------------
lm_engAbilityInGeneral = lm(SP_EnglishAbilityInGeneral ~ gender, data = d)


pwc_engAbilInGeneral = d %>% tukey_hsd(SP_EnglishAbilityInGeneral ~ gender)



engAbilInGeneral_by_gender_t.test = d %>%
  t_test(
    SP_EnglishAbilityInGeneral ~ gender,
    detailed = TRUE,
    var.equal = F
  ) %>%
  add_significance()

pwc_engAbilInGeneral = pwc_engAbilInGeneral %>% add_xy_position(x = "gender")
ggbarplot(d, x = "gender", y = "SP_EnglishAbilityInGeneral", color = "gender", palette = "aaas", add = c("jitter", "mean_ci"), shape = "gender", error.plot = "errorbar", bxp.errorbar.width = 4.5, ylab = "Self-perceived English Ability in general", ggtheme = theme_bw(), sort.by.groups = T, label = T, lab.nb.digits = 3,lab.size = 4.5, lab.vjust = 10.4, lab.col = ggplot2::alpha("darkslategray", alpha = 10), position = position_dodge(), fill = "snow2", xlab = "gender", title = "Self-perceived English Ability in general by gender") +
  stat_pvalue_manual(pwc_comf, hide.ns = TRUE, color = "turquoise4", size = 5, bracket.size = 0.8) +
  labs(
    subtitle = get_test_label(engAbilInGeneral_by_gender_t.test, detailed = TRUE, type = c("expression", "text")),
  caption = get_pwc_label(pwc_engAbilInGeneral)
    )
pwc_engAbilInGeneral


## ---- fig.height=7.0, fig.width=7.0, results='asis'----------------------
lm_engSpeakingAbility = lm(SP_EnglishSpeakingAbility ~ gender, data = d)


pwc_engSpeakAbility = d %>% tukey_hsd(SP_EnglishSpeakingAbility ~ gender)



engSpeakingAbility_gender_t.test = d %>%
  t_test(
    SP_EnglishSpeakingAbility ~ gender,
    detailed = TRUE,
    var.equal = F
  ) %>%
  add_significance()

pwc_engSpeakAbility = pwc_engSpeakAbility %>% add_xy_position(x = "gender")
ggbarplot(d, x = "gender", y = "SP_EnglishSpeakingAbility", color = "gender", palette = "aaas", add = c("jitter", "mean_ci"), shape = "gender", error.plot = "errorbar", bxp.errorbar.width = 4.5, ylab = "Self perceived English Speaking Ability", ggtheme = theme_bw(), sort.by.groups = T, label = T, lab.nb.digits = 3,lab.size = 4.5, lab.vjust = 10.4, lab.col = ggplot2::alpha("darkslategray", alpha = 10), position = position_dodge(), fill = "snow2", xlab = "gender", title = "Self perceived English Speaking Ability") +
  stat_pvalue_manual(pwc_comf, hide.ns = TRUE, color = "turquoise4", size = 5, bracket.size = 0.8) +
  labs(
    subtitle = get_test_label(engSpeakingAbility_gender_t.test, detailed = TRUE, type = c("expression", "text")),
  caption = get_pwc_label(pwc_engSpeakAbility)
    )
pwc_engSpeakAbility


## ---- fig.height=7.0, fig.width=7.0, results='asis'----------------------
lm_engWritingAbility = lm(SP_EnglishWritingAbility ~ gender, data = d)


pwc_engWritingAbility = d %>% tukey_hsd(SP_EnglishWritingAbility ~ gender)



engWritingAbility_gender_t.test = d %>%
  t_test(
    SP_EnglishWritingAbility ~ gender,
    detailed = TRUE,
    var.equal = F
  ) %>%
  add_significance()

pwc_engWritingAbility = pwc_engWritingAbility %>% add_xy_position(x = "gender")
ggbarplot(d, x = "gender", y = "SP_EnglishWritingAbility", color = "gender", palette = "aaas", add = c("jitter", "mean_ci"), shape = "gender", error.plot = "errorbar", bxp.errorbar.width = 4.5, ylab = "Self perceived English Writing Ability", ggtheme = theme_bw(), sort.by.groups = T, label = T, lab.nb.digits = 3,lab.size = 4.5, lab.vjust = 10.4, lab.col = ggplot2::alpha("darkslategray", alpha = 10), position = position_dodge(), fill = "snow2", xlab = "gender", title = "Self perceived English Writing Ability by gender") +
  stat_pvalue_manual(pwc_engWritingAbility, hide.ns = TRUE, color = "turquoise4", size = 5, bracket.size = 0.8) +
  labs(
    subtitle = get_test_label(engWritingAbility_gender_t.test, detailed = TRUE, type = c("expression", "text")),
  caption = get_pwc_label(pwc_engWritingAbility)
    )
pwc_engWritingAbility


## ------------------------------------------------------------------------
# apa_lm_by_gender_engRead = apa_reg_table_lm_ReadAbil_by_Gender$table_block_results[[1]]$model_summary_extended
# 
# apa_lm_by_gender_engRead_type2 = apa_reg_table_lm_ReadAbil_by_Gender$table_block_results[[1]]$model_details_extended

