********************************************************************************
* STATA CODE EXAMPLE (OPTIONAL SUPPLEMENT FOR AU COURSE 2525: APPLIED ECONOMICS)
* LOAD DATA: Example on how to load data from .csv or .xlsx files
* FIGURES: Example on how to set up, combine, and export figures
* TABLES: Example on how to export tables of descriptive statistics or estimates
* PANEL ANALYSIS: Example on how to analyze panel data (BEYOND EXPECTED SKILLS)
* MIT LICENSE: Copyright (c) 2023 Thor Donsby Noe (give credit; no liability)
********************************************************************************
/* Installations and settings
ssc install bcuse 		// access Wooldridge datasets for the examples below
ssc install estout		// export tables to Excel, Word, or LaTeX (descriptive)
ssc install outreg2		// export tables to Excel, Word (estimation results)
ssc install extremes	// list extreme observations for a variable
set scheme s1color, permanently	// printer-friendly plain look for figures
set scheme s2color, permanently // default color scheme with light blue frame
help schemes 					// for more for color scheme options
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

* Declare data as a panel of firms (identified by firm codes) for xt commands
xtset fcode year // "strongly balanced", i.e. no firm is missing in any year

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
* Take a first look at the data (by year)
xtdescribe // balanced panel of 157 firms observed each year 1987-89
correlate scrap year // scrap rate has a negative correlation with time
correlate scrap grant_lead grant_lead2 if d88==0 & d89==0 // is treatment assignment random?
bysort year: tab grant if scrap!=. // scrap only recorded for 54 of the 157 firms
/*	Of the 54 firms for which scrap rate is recorded,
	19 firms (35.2 %) received a grant in 1988,
	and another 10 firms (18.5 %) received a grant in 1989.
*/
bysort year: sum scrap grant grant_1 if scrap!=. // mean scrap rate decreases each year

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

* Identify highest/lowest scrap rates (extreme obs of the first variable listed)
bysort year: extremes scrap fcode // persistency: the same firms recur each year

* Table: Descriptive statistics - guide: repec.sowi.unibe.ch/stata/estout/esttab.html
estpost tabstat scrap lscrap grant /// scrap is right skewed (mean right of p50)
	, statistics(mean sd min p50 max) columns(statistics) /// 
	listwise // omits obs with any of the chosen variables missing (sample comparable to 'regress')
esttab using "$tables/descriptive.rtf", replace /// create/overwrite Word document
	label nonumbers modelwidth(9) ///
	cells("mean sd min p50 max") /// format is flexible for each cell
	stats(N, fmt(%12.0gc) labels("Observations"))

* Table: Descriptive statistics by year
estpost tabstat scrap lscrap grant ///
	, statistics(mean sd min p50 max count) columns(statistics) /// count obs for each row
	listwise by(year) // show subsamples by year
esttab using "$tables/descriptive_yearly.rtf", replace ///
	label nonumbers modelwidth(8) /// narrow modelwidth only leaves space for 2 digits (set format manually)
	cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2)) count(fmt(0))") ///
	noobs // no observations reported in footer as cells("count") reports obs for each row instead


