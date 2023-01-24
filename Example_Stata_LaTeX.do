********************************************************************************
* STATA CODE EXAMPLE (OPTIONAL SUPPLEMENT FOR COURSE 2525: APPLIED ECONOMICS)
* LOAD DATA: Example on how to load data from .csv or .xlsx files
* FIGURES: Example on how to set up, combine, and export figures
* TABLES: Example on how to export tables of descriptive statistics or estimates
* PANEL ANALYSIS: Example on how to analyze panel data (BEYOND EXPECTED SKILLS)
* LATEX DOCUMENT: Download & compile code from GitHub.com/ThorNoe/Stata_example
* MIT LICENSE: Copyright (c) 2023 Thor Donsby Noe (give credit; no liability)
********************************************************************************
/* Installations
ssc install bcuse 	// access Wooldridge datasets for the examples below
ssc install estout	// export tables to Excel, Word, or LaTeX
*/

* Change directory to the folder with your data files (redundant for bcuse)
cd 				"C:\Users\au687527\GitHub\Stata_example"

* Set global references to existing folders for storing figures and tables
global figures 	"C:\Users\au687527\GitHub\Stata_example\LaTeX\figures"
global tables 	"C:\Users\au687527\GitHub\Stata_example\LaTeX\tables"


********************************************************************************
* LOAD DATA
* Scrap rate = percentage of manufactured items that is scrapped due to errors
* Grant = firm's workers get job training under the Michigan program that year
********************************************************************************
/* Example using DataBank.WorldBank.org/reports.aspx?source=2&series=SI.POV.GINI
import delimited Gini.csv, varnames(1) rowrange(1:267) numericcols(5/16) clear
browse
import excel Gini.xlsx, cellrange(A1:P267) firstrow clear // labels in first row
destring YR*, force float replace // convert string to numerical variables
des
sum
*/

* Loading data on firm scrap rates
bcuse jtrain, clear

* Declare data as a panel of firms (identified by firm codes) for xt commands
xtset fcode year // "strongly balanced", i.e. no firm is missing in any year

* Generate lead variable for figures below
gen grant_lead = grant[_n+1]				// dummy for job training next year
gen grant_lead2 = grant_lead[_n+1]			// dummy for job training in 2 years

* Linear time trend can capture yearly growth rate (due to technological change)
gen trend = year-1987

* Add labels from: rdrr.io/cran/wooldridge/man/jtrain.html
label variable scrap 	"Scrap rate"		// % of items scrapped due to errors
label variable lscrap 	"log(scrap rate)"	// natural logarithm of scrap rate
label variable grant 	"Grant"				// dummy for job training that year
label variable grant_1 	"Grant lagged"		// dummy for job training last year
label variable d88	 	"Year 1988"			// dummy for being in year 1988
label variable d89	 	"Year 1989"			// dummy for being in year 1989
label variable trend 	"Time trend"		// covering year t in {0,1,2}


********************************************************************************
* DESCRIPTIVE ANALYSIS (of panel data)
********************************************************************************
* Take a first look at the data
xtdescribe // balanced panel of 157 firms observed each year 1987-89
sort year fcode	// sort data by year and firm (required for "by year" command)
by year: tab grant if scrap!=. // scrap only recorded for 54 of the 157 firms
by year: sum scrap grant grant_1 if scrap!=. // scrap rate is reduced each year
/*	Of the 54 firms for which scrap rate is recorded,
	19 firms (35.2 %) received a grant in 1988,
	and another 10 firms (18.5 %) received a grant in 1989.
*/

* Take a closer look at variation in the reduced sample where scrap is observed
xtsum scrap grant grant_1 if scrap!=. // 54 firms observed over 3 years
/* overall:	Pooled mean, std.dev., min and max
	
   between:	Cross-section std.dev. (ignore mean, min, and max!)
			Measures the difference between the overtime means for each firms
			i.e. the variation in permanent differences between firms
	
    within:	Time series std.dev. (ignore mean, min, and max!)
			Measures the differences across time within each firm
			i.e. due to business cycles or (technological) evolution over time
			 
     scrap:	Variation between firms > variation over time within each firm
*/

* Table: Descriptive statistics - guide: repec.sowi.unibe.ch/stata/estout/esttab.html
estpost tabstat scrap lscrap grant /// scrap is right skewed (mean right of p50)
	, statistics(mean sd min p50 max) columns(statistics) /// 
	listwise // omits obs with any of the chosen variables missing (sample comparable to 'regress')
esttab using "$tables/descriptive.tex", replace style(tex) delimiter("&") /// create/overwrite LaTeX file
	label nonumbers nostar postfoot("\hline\end{tabular}") ///
	cells("mean sd min p50 max") ///
	stats(N, fmt(%12.0gc) labels("Observations"))

* Table: Descriptive statistics by year
estpost tabstat scrap lscrap grant ///
	, statistics(mean sd min p50 max count) columns(statistics) /// count obs for each row
	listwise by(year) // show subsamples by year
