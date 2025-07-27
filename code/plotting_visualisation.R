#Plotting and Visualisation 
#26th July 2025 

#WARNING: The following command will clear RStudio environment 
#Clearing RStudio 
rm(list = ls())

#Loading and calling libraries and packages 
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readr)
library(ggthemes)
library(scales)

#Loading datasets 
#NOTE: Pls set working directory/file path accordingly 
#NOTE: sentiment_parsed_output.csv is the ouput file of text_parsing.ipynb
getwd()
analysed_dataset <- read_csv("/Users/rishabhbijani/Desktop/ra_app/sentiment_parsed_output.csv")
random_sample <- read_csv("/Users/rishabhbijani/Desktop/ra_app/movies_random_sample.csv")

#Checking the structure of the dataset 
str(analysed_dataset)

#Checking unique values in presence columns 
print(unique(analysed_dataset$hindu_muslim_presence))
print(unique(analysed_dataset$gender_relations_presence))
print(unique(analysed_dataset$nationalism_presence))
print(unique(analysed_dataset$lgbtq_presence))

#Recoding "Ambigous" as "Not Present"
analysed_dataset <- analysed_dataset %>%
  mutate(across(ends_with("_presence"), ~ ifelse(. == "Ambiguous", "Not Present", .)))

#PLOT 1: Theme Frequency
# Merge to get release year
merged <- analysed_dataset %>%
  left_join(random_sample %>% select(imdb_id, year_of_release_int), by = "imdb_id") %>%
  rename(release_year = year_of_release_int)

# Pivot to long format: one row per movie-theme
theme_presence_long <- merged %>%
  select(imdb_id, title, release_year,
         hindu_muslim_presence,
         gender_relations_presence,
         nationalism_presence,
         lgbtq_presence) %>%
  pivot_longer(
    cols = ends_with("_presence"),
    names_to = "theme",
    values_to = "presence"
  ) %>%
  filter(presence == "Present" & !is.na(release_year))

# Clean theme labels
theme_presence_long$theme <- recode(theme_presence_long$theme,
                                    hindu_muslim_presence = "Hindu–Muslim Relations",
                                    gender_relations_presence = "Gender Relations",
                                    nationalism_presence = "Nationalism",
                                    lgbtq_presence = "LGBTQIA+ Themes"
)

# Count how many movies had each theme by year
theme_freq <- theme_presence_long %>%
  group_by(release_year, theme) %>%
  summarise(count = n(), .groups = "drop")

# Plot
plot_frequency <- ggplot(theme_freq, aes(x = release_year, y = count, color = theme)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  geom_text(aes(label = count), vjust = -0.7, size = 3.5, show.legend = FALSE) +  # numbers on points
  labs(
    title = "Theme Frequency in Bollywood Films (2010–Present)",
    x = "Release Year",
    y = "Number of Movies",
    color = "Theme"
  ) +
  scale_x_continuous(breaks = seq(2010, 2024, 1)) +
  scale_y_continuous(breaks = pretty_breaks(n = 10)) +  # whole number breaks
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    legend.box = "horizontal"
  ) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE))  

# Display the plot
print(plot_frequency)

#Saving the frequency plot 
#NOTE: Pls change the path to save the plot accordingly 
ggsave("bollywood_theme_frequency.png", plot = plot_frequency, 
       path = "/Users/rishabhbijani/Desktop/ra_app/plots")

#PLOT 2: Average score across conservative-progressive axes by theme 
# Add year to main dataset
merged_sentiment <- analysed_dataset %>%
  left_join(random_sample %>% select(imdb_id, year_of_release_int), by = "imdb_id") %>%
  rename(release_year = year_of_release_int) %>%
  filter(!is.na(release_year))

# Pivot longer for conservative–progressive axis
sentiment_long <- merged_sentiment %>%
  select(release_year, imdb_id,
         ends_with("_presence"),
         ends_with("conservative_progressive")) %>%
  pivot_longer(
    cols = ends_with("conservative_progressive"),
    names_to = "theme_axis",
    values_to = "score"
  ) %>%
  filter(!is.na(score))

