# Stata example
Stata code example developed for the course [2525: Applied Economics](https://kursuskatalog.au.dk/en/course/116211/2525-Applied-Economics) at Aarhus University (AU), Department of Economics and Business Economics.

## Load data
Example on how to load data from .csv or .xlsx files.

## Figures
Example on how to set up, combine, and export figures.

## Tables
Example on how to export tables of descriptive statistics or estimation results to LaTeX, Excel, or Word.

Namely, I provide the same example in two separate do-files depending on your preferences:
* [Stata example using Word](https://github.com/ThorNoe/Stata_example/blob/main/Example_Stata_Word.do)
* [Stata example using LaTeX](https://github.com/ThorNoe/Stata_example/blob/main/Example_Stata_LaTeX.do) (and [pdf with outputs](https://github.com/ThorNoe/Stata_example/blob/main/LaTeX/main.pdf) compiled using the code in the [LaTeX folder](https://github.com/ThorNoe/Stata_example/tree/main/LaTeX))

In Danish, I explain the code in four [videos](https://panopto.au.dk/Panopto/Pages/Viewer.aspx?pid=16d10c85-77e2-4e52-822b-afae00080e9a) with time codes.

## Panel analysis
Example on how to analyze panel data.

# Collaborate on group projects
Your group can quickly get started writing collaboratively with LaTeX. It's a steep learning curve, but LaTeX is amazing for equations and all kinds of dynamic references compared to Word. That said, Word is far superior to Google Docs.

## Use Word in real-time
Aarhus University [provides access](https://studerende.au.dk/it-support/software) to collaborative group work in Microsoft Office 365.
* At [Office Online](https://www.office.com/), you can open a new Word document or one existing on your OneDrive.
  * "Share" access to the document with other AU e-mails or copy a link to it (loosen restriction such that anyone on AU with the link can edit).
  * You can write within you browser or even do real-time editing in your desktop version of Microsoft Word (select "Redigering" &rarr; "Åbn i skrivebordsprogram").
* At [OneDrive.live.com/login](https://onedrive.live.com/login), you can share a folder with the rest of your group to ease access to the Word document and other files.

## Use LaTeX in real-time
To handle LaTeX code, I highly recommend using the free [Overleaf](https://www.overleaf.com) editor in your browser:
1. Download the [.zip file](https://github.com/ThorNoe/article_template/archive/refs/heads/main.zip) of my [LaTeX article template](https://github.com/ThorNoe/article_template) (or the [.zip file](https://github.com/ThorNoe/Stata_example/raw/main/LaTeX.zip) with LaTeX code for the [pdf with outputs](https://github.com/ThorNoe/Stata_example/blob/main/LaTeX/main.pdf) of the above Stata example).
2. Create an [Overleaf](https://www.overleaf.com/register) account
   * Select <span style="background-color:green;color:white">"New Project"</span> &rarr; "Upload Project" &rarr; add the .zip file.
   * "Share" &rarr; add e-mail addresses of your other group members.
3. Learn the basics
   * Read the guide [Learn LaTeX in 30 minutes
](https://www.overleaf.com/learn/latex/Learn_LaTeX_in_30_minutes).
   * My setup is a bit more elaborate as the "main.tex" file uses the `\input{}` command to read files from the different folders.
     * Click on ">" next to the "preample" folder &rarr; open the "title_page.tex" file to edit title and authors.
     * Click on ">" next to the "sections" folder &rarr; open "data.tex" or another file to start writing.
     * **CTRL+s** saves your current file and *recompiles* the entire document. Do it often to catch compiling errors early.
     * 📄🟥"Logs and output files" next to the <span style="background-color:green;color:white">🔄🟩"Recompile"</span> button can help you locate and debug critical code errors or you can out-comment recent code and uncomment it gradually (**CTRL+'** adds/removes `%` at the beginning of each marked line). After major debugging, it can be necessary to choose <span style="background-color:green;color:white">🔄🟩"Recompile"</span> &rarr; "Recompile from scratch" to clear the cache memory.

### License
This repository is released under the [MIT License](https://github.com/ThorNoe/Stata_example/blob/main/LICENSE), that is, you can basically do anything with my code as long as you give appropriate credit and don’t hold me liable.
