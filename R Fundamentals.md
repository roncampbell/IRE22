# Fundamentals of R

<code>R</code> can clean, analyze and visualze vast amounts of data efficiently. Its power comes from the thousands of packages that programmers and scientists have created to extend it. We'll be using two of those packages to explore census data in the Denver metro area.

In R, packages first must be installed and then loaded. The IRE/NICAR staff has already installed the packages we'll be using for this lesson, but here for future reference is how to install a package:

> install.packages("xxx")  [where "xxx" is the name of a package]

To load a package for use, simply enter this at the prompt:

> library(xxx) [where xxx is the name of the package -- and notice, this time the package name is NOT in quotes]

Some rules of the R road before we dig in:

* Capitalization matters. If a variable is spelled "Cat", don't write "cat" or "CAT". 
* Punctuation matters. R will help you by creating parentheses in pairs; don't erase closing parentheses by mistake.
* Assign variables with this mark <code><-</code> (left arrow and hyphen). This is the assignment operator. The shortcut on Windows is Alt + minus sign; on Mac it is Option + minus sign.
* Combine two or more commands that you want done in sequence top-to-bottom with the pipe, <code>%>%</code>. The shortcut on Windows is Shift-Alt-M; on Mac it is Shift-Command-M. You can read the pipe as "and then do this." 
* Comment out a line with the <code>#</code> (hash) mark.
* Finally, you can create a script in R. In fact, you can create scripts several different ways, including as a simple script, as a notebook and as a Markdown document. This is a Very Big Deal. You can insert comments in your code, helpful notes to your collaborators and your future self. You can recheck every stage of your work. You can re-run the same script a second, third and fourth time if you get new data. You can even steal - um, borrow - your code for future projects, confident that it will work. 

We'll begin by loading a couple of packages. If you're studying this after the conference, be sure to install the packages first.
  
  * > library(tidyverse)
  * > library(tidycensus)
  
The tidycensus package uses the Census Bureau's application programming interface (API) to download data directly from the census website. It is much, much faster than any of the bureau's own tools. Once you learn the basic syntax, tidycensus becomes almost second-nature.  
  
Time is short during the class, and conference room internet hookups are notoriously slow. So we're going to take a shortcut. I wrote a script, <code>DemoTracts.R</code>., that pulls 2020 census tract data for the six Denver region metro counties: Adams, Arapahoe, Broomfield, Denver, Douglas and Jefferson, using the 3-digit FIPS codes for those counties. 
  
You'll find DemoTracts.R in the Data portion of this GitHub repo. Feel free to recycle this script for your own market, substituting your state and the FIPS codes for the counties that comprise your metro.
  
DemoTracts.R produces a comma-separated variable (csv) file, DenverTracts.csv, that we will use right now, using the R function <code>read_csv()</code>.
  
> DenverTracts <- read_csv("DenverTracts.csv")
  
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
  
In the last couple of commands, you saw the pipe operator at work. For example, the plain-English version of the R command where you first saw the pipe is "Take the existing DenverTracts data frame, separate the NAME column into new columns called Tract, County and State, using a comma as the separator, and put the results back into the DenverTracts data frame." 
  
The census data now looks better. But we want to see each tract's information on a single row. Right now we can see a tract's total on one line; then we have to skip down several lines to see the information on its White population, and skip down many more lines to see the Black population and so forth. 
  
The solution is to "pivot" the data, making it wide instead of long.
  
> DenverTracts <- DenverTracts %>% 
  pivot_wider(names_from = variable, values_from = value)</code>
  
Here's the result; in the view below, we can see eight of the 12 columns.  
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts3a.png?raw=true)

Now let's sort the tracts by population in descending order. 
  
> DenverTracts %>%
  arrange(desc(Total))</code>
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts3b.png?raw=true)
  
There are six counties in the Denver metro area. Let's summarize data for each county. We'll do that using the R "group_by" function; if you have used  SQL databases, this will be familiar territory.
  
> DenverCounties <- DenverTracts %>% 
  group_by(County) %>%
  summarize(Tracts = n(),
            PopTotal = sum(Total),
            WhiteTotal = sum(White),
            BlackTotal = sum(Black),
            HispanicTotal = sum(Hispanic),
            AsianTotal = sum(Asian))
 
![](https://github.com/roncampbell/IRE22/blob/images/DTracts5.png?raw=true)

  
It would be useful to know the percentages for some of the major races. While we're at it, let's reorder the columns so we can see the percentages without having to scroll across.
  
> DenverCounties <- DenverCounties %>%
  mutate(WhitePer = 100 * (WhiteTotal / PopTotal),
         HispanicPer = 100 * (HispanicTotal / PopTotal),
         BlackPer = 100 * (BlackTotal / PopTotal),
         AsianPer = 100 * (AsianTotal / PopTotal)) %>%
  select(County, Tracts, PopTotal, WhitePer, HispanicPer, BlackPer, AsianPer, WhiteTotal, HispanicTotal, BlackTotal, AsianTotal)

![](https://github.com/roncampbell/IRE22/blob/images/DTracts6.png?raw=true)  
  
Now let's focus on just one of the six counties - the biggest, Denver City and County. We'll use a filter and a double-equal sign, <code>==</code>. In R, a single-equal sign, <code>=</code>, is used to assign variables. 
  
> DenverCityTracts <- DenverTracts %>%
  filter(County == 'Denver County')
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts4b.png?raw=true)
 
We've gone from 688 tracts in the metro area to 178 tracts in the city of Denver. Many of the remaining tracts are small. Let's focus on the largest tracts, those with at least 5,000 residents. We can do that by making a small change to the code we just wrote creating DenverCityTracts.
  
> DenverCityTracts <- DenverTracts %>%
  filter(County == 'Denver County' & Total >= 5000)
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts4c.png?raw=true)
 
With that, we've gone from 688 tracts down to 37 - the 37 largest tracts in the city of Denver.