********************************************************************************
* FIGURES (comparing firms with grant in 1988 to firms that never receive grant)
* Kernel density is similar to histogram but doesn't require fine-tuning of bins
********************************************************************************
* Figure: Kernel density in 1987 (by grant in 1988)
gr two	(kdensity scrap if d88==0 & d89==0 & grant_lead==1) ///
		(kdensity scrap if d88==0 & d89==0 & grant_lead==0 & grant_lead2==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Panel A: Scrap rates in 1987") ///
		xtitle("Scrap rate (per 100 items)") ytitle("Density") ///
		xlab(0(5)30) ylab(0(.05).25) /// fix axis scales to match Fig_89
		name(Fig_87, replace) // name for graph combine below
graph export "$figures/kernels_87.png", replace
sum scrap if d88==0 & d89==0 & grant_lead==1, detail // smallest=.28, largest=18
sum scrap if d88==0 & d89==0 & grant_lead==0 & grant_lead2==0, detail // same median
tab scrap if d88==0 & d89==0 & grant_lead==0 & grant_lead2==0 // five<.28; three>18
* Selection bias? No firm getting grant in 1988 had close to 0 or very high scrap rate

* Figure: Kernel density in 1988 (by grant in 1988)
gr two	(kdensity scrap if d88==1 & grant==1) ///
		(kdensity scrap if d88==1 & grant==0 & grant_lead==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Panel B: Scrap rates in 1988") ///
		xtitle("Scrap rate (per 100 items)") ytitle("Density") ///
		xlab(0(5)30) ylab(0(.05).25) /// fix axis scales to match Fig_89
		name(Fig_88, replace) // name for graph combine below
graph export "$figures/kernels_88.png", replace
* A scrap rate < 7% is now more common among the firms that receive grant in 1988

* Figure: Kernel density in 1989 (by grant in 1988)
gr two	(kdensity scrap if d89==1 & grant_1==1) ///
		(kdensity scrap if d89==1 & grant_1==0 & grant==0) ///
		, legend(label(1 "Grant in 1988") label(2 "No grant")) ///
		title("Panel C: Scrap rates in 1989") ///
		xtitle("Scrap rate (per 100 items)") ytitle("Density") ///
		xlab(0(5)30) /// add tick marks for every 5 items scrapped
		name(Fig_89, replace) // name for graph combine below
graph export "$figures/kernels_89.png", replace
* Now a much larger share have a very low scrap rate regardless of grant history

* Combine figures
graph combine Fig_87 Fig_88 Fig_89 /// right skewed each year (thick right tail)
		, title("Firms that receive grant in 1988 vs never receiving grant")
graph export "$figures/kernels_combined.png", replace


********************************************************************************
* ESTIMATION (panel analysis elaborates on Table 14.1 in Wooldridge 7e, p. 464)
* Replace ".doc" with ".xls" to produce an Excel workbook with results instead
********************************************************************************
* Baseline (standard pooled OLS with year dummies)
reg lscrap grant grant_1 d88 d89 // grant is insignificant
outreg2 using "$tables/results.doc", replace /// create/overwrite Word document
	ctitle("Baseline, (se)") label nocons // use variable labels and omit constant

* Baseline simplified with a yearly time trend instead of year dummies
reg lscrap grant grant_1 trend // estimates, se, and R^2 unchanged
outreg2 using "$tables/results.doc", /// append to existing Word table
	ctitle("Trend, (se)") label nocons

* Take a look at the standard errors (does Gauss-Markov Assumptions hold?)
predict uhat, residuals // save predicted error term of the last regression
extremes uhat fcode year scrap, n(10) // violates MLR.2 (random sampling: obs are i.i.d.)
bysort year: sum uhat // violates MLR.4 (0 conditional mean) & MLR.5 (homoscedasticity)
drop uhat // remove the uhat variable such that it can be predicted again

* Baseline extended with dummies to capture firm-specific effects (permanent differences)
reg lscrap grant grant_1 d88 d89 i.fcode // identical to FE estimation but for constant and dummies
outreg2 using "$tables/results.doc", ///
	drop(i.fcode) addtext(Firm dummies, Yes) /// omit firm dummies but note it
	ctitle("Dummies, (se)") label nocons

* FE estimation: time-demeaning eliminates firm-specific effect (within-transformation)
xtreg lscrap grant grant_1 d88 d89, fe // identical to table 14.1 in Wooldridge 7e, p. 464
outreg2 using "$tables/results.doc", ///
	ctitle("FE, (se)") label nocons

* FE estimation with cluster-robust std. errors (obs for same firm aren't i.i.d.)
xtreg lscrap grant grant_1 d88 d89, fe cluster(fcode) // lag is insignificant
outreg2 using "$tables/results.doc", /// see appendix 14A.2 in Wooldridge 7e, pp. 493-494
	ctitle("FE cluster robust, (se)") label nocons
