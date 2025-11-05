
library(tidyverse)
library(jsonlite)
library(broom)

# load Longenhagen's grades
df_grades <- read_csv("data/longenhagen.csv")
df_bat <- df_grades %>% filter(!is.na(f_hit)) %>% select(player:summary, c_hit:throw)

# load Claude output
claude_raw <- fromJSON("data/longenhagen-structured.json")

# put Claude data into a format with one row per player
df_claude <- claude_raw %>% 
  unnest(traits_json) %>% 
  pivot_longer(-(player_name:processing_notes), names_to = "category") %>% 
  unnest(value) %>% 
  select(player_name:category, grade) %>% 
  filter(!is.na(grade)) %>% 
  pivot_wider(names_from = category, values_from = grade)

# analyze data on a tagged-mechanic level
df_compare <- df_bat %>% inner_join(df_claude, by = c("player" = "player_name"))
df_analyze <- df_compare %>% 
  pivot_longer(-c(player:processing_notes), names_to = "category", values_to = "grade", values_drop_na = T) %>% 
  group_by(category) %>% 
  filter(n() >= 30) %>% 
  ungroup()

# fit a model predicting each tag as a function of existing grades
df_mods <- df_analyze %>% 
  mutate(pos_grp = case_when(pos == "C" ~ "C", 
                             pos %in% c("2B", "SS", "CF") ~ "middle", 
                             TRUE ~ "corner")) %>% 
  nest(.by = category) %>% 
  mutate(m = map(data, ~ lm(grade ~ pos_grp + c_hit + I(f_hit - c_hit) + 
                              c_raw + I(f_raw - c_raw) + 
                              I(c_game - c_raw) + I(f_game - c_game) + 
                              c_run + 
                              c_field + I(f_field - c_field) + 
                              throw, 
                            data = .x)), 
         summs = map(m, glance))

# seeing which Claude traits are most correlated with existing tool grades
df_results <- df_mods %>% 
  unnest(summs) %>% 
  select(category, nobs, r.squared) %>% 
  arrange(r.squared)
