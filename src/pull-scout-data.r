library(tidyverse)
library(rvest)
library(snakecase)

html <- read_html("https://blogs.fangraphs.com/2025-top-100-prospects/")
html
#> {html_document}
#> <html lang="en">
#> [1] <head>\n<meta http-equiv="Content-Type" content="text/html; charset=UT ...
#> [2] <body>\n    <a href="#container" class="visually-hidden-focusable">Ski ...
#> 
#> 

html %>% 
  html_elements('.top-prospects-tool') %>% 
  html_attr("data-team")

players <- html %>% 
  html_elements("h3") %>% 
  html_elements("a") %>% 
  html_text2()

pos <- 
  html %>% 
  html_elements('.top-prospects-tool') %>% 
  html_attr("data-position")

teams <- html %>% 
  html_elements('.top-prospects-tool') %>% 
  html_attr("data-team")

tools <- 
  html %>% 
  html_elements('.table-grey')  %>% 
  html_elements(".table-player-0") %>% 
  html_table()

tldrs <- html %>% 
  html_elements(".top-prospects-tool") %>% 
  html_elements(".prospects-list-tldr") %>% 
  html_text2()

writeups <- html %>% 
  html_elements(".top-prospects-tool")  %>% 
  html_elements(".prospects-list-summary") %>% 
  html_text2()

df <- tibble(
  player = players, 
  team = teams, 
  pos = pos, 
  tldr = tldrs, 
  summary = writeups, 
  tools = tools
)
df_clean <- df %>% 
  unnest(tools) %>% 
  rename_with(to_any_case) %>% 
  mutate(changeup = coalesce(splitter, changeup)) %>% # no player has both
  select(-splitter) %>% 
  separate(fastball, c("c_fastball", "f_fastball"), convert = T) %>% 
  separate(slider, c("c_slider", "f_slider"), convert = T) %>% 
  separate(command, c("c_command", "f_command"), convert = T) %>% 
  separate(hit, c("c_hit", "f_hit"), convert = T) %>% 
  separate(raw_power, c("c_raw", "f_raw"), convert = T) %>% 
  separate(game_power, c("c_game", "f_game"), convert = T) %>% 
  separate(run, c("c_run", "f_run"), convert = T) %>% 
  separate(fielding, c("c_field", "f_field"), convert = T) %>% 
  separate(curveball, c("c_curveball", "f_curveball"), convert = T) %>% 
  separate(cutter, c("c_cutter", "f_cutter"), convert = T) %>% 
  separate(changeup, c("c_change", "f_change"), convert = T) %>% 
  separate(sits_tops, c("sits", "tops"), sep = " / ", convert = T) %>% 
  separate(sits, c("sits_low", "sits_high"), convert = T)

write_csv(df_clean, "data/longenhagen.csv", na = "")



