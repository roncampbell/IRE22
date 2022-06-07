# Fundamentals of R

<code>R</code> can clean, analyze and visualze vast amounts of data efficiently. Its power comes from the thousands of packages that programmers and scientists have created to extend it. We'll be using two of those packages to explore census data in the Denver metro area.

In R, packages first must be installed and then loaded. The IRE/NICAR staff has already installed the packages we'll be using for this lesson, but here for future reference is how to install a package:

> install.packages("xxx")  [where "xxx" is the name of a package]

To load a package for use, simply enter this at the prompt:

> library(xxx) [where xxx is the name of the package -- and notice, this time the package name is NOT in quotes]

A few more points before we dig in:

* Capitalization matters. If a variable is spelled "Cat", don't write "cat" or "CAT". 
* Punctuation matters. R will help you by creating parentheses in pairs; don't erase closing parentheses by mistake.
* Assign variables with this mark <code><-</code> (left arrow and hyphen). This is the assignment operator. The shortcut on Windows is Alt + minus sign; on Mac it is Option + minus sign.
* Comment out a line with the <code>#</code> (hash) mark.
* Finally, you can create a script in R. In fact, you can create scripts several different ways, including as a simple script, as a notebook and as a Markdown document. This is a Very Big Deal. You can insert comments in your code, helpful notes to your collaborators and your future self. You can recheck every stage of your work. You can re-run the same script a second, third and fourth time if you get new data. You can even steal - um, borrow - your code for future projects, confident that it will work. 

We'll begin by loading a couple of packages. If you're studying this after the conference, be sure to install the packages first.
  
  * > library(tidyverse)
  * > library(tidycensus)
  
The tidycensus package uses the Census Bureau's application programming interface (API) to download data directly from the census website. It is much, much faster than any of the bureau's own tools. Once you learn the basic syntax, tidycensus becomes almost second-nature.
  
The Census Bureau has 70+ racial categories, the vast majority of them multiracial groups (for example, Multiracial - three races - Non-Hispanic White, Non-Hispanic Black and Non-Hispanic Asian). However, it also lists simplified categories, and we'll use a simple 8-category set. Then we'll apply that set to the six Denver region metro counties: Adams, Arapahoe, Broomfield, Denver, Douglas and Jefferson, using the 3-digit FIPS codes for those counties. You can recycle this script for your own market, substituting your state and the FIPS codes for the counties that comprise your metro.  
  
First, we'll define the race categories, assigning plain-English names to the Census variables.

<code>race_vars <- c(Total = 'P2_001N',
               White = 'P2_005N',
               Hispanic = 'P2_002N',
               Black = 'P2_006N',
               AmericanIndian = 'P2_007N',
               Asian = 'P2_008N',
               PacIslander = 'P2_009N',
               OtherRace = 'P2_010N',
               Multiracial = 'P2_011N'
               )</code>
             
Let's stop briefly for a few housekeeping notes: First, we've given the Census Bureau's variables ("P2_001N", etc.) new names with an equal sign; easy and convenient. Second, we grouped nine variables together with "c(...)". That "c" stands for "concatenate" or "combine", and it comes in handy when you need to mash together several things. 
  
Third and most important, we've assigned all these renamed variables to yet another variable, which we're calling race_vars, and we've done that with the assignment operator, which I described above. You'll use the assignment operator way more often than the equal sign in R. 
  
We'll then make the call to the Census Bureau, specifying that we want "decennial" (once-a-decade) data from 2020, at the tract level, that we want it from Colorado ("CO"), from counties in the Denver metro, and that we specifically want race_vars, which we just defined. We also say "geometry = FALSE" because we don't need maps.
  
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
  
Well, um, okay. 
  
The first thing to do is to clean up the NAME field. We'll do that in a few steps, splitting the census tract, county and state into three fields, then eliminating the state field because we don't need it. (All the tracts are in Colorado.)
  
> DenverTracts <- DenverTracts %>% 
  separate(NAME, into = c('Tract', 'County', 'State'), sep = ',')
  
This operation creates a leading white space in front of each county name. We'll remove it in the next step.
  
> DenverTracts$County <- str_trim(DenverTracts$County, side = "left") 
  
Then we remove the unnecessary State column.
  
> DenverTracts[4] <- NULL
  
Now our file looks like this.
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts2.png?raw=true)
  
In the last couple of commands, we introduced a new operator, the pipe: <code>%>%</code>. In R, the pipe lets us string several commands together. You can read it to say, "And then do this." 
  
For example, the plain-English version of the R command where you first saw the pipe is "Take the existing DenverTracts data frame, separate the NAME column into new columns called Tract, County and State, using a comma as the separator, and put the results back into the DenverTracts data frame." 
  
The shortcut for the pipe in Windows is Alt-Shift-M; in Mac it is Command-Shift-M.
                     
The census data now looks better. But we want to see each tract's information on a single row. Right now we can see a tract's total on one line; then we have to skip down several lines to see the information on its White population, and skip down many more lines to see the Black population and so forth. 
  
The solution is to "pivot" the data, making it wide instead of long.
  
<code>DenverTracts <- DenverTracts %>% 
  pivot_wider(names_from = variable, values_from = value)</code>
  
Here's the result; in the view below, we can see eight of the 12 columns.  
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts3a.png?raw=true)

Now let's sort the tracts by population in descending order. 
  
<code>DenverTracts %>%
  arrange(desc(Total))</code>
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts3b.png?raw=true)
  
There are six counties in the Denver metro area. Let's summarize data for each county. We'll do that using the R "group_by" function; if you have used  SQL databases, this will be familiar territory.
  
<code>DenverCounties <- DenverTracts %>% 
  group_by(County) %>%
  summarize(Tracts = n(),
            PopTotal = sum(Total),
            WhiteTotal = sum(White),
            BlackTotal = sum(Black),
            HispanicTotal = sum(Hispanic),
            AsianTotal = sum(Asian)
  ) </code>
  
![]()
  
  focus on just one of them, Denver. We'll use a filter and a double-equal sign, <code>==</code>. In R, a single-equal sign, <code>=</code>, is used to assign variables. 
  
<code>DenverCityTracts <- DenverTracts %>%
  filter(County == 'Denver County')
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts4b.png?raw=true)
 
We've gone from 688 tracts in the metro area to 178 tracts in the city of Denver. Many of the remaining tracts are small. Let's focus on the largest tracts, those with at least 5,000 residents. We can do that by making a small change to the code we just wrote creating DenverCityTracts.
  
<code>DenverCityTracts <- DenverTracts %>%
  filter(County == 'Denver County' & Total >= 5000)</code>
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts4c.png?raw=true)
 
With that, we've gone from 688 tracts down to 37 - the 37 largest tracts in the city of Denver.
  
So far, we've been looking at tracts. But we can slice the data other ways. Let's return to the original 
