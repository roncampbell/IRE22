# Fundamentals of R

<code>R</code> can clean, analyze and visualize vast amounts of data efficiently. R is open-source -- free -- and is widely used in the academic and business world. It works well on Mac and Windows. For a guide to installing R and the most popular front-end, R Studio, see this [guide](https://bit.ly/ire-install-r) prepared by the IRE/NICAR staff.

R's power comes from the thousands of packages that programmers and scientists have created to extend it. We'll be using two of those packages to explore census data in the Denver metro area.

In R, packages first must be installed onto the hard drive and then loaded into memory. The IRE/NICAR staff has already installed the packages we'll be using for this lesson, but here for future reference is how to install a package:

> install.packages("xxx")  [where "xxx" is the name of a package]

To load a package for use, simply enter this at the prompt:

> library(xxx) [where xxx is the name of the package -- and notice, this time the package name is NOT in quotes]

Some rules of the R road before we dig in:

* Capitalization matters. If a variable is spelled "Cat", don't write "cat" or "CAT". 
* Punctuation matters. R will help you by creating parentheses in pairs; don't erase closing parentheses by mistake.
* Assign variables with this mark <code><-</code> (left arrow and hyphen). This is the assignment operator. The shortcut on Windows is Alt + minus sign; on Mac it is Option + minus sign.
* Combine two or more commands that you want done in sequence top-to-bottom with the pipe, <code>%>%</code>. The shortcut on Windows is Shift-Alt-M; on Mac it is Shift-Command-M. You can read the pipe as "and then do this." 
* Comment out a line with the <code>#</code> (hash) mark.
* Finally, you can create a script in R. In fact, you can create scripts several different ways: as a simple script, as a notebook and as a Markdown document. This is a Very Big Deal. You can insert comments in your code, helpful notes to your collaborators and your future self. You can recheck every stage of your work. You can re-run the same script as many times as you like if you get new data. You can even steal - um, borrow - part or all of one script for future projects, confident that it will work. 

We'll begin by starting R Studio, then clicking at upper right to create a new project. A project in R is a container for data and scripts. The project will take its name from the folder where we place it -- either a new folder created for the purpose or an existing folder where we already have data. The IRE/NICAR staff has already created a folder for this class, and we'll put our project there.
  
Next, go to the upper left and click on the green "+" sign; then click on R Notebook. You have now begun a script.
    
We'll first load a couple of packages. If you're studying this after the conference, be sure that you have already installed the packages -- reminder: <code>install.packages("xxxx")</code> -- before loading them into memory.
  
  * > library(tidyverse)
  * > library(tidycensus)
  
The tidycensus package uses the Census Bureau's application programming interface (API) to download data directly from the census website. It is much faster than any of the bureau's own tools. Once you learn the basic syntax, tidycensus becomes almost second-nature. You will need a key to the Census API site; keys are free and easy to get. Sign up [here](https://api.census.gov/data/key_signup.html).
  
Time is short during the class, and conference room internet hookups are notoriously slow. So we're going to take a shortcut. I wrote a script, <code>DemoTracts.R</code>., that pulls 2020 census tract data for the six Denver region metro counties: Adams, Arapahoe, Broomfield, Denver, Douglas and Jefferson, using the 3-digit FIPS codes for those counties. You'll find DemoTracts.R in the Data portion of this GitHub repo. Feel free to customize DemoTracts.R for your own market, substituting your state and the FIPS codes for the counties that comprise your metro. 
  
DemoTracts.R produces a comma-separated variable (csv) file, DenverTracts.csv, that we will use right now, using the R function <code>read_csv()</code>.
  
> DenverTracts <- read_csv("DenverTracts.csv")
  
Here's what the file looks like.
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts2a.png?raw=true)

Now let's sort the tracts by population in descending order. 
  
> DenverTracts %>%
  arrange(desc(Total))</code>
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts2b.png?raw=true)
  
There are six counties in the Denver metro area. Let's summarize data for each county. We'll do that using the R "group_by" function. If you have used SQL databases, this will look familiar.
  
> DenverCounties <- DenverTracts %>% 
  group_by(County) %>%
  summarize(Tracts = n(),
            PopTotal = sum(Total),
            WhiteTotal = sum(White),
            BlackTotal = sum(Black),
            HispanicTotal = sum(Hispanic),
            AsianTotal = sum(Asian))
 
