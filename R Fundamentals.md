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

