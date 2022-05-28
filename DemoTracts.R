#######################################
# Find local census tract data with R #
#######################################

# Working code for class at IRE 2022 in Denver

# Set working directory ---------------------------------------------------

# I use Mac directory conventions on import statements below

# Denver metro counties used below; substitute your state
# and counties to get local census information

# remove hash mark when setting working directory and place 
# working directory within parentheses

# setwd()

# Load packages -----------------------------------------
library(tidyverse)
library(tidycensus)

# define 2020 race variables
race_vars <- c(Total = 'P2_001N',
               White = 'P2_005N',
               Black = 'P2_006N',
               AmericanIndian = 'P2_007N',
               Asian = 'P2_008N',
               PacIslander = 'P2_009N',
               OtherRace = 'P2_010N',
               Multiracial = 'P2_011N',
               Hispanic = 'P2_002N')

# import 2020 population by tract for Denver metro counties
DenverTracts <- get_decennial(
  geography = "tract",
  state = "CO",
  county = c("001", "005", "014", "031", "035", "059"),
  variables = race_vars,
  year = 2020,
  geometry = FALSE
)

# split the NAME column
DenverTracts <- DenverTracts %>% 
  separate(NAME, into = c('Tract', 'County', 'State'), sep = ',')

# remove whitespace from County field
DenverTracts$County <- str_trim(DenverTracts$County, side = "left") 

# remove unneeded column "State" -- keep for multi-state files
DenverTracts[4] <- NULL

# pivot data frame from long to wide
DenverTracts <- DenverTracts %>% 
  pivot_wider(names_from = variable, values_from = value)

# export file to CSV
write_csv(DemoTracts, 'DemoTracts.csv')