# Join with presence info
presence_long <- merged_sentiment %>%
  select(imdb_id,
         ends_with("_presence")) %>%
  pivot_longer(
    cols = ends_with("_presence"),
    names_to = "theme_presence",
    values_to = "presence"
  )

# Merge and clean
sentiment_facet <- sentiment_long %>%
  mutate(theme = str_replace(theme_axis, "_conservative_progressive", ""),
         presence_col = paste0(theme, "_presence")) %>%
  left_join(presence_long, by = c("imdb_id", "presence_col" = "theme_presence")) %>%
  filter(presence == "Present")

# Clean theme names
sentiment_facet$theme <- recode(sentiment_facet$theme,
                                hindu_muslim = "Hindu–Muslim Relations",
                                gender_relations = "Gender Relations",
                                nationalism = "Nationalism",
                                lgbtq = "LGBTQIA+ Themes"
)
avg_sentiment <- sentiment_facet %>%
  group_by(release_year, theme) %>%
  summarise(avg_score = mean(score), .groups = "drop")

plot_facet <- ggplot(avg_sentiment, aes(x = release_year, y = avg_score)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  geom_text(aes(label = round(avg_score, 2)), vjust = -0.8, size = 3.3, color = "black") +  # 👈 Add labels
  facet_wrap(~ theme, ncol = 2) +
  scale_x_continuous(breaks = seq(2010, 2024, 2)) +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(
    title = "Average Conservative–Progressive Score by Theme (2010–Present)",
    x = "Release Year",
    y = "Average Sentiment Score"
  ) +
  theme_economist_white() +
  theme(
    strip.text = element_text(face = "bold", size = 11),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
  )

print(plot_facet)

#Saving the plot 
#NOTE: Pls change the path accordingly 
ggsave("bollywood_average_score.png", plot = plot_facet, 
       path = "/Users/rishabhbijani/Desktop/ra_app/plots")


#PLOT 3: Positive-Negative Axis 


# Pivot longer using correct suffix
sentiment_posneg <- merged_sentiment %>%
  select(release_year, imdb_id,
         ends_with("_presence"),
         ends_with("negative_positive")) %>%
  pivot_longer(
    cols = ends_with("negative_positive"),
    names_to = "theme_axis",
    values_to = "score"
  ) %>%
  filter(!is.na(score))

# Join with presence info
presence_long <- merged_sentiment %>%
  select(imdb_id,
         ends_with("_presence")) %>%
  pivot_longer(
    cols = ends_with("_presence"),
    names_to = "theme_presence",
    values_to = "presence"
  )

# Merge and clean
sentiment_posneg_facet <- sentiment_posneg %>%
  mutate(theme = str_replace(theme_axis, "_negative_positive", ""),
         presence_col = paste0(theme, "_presence")) %>%
  left_join(presence_long, by = c("imdb_id", "presence_col" = "theme_presence")) %>%
  filter(presence == "Present")

# Clean theme names
sentiment_posneg_facet$theme <- recode(sentiment_posneg_facet$theme,
                                       hindu_muslim = "Hindu–Muslim Relations",
                                       gender_relations = "Gender Relations",
                                       nationalism = "Nationalism",
                                       lgbtq = "LGBTQIA+ Themes"
)

# Compute average score by year and theme
avg_posneg <- sentiment_posneg_facet %>%
  group_by(release_year, theme) %>%
  summarise(avg_score = mean(score), .groups = "drop")

# Plot
plot_posneg <- ggplot(avg_posneg, aes(x = release_year, y = avg_score)) +
  geom_line(color = "darkgreen", size = 1) +
  geom_point(color = "darkgreen", size = 2) +
  geom_text(aes(label = round(avg_score, 2)), vjust = -0.8, size = 3.3, color = "black") +
  facet_wrap(~ theme, ncol = 2) +
  scale_x_continuous(breaks = seq(2010, 2024, 2)) +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(
    title = "Average Positive–Negative Score by Theme (2010–Present)",
    x = "Release Year",
    y = "Average Sentiment Score"
  ) +
  theme_economist_white() +
  theme(
    strip.text = element_text(face = "bold", size = 11),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
  )

# Show and save
print(plot_posneg)

ggsave("bollywood_average_score_positive_negative.png", plot = plot_posneg,
       path = "/Users/rishabhbijani/Desktop/ra_app/plots")

 
#PLOT4: Inclusionary-Exclusionary 



# Pivot longer using correct suffix
sentiment_exclincl <- merged_sentiment %>%
  select(release_year, imdb_id,
         ends_with("_presence"),
         ends_with("_exclusionary_inclusionary")) %>%
  pivot_longer(
    cols = ends_with("_exclusionary_inclusionary"),
    names_to = "theme_axis",
    values_to = "score"
  ) %>%
  filter(!is.na(score))

# Merge with presence data
sentiment_exclincl_facet <- sentiment_exclincl %>%
  mutate(theme = str_replace(theme_axis, "_exclusionary_inclusionary", ""),
         presence_col = paste0(theme, "_presence")) %>%
  left_join(presence_long, by = c("imdb_id", "presence_col" = "theme_presence")) %>%
  filter(presence == "Present")

# Clean theme names
sentiment_exclincl_facet$theme <- recode(sentiment_exclincl_facet$theme,
                                         hindu_muslim = "Hindu–Muslim Relations",
                                         gender_relations = "Gender Relations",
                                         nationalism = "Nationalism",
                                         lgbtq = "LGBTQIA+ Themes"
)

# Compute average score by year and theme
avg_exclincl <- sentiment_exclincl_facet %>%
  group_by(release_year, theme) %>%
  summarise(avg_score = mean(score), .groups = "drop")

# Plot
plot_exclincl <- ggplot(avg_exclincl, aes(x = release_year, y = avg_score)) +
  geom_line(color = "purple", size = 1) +
  geom_point(color = "purple", size = 2) +
  geom_text(aes(label = round(avg_score, 2)), vjust = -0.8, size = 3.3, color = "black") +
  facet_wrap(~ theme, ncol = 2) +
  scale_x_continuous(breaks = seq(2010, 2024, 2)) +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(
    title = "Average Exclusionary–Inclusive Score by Theme (2010–Present)",
    x = "Release Year",
    y = "Average Sentiment Score"
  ) +
  theme_economist_white() +
  theme(
    strip.text = element_text(face = "bold", size = 11),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5)
  )

