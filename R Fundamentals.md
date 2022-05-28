# Fundamentals of R

<code>R</code> can clean, analyze and visualze vast amounts of data efficiently. Its power comes from the thousands of packages that programmers and scientists have created to extend it. We'll be using two of those packages to explore census data in the Denver metro area.

In R, packages first must be installed and then loaded. The IRE/NICAR staff has already installed the packages we'll be using for this lesson, but here for future reference is how to install a package:

> install.packages("xxx")  [where "xxx" is the name of a package]

To load a package for use, simply enter this at the prompt:

> library(xxx) [where xxx is the name of the package -- and notice, this time the package name is NOT in quotes]

A few more points before we dig in:

* Capitalization matters. If a variable is spelled "Cat", don't write "cat" or "CAT". 
* Punctuation matters. R will help you by creating parentheses in pairs; don't erase closing parentheses by mistake.
* Assign variables with this mark <code><-</code> (left arrow and hyphen). The shortcut on Windows is Alt + minus sign; on Mac it is Option + minus sign.
* Comment out a line with the <code>#</code> (hash) mark.
* Finally, you can create a script in R. In fact, you can create scripts several different ways, including as a simple script, as a notebook and as a Markdown document. This is a Very Big Deal. You can insert comments in your code, helpful notes to your collaborators and your future self. You can recheck every stage of your work. You can re-run the same script a second, third and fourth time if you get new data. You can even steal - um, borrow - your code for future projects, confident that it will work. 

We'll begin by loading a couple of packages. The IRE/NICAR staff has already installed them, so you don't have to. If you're studying this after the conference, be sure to install the packages first.
  
  * > library(tidyverse)
  * > library(tidycensus)
  
The tidycensus package uses the Census Bureau's application programming interface (API) to download data directly from the census website. It is much, much faster than any of the bureau's own tools. Once you learn the basic syntax, tidycensus becomes almost second-nature.
  
The Census Bureau has 70+ racial categories, the vast majority of them multiracial groups (for example, Multiracial - three races - Non-Hispanic White, Non-Hispanic Black and Non-Hispanic Asian). However, it also lists simplified categories, and we'll use a simple 8-category set. Then we'll apply that to the six Denver region metro counties: Adams, Arapahoe, Broomfield, Denver, Douglas and Jefferson.  
  
First, we'll define the race categories, assigning plain-English names to the Census variables.

<code>race_vars <- c(Total = 'P2_001N',
               White = 'P2_005N',
               Black = 'P2_006N',
               AmericanIndian = 'P2_007N',
               Asian = 'P2_008N',
               PacIslander = 'P2_009N',
               OtherRace = 'P2_010N',
               Multiracial = 'P2_011N',
                   Hispanic = 'P2_002N')</code>
             
Next, we'll make the call to the Census Bureau, specifying that we want "decennial" (once-a-decade) data from 2020, at the tract level, that we want it from Colorado ("CO"), from counties in the Denver metro (listing FIPS codes for the six Denver metro counties), and citing "race_vars", which we just defined, as the stuff we want. We also say "geometry = FALSE" because we don't need maps.
  
<code>DenverTracts <- get_decennial(
  geography = "tract",
  state = "CO",
  county = c("001", "005", "014", "031", "035", "059"),
  variables = race_vars,
  year = 2020,
  geometry = FALSE
)</code>
  
Here's what the file looks like.
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts1.png?raw=true)
  