![](https://github.com/roncampbell/IRE22/blob/images/DTracts5.png?raw=true)

  
It would be useful to know the percentages for some of the major races. We can do that by creating new columns with the mutate command.
  
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
 
There are 178 tracts in Denver County. We can get an idea of their size with the summary() function in R.
  
![](https://github.com/roncampbell/IRE22/blob/images/DenCityTractsSummary1.png?raw=true)  
  
This simple command produces six measures for a numerical column: the minimum, maximum, median, mean, and 1st and 3rd quartiles. If there are missing (NA) values, it will also count them. The summary tells us that a quarter of the Denver tracts have fewer than 3,000 residents while a quarter have at least 4,755 residents.
  
Let's focus on the largest tracts, those with at least 4,755 residents. We can do that by making a small change to the code we just wrote creating DenverCityTracts.
  
> DenverCityTracts <- DenverTracts %>%
  filter(County == 'Denver County' & Total >= 4755)
  
![](https://github.com/roncampbell/IRE22/blob/images/DTracts4c.png?raw=true)
 
With that, we've gone from 688 tracts down to 45 - the 45 largest tracts in the city of Denver.

R allows you to import data directly from the web. We'll pull some income data for the Denver metro area now using the tidycensus package. Reminder: You need a Census API key to do this, unless you want to use the DenverIncome.csv file attached to this repo. The instructions for signing up for an API key area are above.
  
> DenverIncome <- get_acs(
  geography = "county",
  state = "CO",
  county = c('001', '005', '014', '031', '035', '059'),
  variables = c(MedHHIncome = 'B19013_001'),
  year = 2020
)
DenverIncome
                  
![](https://github.com/roncampbell/IRE22/blob/images/DenCoInc1.png?raw=true)                  

This is the median household income for each of the six counties in the Denver metro. The data comes from the American Community Survey 2020 5-Year Estimates. The tidycensus syntax works like this: The first part, get_xxx asks for a specific census product, in this case, acs -- the American Community Survey. The next part, geography, is where we specify if want information broken down by state, congressional district, ZIP Code, tract or something else. Then we specify the state, using the postal abbreviation. At this point, we're asking for every county in Colorado; but on the next line, we limit it to six counties, specifying them by their FIPS codes. When listing two or more items, we precede the list with a "c", short for "combine" or "concatenate". Finally we list the census variable we want and, for convenience, assign it a plain-English name.                  

The tidyverse package includes a wonderful visualization program, ggplot2. We'll use it to compare median household income among the six counties.
                  
> ggplot(DenverIncome, aes(x = Income, y = NAME)) +
  geom_point(size = 3, color = "royalblue")
  
 ![](https://github.com/roncampbell/IRE22/blob/images/DenCoPlot.png?raw=true)
 
R has many colors built-in. Just type <code>colors()</code> in the console, hit enter, and read the list of 650+ colors for yourself. There are also add-on packages of colors like viridis and RColorBrewer.
  
Let's improve the chart. The median income for Denver and Adams counties look identical or nearly so. And the chart would be easier to read if the values were arranged by income instead of by name. 
  
> ggplot(DenverIncome, aes(x = estimate, y =reorder(NAME, estimate))) +
  geom_errorbarh(aes(xmin = estimate - moe, xmax = estimate + moe)) +
  geom_point(size = 3, color = "royalblue")

The vertical (y) axis is reordered by adding the estimate to the NAME field. 
  
The geom_errorbarh() adds horizontal bars depicting the margin of error (MOE) around each point. The minimum MOE is the estimate minus the MOE; the maximum MOE is the estimate plus the MOE.   
  
![](https://github.com/roncampbell/IRE22/blob/images/DenCoInc2.png?raw=true)

Finally, we'll add a title, change the background and eliminate the axis legends. For this part, we'll just take what we wrote a moment ago and add a few new lines.
  
> ggplot(DenverIncome, aes(x = estimate, y =reorder(NAME, estimate))) +
  geom_errorbarh(aes(xmin = estimate - moe, xmax = estimate + moe)) +
  geom_point(size = 3, color = "royalblue") +
  labs(title = "Median household income - Denver metro",
       caption = "Source: American Community Survey",
       x = "",
       y = "") +
  theme_minimal()
  
 ![](https://github.com/roncampbell/IRE22/blob/images/DenCoInc3.png?raw=true)
  
