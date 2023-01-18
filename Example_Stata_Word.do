********************************************************************************
* STATA CODE EXAMPLE (OPTIONAL SUPPLEMENT FOR COURSE 2525: APPLIED ECONOMICS)
* LOAD DATA: Examples on how to load data from .csv or .xlsx files
* FIGURES: Examples on how to set up, save, and combine figures
* TABLES: Examples on how to save tables of descriptive statistics and estimates
* PANEL ANALYSIS: Examples on how to analyze panel data (BEYOND EXPECTED SKILLS)
* MIT LICENSE: Copyright (c) 2023 Thor Donsby Noe
********************************************************************************
/* Installations
ssc install bcuse 	// access Wooldridge datasets for the examples below
ssc install estout	// export tables to Excel, Word, and LaTeX (descriptive)
ssc install outreg2	// export tables to Excel, Word (estimation results)
*/

* Change directory to the folder with your data files (redundant for bcuse)
cd 				"C:\Users\au687527\GitHub\Stata_example"

* Set global references to existing folders for storing figures and tables
global figures 	"C:\Users\au687527\GitHub\Stata_example\Figures"
global tables 	"C:\Users\au687527\GitHub\Stata_example\Tables"


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

* Generate lead variable for figures below
gen grant_lead = grant[_n+1]				// dummy for job training next year
gen grant_lead2 = grant_lead[_n+1]			// dummy for job training in 2 years

* Linear time trend can capture yearly growth rate (due to technological change)
gen trend = year-1987

* Add labels from: rdrr.io/cran/wooldridge/man/jtrain.html
label variable scrap 	"Scrap rate" 		// % of items scrapped due to errors
label variable lscrap 	"log(scrap rate)"	// natural logarithm of scrap rate
label variable grant 	"Grant"				// dummy for job training that year
label variable grant_1 	"Grant lagged"		// dummy for job training last year
label variable d88	 	"Year 1988"			// dummy for being in year 1988
label variable d89	 	"Year 1989"			// dummy for being in year 1989
label variable trend 	"Time trend"		// covering year t in {0,1,2}


********************************************************************************
* DESCRIPTIVE ANALYSIS (of panel data)
********************************************************************************
* Declare data as a panel of firms (each identified by their firm code)
xtset fcode year // "strongly balanced", i.e. no firm is missing in any year

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
esttab using "$tables/descriptive.rtf", replace /// create/overwrite Word document
	label nonumbers modelwidth(9) ///
	cells("mean sd min p50 max") ///
	stats(N, fmt(%12.0gc) labels("Observations"))

* Table: Descriptive statistics by year
estpost tabstat scrap lscrap grant ///
	, statistics(mean sd min p50 max count) columns(statistics) /// count obs for each row
	listwise by(year) // show subsamples by year
esttab using "$tables/descriptive_yearly.rtf", replace ///
	label nonumbers modelwidth(8) /// narrow modelwidth requires fewer digits (set manually)
	cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2)) count(fmt(0))") ///
	noobs // cells("count") makes it redundant to report observations in footer


********************************************************************************
* FIGURES (comparing firms with grant in 1988 to firms that never receive grant)
* Kernel density is similar to histogram but doesn't require fine-tuning of bins
********************************************************************************
* Figure: Kernel density in 1987 (by grant in 1988)
gr two	(kdensity scrap if d88==0 & d89==0 & grant_lead==1) ///
		(kdensity scrap if d88==0 & d89==0 & grant_lead==0 & grant_lead2==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Scrap rates in 1987") xtitle("Scrap rate (per 100 items)") ///
		ytitle("Density") name(Fig_87, replace) // name for graph combine below
graph export "$figures/kernels_87.png", replace
* Indicates (self) selection bias: firms getting grant in 88 scrapped more in 87

* Figure: Kernel density in 1988 (by grant in 1988)
gr two	(kdensity scrap if d88==1 & grant==1) ///
		(kdensity scrap if d88==1 & grant==0 & grant_lead==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Scrap rates in 1988") xtitle("Scrap rate (per 100 items)") ///
		ytitle("Density") name(Fig_88, replace) // name for graph combine below
graph export "$figures/kernels_88.png", replace
* A scrap rate < 7% is now more common among the firms that receive grant in 88

* Figure: Kernel density in 1989 (by grant in 1988)
gr two	(kdensity scrap if d89==1 & grant_1==1) ///
		(kdensity scrap if d89==1 & grant_1==0 & grant==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Scrap rates in 1989") xtitle("Scrap rate (per 100 items)") ///
		ytitle("Density") name(Fig_89, replace) // name for graph combine below
graph export "$figures/kernels_89.png", replace
* Now a much larger share have a very low scrap rate regardless of grant history

* Combine figures
graph combine Fig_87 Fig_88 Fig_89 /// right skewed each year (thick right tail)
		, title("Firms that receive grant in 1988 vs never receiving grant")
graph export "$figures/kernels_combined.png", replace


********************************************************************************
* ESTIMATION (panel analysis reproduces Table 14.1 in Wooldridge 7e, p. 464)
* Replace ".doc" with ".xls" to produce Excel workbook of results instead
********************************************************************************
* Standard pooled OLS as a baseline
reg lscrap grant grant_1 d88 d89 // grant is insignificant
outreg2 using "$tables/results.doc", replace /// create/overwrite Word document
	ctitle("Baseline, (se)") label nocons // use variable labels and omit constant

* Standard pooled OLS simplified with a yearly time trend instead of year dummies
reg lscrap grant grant_1 trend // grant is insignificant
outreg2 using "$tables/results.doc", /// append to existing Word table
	ctitle("Trend, (se)") label nocons
	
* Standard pooled OLS with dummies to capture firm-specific effects
reg lscrap grant grant_1 d88 d89 i.fcode // identical to FE estimation but for constant and dummies
outreg2 using "$tables/results.doc", ///
	ctitle("Dummies, (se)") label nocons ///
	drop(i.fcode) addtext(Firm dummies, Yes) // omit dummies

* FE estimation: time-demeaning eliminates firm-specific effect (within-transformation)
xtreg lscrap grant grant_1 d88 d89, fe // identical to table 14.1 in Wooldridge 7e
outreg2 using "$tables/results.doc", ///
	ctitle("FE, (se)") label nocons

* FE estimation with cluster-robust std. errors (obs for same firm aren't i.i.d.)
xtreg lscrap grant grant_1 d88 d89, fe vce(cluster fcode) // lag insignificant
outreg2 using "$tables/results.doc",
	ctitle("FE cluster robust, (se)") label nocons