# Show and save
print(plot_exclincl)

ggsave("bollywood_average_score_exclusionary_inclusive.png", plot = plot_exclincl,
       path = "/Users/rishabhbijani/Desktop/ra_app/plots")




#PLOT 5 : Stacked Area Chart 

#Counting number of movies per year 
year_totals <- theme_freq %>%
  group_by(release_year) %>%
  summarise(total_movies = sum(count), .groups = "drop")

#Plotting 
plot_area <- ggplot(theme_freq, aes(x = release_year, y = count, fill = theme)) +
  geom_area(alpha = 0.8, position = "stack") +
  geom_text(
    data = year_totals,
    aes(x = release_year, y = total_movies + 0.3, label = total_movies),
    inherit.aes = FALSE,
    size = 3.5,
    vjust = 0
  ) +
  labs(
    title = "Stacked Area Chart of Theme Frequency (2010–Present)",
    x = "Release Year", y = "Number of Movies", fill = "Theme"
  ) +
  theme_economist() +
  scale_y_continuous(breaks = pretty_breaks(n = 8)) +
  scale_x_continuous(breaks = seq(2010, 2024, 1)) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  ) +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE))

# Display plot
print(plot_area)

#Saving Area Plot 
#NOTE: Pls change the path accordingly 
ggsave("bollywood_stacked_area_plot.png", plot = plot_area, 
       path = "/Users/rishabhbijani/Desktop/ra_app/plots")