esttab using "$tables/descriptive_yearly.tex", replace style(tex) delimiter("&") ///
	label nonumbers nostar postfoot("\hline\end{tabular}") ///
	cells("mean sd min p50 max count") ///
	noobs // cells("count") makes it redundant to report observations in footer


********************************************************************************
* FIGURES (comparing firms with grant in 1988 to firms that never receive grant)
* Kernel density is similar to histogram but doesn't require fine-tuning of bins
********************************************************************************
* Figure: Kernel density in 1987 (by grant in 1988)
gr two	(kdensity scrap if d88==0 & d89==0 & grant_lead==1) ///
		(kdensity scrap if d88==0 & d89==0 & grant_lead==0 & grant_lead2==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Panel A: Scrap rates in 1987") xtitle("Scrap rate (per 100 items)") ///
		ytitle("Density") name(Fig_87, replace) // name for graph combine below
graph export "$figures/kernels_87.png", replace
sum scrap if d88==0 & d89==0 & grant_lead==1, detail // smallest=.28, p10=.45
sum scrap if d88==0 & d89==0 & grant_lead==0 & grant_lead2==0, detail // p10=.06
tab scrap if d88==0 & d89==0 & grant_lead==0 & grant_lead2==0
* Selection bias? No firm getting grant in 1988 scrapped less than 0.28% in 1987

* Figure: Kernel density in 1988 (by grant in 1988)
gr two	(kdensity scrap if d88==1 & grant==1) ///
		(kdensity scrap if d88==1 & grant==0 & grant_lead==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Panel B: Scrap rates in 1988") xtitle("Scrap rate (per 100 items)") ///
		ytitle("Density") name(Fig_88, replace) // name for graph combine below
graph export "$figures/kernels_88.png", replace
* A scrap rate < 7% is now more common among the firms that receive grant in 1988

* Figure: Kernel density in 1989 (by grant in 1988)
gr two	(kdensity scrap if d89==1 & grant_1==1) ///
		(kdensity scrap if d89==1 & grant_1==0 & grant==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Panel C: Scrap rates in 1989") xtitle("Scrap rate (per 100 items)") ///
		ytitle("Density") name(Fig_89, replace) // name for graph combine below
graph export "$figures/kernels_89.png", replace
* Now a much larger share have a very low scrap rate regardless of grant history

* Combine figures
graph combine Fig_87 Fig_88 Fig_89 /// right skewed each year (thick right tail)
		, title("Firms that receive grant in 1988 vs never receiving grant")
graph export "$figures/kernels_combined.png", replace


********************************************************************************
* ESTIMATION (panel analysis elaborates on Table 14.1 in Wooldridge 7e, p. 464)
********************************************************************************
estimates clear // clear estimates before creating table of estimation results

* Standard pooled OLS as a baseline
reg lscrap grant grant_1 d88 d89 // grant is insignificant
est store baseline, title("Baseline")

* Standard pooled OLS simplified with a yearly time trend instead of year dummies
reg lscrap grant grant_1 trend // grant is insignificant
est store trend, title("Trend")

* Standard pooled OLS with dummies to capture firm-specific effects
reg lscrap grant grant_1 d88 d89 i.fcode // identical to FE estimation but for constant and dummies
est store dummies, title("Dummies")

* FE estimation: time-demeaning eliminates firm-specific effect (within-transformation)
xtreg lscrap grant grant_1 d88 d89, fe // identical to table 14.1 in Wooldridge 7e, p. 464
est store FE, title("FE")

* FE estimation with cluster-robust std. errors (obs for same firm aren't i.i.d.)
xtreg lscrap grant grant_1 d88 d89, fe cluster(fcode) // lag is insignificant
est store FE_cluster, title("FE cluster robust") // see appendix 14A.2 in Wooldridge 7e, pp. 493-494

* Save complete estimation results as Excel file
estout * using "$tables/results.xls", replace /// create/overwrite Excel workbook
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) label /// use model titles & variable labels
	cells( b(star fmt(4)) se(par fmt(4)) ) ///
	stats( r2 N N_g g_avg, fmt(4 %12.0gc) labels("R-squared" "Obs." "Number of firms" "Obs. per firm") )

* Save reduced estimation results as LaTeX file (without dummies)
estout * using "$tables/results.tex", replace style(tex) /// create/overwrite LaTeX file
	starlevels(* .10 ** .05 *** .01) mlabels(,titles numbers) label ///
	cells( b(star fmt(4)) se(par fmt(4)) ) ///
	stats( r2 N N_g g_avg, fmt(4 %12.0gc) labels("R$^2$" "Obs." "Number of firms" "Obs. per firm") ) ///
	drop(_cons) indicate("Firm dummies=*fcode*") /// omit constant and firm dummies
	prehead("\begin{tabular}{lccccc}\hline") /// MANUALLY FIT NUMBER OF C's TO NUMBER OF MODELS!
	posthead("\hline") prefoot("\hline") ///
	postfoot("\hline\end{tabular}\\Standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.1")
