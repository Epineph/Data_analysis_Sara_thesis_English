# Data_analysis_Sara_thesis_English

R-markdown and raw data for Sara's Master's thesis in English

If you download the files, make sure to put all the files in the same directory (unless you like pain and suffering, i.e., disorganised folder structure and messy code.
Otherwise you may need to change the path in the code where the .csv (data), image of regression table, data used for illustrating residuals in regression models 
as well as the reference file. 

This all depends on the working directory, which I have coded as: 

this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

Here, dirname(parent.frame(2)$ofile) assigns the path of the directory containing your r-markdown file "Data_analysis_final.Rmd" to the variable
'this.dir' where the function setwd(this.dir) sets the working directory to the path contained in the variable 'this.dir', and hence your working directory 
is set to the path of the folder that contains your file(s). If all the files in this repository are in the same directory, no code needs to be changed, 
since R reads the files relative to your working directory.

If you want to keep the files in different folders, there are two different approaches:

1) If there is no systematic folder structure with respect to the R-markdown script and the files it reads (i.e., all the files are relatively randomly scatte)
then you have to let R know the absolute path in each variable that reads or loads a file on your PC.

For example, where the data gets loaded you would have to change
"RawDataAsNumerical.csv" to "/your/path/to/the/directory/RawDataAsNumerical.csv" on line 123 so that:
```
dataAsNumerical = read.csv(
  "RawDataAsNumerical.csv",
  na.strings = "Na",
  header = T,
  sep = ","
)
```
becomes:
```
dataAsNumerical = read.csv(
  "/your/path/to/the/directory/RawDataAsNumerical.csv",
  na.strings = "Na",
  header = T,
  sep = ","
)
```
The same would be true for
```
load("SCD.rda")
```
on line 459, where you would have to change load("SCD.rda") to load("/your/path/to/the/directory/SCD.rda").

The regression plot that is a PNG file would similarly have to be changed (line 502) so that:
```{=tex}
\includegraphics[width = \linewidth]{reg_table_2.png}
```
should be changed to:
```{=tex}
\includegraphics[width = \linewidth]{your/path/to/the/directory/reg_table_2.png}.
```
Lastly, the .bib file containing the references (line 119) would have to be changed from

```
r_refs("references.bib")
```
to
```
r_refs("your/path/to/the/directory/references.bib").
```
2) If there is a systematic folder structure in which the folder containing the R-markdown script also contains the folders in which the files that are read by the r-markdown script
are located. I.e., the folder with the r-markdown script is the parent directory and all the files imported by it is in child directories, e.g., a folder structure where
\folder_with_R_markdown_script\all_data_files. 

In this case, asssuming that the working directory is loaded like it is in the script, i.e., to the directory containing your r-markdown script, 
or, more correctly, to the path\to\the\folder\ containing the r-markdown script, all the files imported by the code would have to be referenced
relative to the working directory. For example, in this case the files would be loaded by using their relative path (indicated by the character ~),
so that the references.bib and .png file would be loaded as `r_refs("~/all_data_files/references.bib")` and 
`\includegraphics[width = \linewidth]{~/all_data_files/reg_table_2.png}`.

Alternatively, you could have several folders as child directories with respect to the folder containing the r-markdown script, the parent directory that also is your 
working directory. Then, for example the references would be in a folder called references, the .png file in a folder called graphics, the data file in a folder called rawData, and hence
these files would be loading accordingly: `r_refs("~/refences/references.bib")`, `\includegraphics[width = \linewidth]{~/graphics/reg_table_2.png}` and
`dataAsNumerical = read.csv("~/rawData/RawDataAsNumerical.csv", na.strings = "Na", header = T, sep = ",")`. Organizing your data using such a folder structure is very nice and organized,
and generally the preferred method because it is a very intuitive folder structure (keeping all your files in one folder can be quite messy, especially in large projects 
where your code may import hundreds of files of consisting of a wide range of data types) and therefore the preferred method. Since only 5 files are used in total, the messiness off the
one-folder approach is limited and the benefit is that path of the files imported by the script can be omitted (like in my script), since they are all contained in the immediate working
directory.

# Running the code

In order to run the code, one must first install R: https://cloud.r-project.org/ and R studio https://posit.co/download/rstudio-desktop/. All of which is free software. The packages loaded
in the script in the sections with multiple library(name) must be installed by the user. 
