clear all
version 9
snapshot erase _all
set more off,perm
dis _newline(200)
capture log close
log using "../log/Effects of land titling.log", replace

****************************************************************************************************
****************** Property rights for the poor: Effects of land titling ***************************
****************************************************************************************************

                             ********** Sebasti·n Galiani **************
                             ********** Ernesto Schargrodsky ***********

****************************************************************************************************

cd "/Users/JOR/Dropbox/Replication/data/new_jun13/do"
*cd "D:/Users/ewhitney/Dropbox (IFPRI)/Replication/data/new_jun13/do"

*** Creates matching datasets
*do "../do/Matching datasets_ew"
*do "../do/Matching datasets_ew_altmatch.do"

*** Table 1: Pre-treatment characteristics *********************************************************
	use "../data/investment", clear
	
	* Panel A
/*	ORIGINAL COMMANDS
	ttest distanceToCreek if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch
	ttest distToNonSquatted if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch
	ttest parcelSurface if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch
	ttest blockCorner if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch	*/

	*I am making a matrix and will export to excel. for each ttest i need to run -mean- command to capture the SE
mat panelA=J(4,7,.)

	local i=0
	foreach x in distanceToCreek distToNonSquatted parcelSurface blockCorner	{
		local ++i	// shift row down 1
	mean `x' if neighborhood<5 & repeatedParcel==0&propertyOffer==0
			mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat panelA[`i',2] = B
			mat drop temp B
	mean `x' if neighborhood<5 & repeatedParcel==0&propertyOffer==1
			mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat panelA[`i',4] = B
			mat li B

	ttest `x' if neighborhood<5 & repeatedParcel==0, by (propertyOffer) unequal welch
	mat panelA[`i',1] = r(mu_1)
	mat panelA[`i',3] = r(mu_2)
	mat panelA[`i',5] = r(mu_1) - r(mu_2)
	mat panelA[`i',6] = r(se)
	mat panelA[`i',7]=r(N_2)+r(N_1)	
}

*N for each ttest is 1082, will report in title

putexcel A1=matrix(panelA) using ../output/outputtables,replace
 		
	* Panel B
/*	ORIGINAL COMMANDS
	ttest ageOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest genderOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest argentineOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest educationYearsOrigSquatter if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest argentineOrigSquatterFather if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest educYearsOrigSquatterFather if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest argentineOrigSquatterMother if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	ttest educYearsOrigSquatterMother if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch	*/
mat panelB=J(8,7,.)

	local i=0
	foreach x in ageOrigSquatter genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 	///
	argentineOrigSquatterFather educYearsOrigSquatterFather argentineOrigSquatterMother educYearsOrigSquatterMother		{
		local i=`i'+1
	mean `x' if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1&propertyOffer==0
			mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat panelB[`i',2] = B
			mat drop temp B
			gen sample`i'=e(sample)
	mean `x' if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1&propertyOffer==1
			mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat panelB[`i',4] = B
			replace sample`i'=1 if e(sample)
	ttest `x' if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, by (propertyOffer) unequal welch
	mat panelB[`i',1] = r(mu_1)
	mat panelB[`i',3] = r(mu_2)
	mat panelB[`i',5] = r(mu_1) - r(mu_2)
	mat panelB[`i',6] = r(se)
	mat panelB[`i',7]=r(N_2)+r(N_1)
}

putexcel A10=matrix(panelB) using ../output/outputtables,modify

egen sample=rowmax(sample*)
drop sample1-sample8

*now rerun panel A using sample from panel B (union of all obs used in every ttest)
mat panelAalt=J(4,7,.)

	local i=0
	foreach x in distanceToCreek distToNonSquatted parcelSurface blockCorner	{
		local i=`i'+1
	mean `x' if neighborhood<5 & repeatedParcel==0&propertyOffer==0&sample
			mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat panelAalt[`i',2] = B
			mat drop temp B
	mean `x' if neighborhood<5 & repeatedParcel==0&propertyOffer==1&sample
			mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat panelAalt[`i',4] = B
			mat li B

	ttest `x' if neighborhood<5 & repeatedParcel==0 &sample, by (propertyOffer) unequal welch
	mat panelAalt[`i',1] = r(mu_1)
	mat panelAalt[`i',3] = r(mu_2)
	mat panelAalt[`i',5] = r(mu_1) - r(mu_2)
	mat panelAalt[`i',6] = r(se)
	mat panelAalt[`i',7]=r(N_2)+r(N_1)
}


putexcel A20=matrix(panelAalt) using ../output/outputtables,modify
***now copy/paste results for Table 1 into main xlsx file

***OUR Table 4 (breakdown of Parcel, household, and child observations from original analysis)

***Before running tests, lets look at the households that are included in Panel A of Table 1. The count is 1082. However, only
*a maximum of 448 of these are included in the analysis. 634 are included in the ttests in Panel A Table 1 but are excluded from
*subsequent analysis. Who are these 634?
*lets look at parcels and households across neighborhoods, by arrival and selection in randomization, and by offer and receipt early/late

*make a variable to capture the second household in the cases of repeated parcels.
egen temp=max(repeated),by(parcelId )
gen otherrepeat=(repeated==0&temp==0)|(repeated==1&temp==1)
drop temp

gen digit1=householdArrivedBefore1986						//going to recode, leave the original intact
recode digit1 .=2											//recode so we can make a value representing these missing values
replace digit1=digit1+1										//now we have values of 1 (arrived after) 2 (arrived before) and 3 (not selected)

gen digit2=neighborhood==5								//0=contig,1=san martin

gen digit3=0												//control
replace digit3=1 if propertyRightOfferEarly					//1=early offer
replace digit3=2 if propertyRightOfferLate					//2=late offer
replace digit3=3 if propertyRightEarly						//3=early receipt
replace digit3=4 if propertyRightLate						//4=late receipt

egen neighborhoodarrive=concat(digit1 digit2 digit3)		//concat, will leave us with max 3*2*5=30 unique values: 
																	//selection/arrival (arrival before=0, after=1, not selected=2)
																	//noncontiguous neighborhood (0/1)
																	//offer (0-4)
destring neighborhoodarrive,replace							//probably not necessary

gen str_d1="Selected, Arrived After" 			if digit1==1
replace str_d1="Selected, Arrived Before" 		if digit1==2
replace str_d1="Not Selected"					if digit1==3

gen str_d2="Contiguous" 						if digit2==0
replace str_d2="San Martin" 					if digit2==1

gen str_d3="Control"							if digit3==0
replace str_d3="Early Offer" 					if digit3==1
replace str_d3="Late Offer" 					if digit3==2
replace str_d3="Early Receipt" 					if digit3==3
replace str_d3="Late Receipt" 					if digit3==4
	
egen neigharr_str=concat(str_d1 str_d2 str_d3),punct(", ")
labmask neighborhoodarrive,values(neigharr_str)
*drop neigharr_str digit* str_d*

tab neighborhoodarrive repeated,m							//heres our initial table

***look only at the sample of 300
tab formerOwner propertyOffer
keep if repeatedParcel==0
tab formerOwner propertyOffer
keep if neighborhood<5 
tab formerOwner propertyOffer
keep if inBothDatasets==3
tab formerOwner propertyOffer
keep if householdArrivedBefore1986==1
tab formerOwner propertyOffer

***how many owners are associated with treatment and control (using offer as def of treatment)?
collapse (max) propertyRight propertyOffer propertyRightEarly propertyRightLate propertyRightOfferEarly propertyRightOfferLate,by(formerO)

br formerOwner propertyOffer propertyRightOfferEarly propertyRightOfferLate
***four owners are associated with parcels that received the property right offer.
***three of these owners are assoc with parcels that received the offer early (1989-91).
***the remaining owner is assoc with parcels that received the offer late.


****************************************************************************************************

	use "../data/investment", clear
	
log off
gen ageOsMiss=0
replace ageOsMiss=1 if ageOrigSquatter==.
*recode ageOfOrigSquatterDummy 0=. if ageOsMiss==1	// recode dummy var to missing if age is missing
gen argentinaFatherOsMiss=0
replace argentinaFatherOsMiss=1 if argentineOrigSquatterFather==.
replace argentineOrigSquatterFather=0 if argentineOrigSquatterFather==.
gen argentinaMotherOsMiss=0
replace argentinaMotherOsMiss=1 if argentineOrigSquatterMother==.
replace argentineOrigSquatterMother=0 if argentineOrigSquatterMother==.
gen educationOfTheFatherMiss=0
replace educationOfTheFatherMiss=1 if levelEducOfTheOrigSquatterFather==.
replace educYearsOrigSquatterFather=0 if levelEducOfTheOrigSquatterFather==.
gen educationOfTheMotherMiss=0
replace educationOfTheMotherMiss=1 if levelEducOfTheOrigSquatterMother==.
replace educYearsOrigSquatterMother=0 if levelEducOfTheOrigSquatterMother==.
snapshot save, label("Investment dataset (#1)")
log on

*** Table 2: Household attrition *******************************************************************
/*	ORIGINAL COMMANDS
	ttest householdArrivedBefore1986 if (repeatedParcel==0 & neighborhood<5), by (propertyOffer) unequal welch
	ttest householdArrivedBefore1986 if (repeatedParcel==0 & propertyRightOfferLate==0 & neighborhood<5), by (propertyOffer) unequal welch
	ttest householdArrivedBefore1986 if (repeatedParcel==0 & propertyRightOfferEarly==0 & neighborhood<5), by (propertyOffer) unequal welch
*/

mat table2=J(3,8,.)
	local i=0
	mean householdArrivedBefore1986 if repeatedParcel==0 & neighborhood<5&propertyOffer==0
				mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat table2[1,2] = B[1,1]
			mat drop temp B
	mean householdArrivedBefore1986 if repeatedParcel==0 & neighborhood<5&propertyOffer==1
				mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat table2[1,4] = B[1,1]
			mat drop temp B
	mean householdArrivedBefore1986 if repeatedParcel==0 & propertyRightOfferLate==0 & neighborhood<5&propertyOffer==1
				mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat table2[1,6] = B[1,1]
			mat drop temp B
	mean householdArrivedBefore1986 if repeatedParcel==0 & propertyRightOfferEarly==0 & neighborhood<5&propertyOffer==1
				mat temp=[1,1]
			mat temp[1,1]=e(V)
			matmap temp B,map(sqrt(@))
			mat table2[1,8] = B[1,1]
			mat drop temp B
	ttest householdArrivedBefore1986 if (repeatedParcel==0 & neighborhood<5), by (propertyOffer) unequal welch
		mat table2[1,1] = r(mu_1)
		mat table2[1,3] = r(mu_2)
		mat table2[2,3] = r(mu_1) - r(mu_2)
		mat table2[2,4] = r(se)
		mat table2[3,3]=r(N_2)+r(N_1)
	ttest householdArrivedBefore1986 if (repeatedParcel==0 & propertyRightOfferLate==0 & neighborhood<5), by (propertyOffer) unequal welch
		mat table2[1,5] = r(mu_2)
		mat table2[2,5] = r(mu_1) - r(mu_2)
		mat table2[2,6] = r(se)
		mat table2[3,5]=r(N_2)+r(N_1)
	ttest householdArrivedBefore1986 if (repeatedParcel==0 & propertyRightOfferEarly==0 & neighborhood<5), by (propertyOffer) unequal welch
		mat table2[1,7] = r(mu_2)
		mat table2[2,7] = r(mu_1) - r(mu_2)
		mat table2[2,8] = r(se)
		mat table2[3,7]=r(N_2)+r(N_1)
		
putexcel A26=matrix(table2) using ../output/outputtables,modify
***now copy/paste results for Table 2 into main xlsx file

*** Table 3: Housing investment ********************************************************************

	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter argentinaFatherOsMiss educationYearsOrigSquatter 			///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 			///
	argentineOrigSquatterMother argentinaMotherOsMiss educYearsOrigSquatterMother educationOfTheMotherMiss 			///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
outreg2 using ../output/table3.xls,replace stats(coef tstat) bdec(3) tdec(3) label
	
	local i=1
	sca de coeff1=_b[propertyRight]
	sum goodWalls if e(sample) & propertyRight==0
	mat tables=J(12,8,.)
	***table 3: rows 1,2 for matrix output matrix(tables)
	mat tables[1,`i']=r(mean)
	sca de mean`i'=r(mean)
	sca de delta`i'=coeff`i'*100/mean`i'
	mat tables[2,`i']=delta`i'

	
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 		///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 			///
	educYearsOrigSquatterMother educationOfTheMotherMiss 															///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
outreg2 using ../output/table3.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sca de coeff`i'=_b[propertyRight]
	sum goodRoof if e(sample) & propertyRight==0
	mat tables[1,`i']=r(mean)
	sca de mean`i'=r(mean)
	sca de delta`i'=coeff`i'*100/mean`i'
	mat tables[2,`i']=delta`i'
	
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 				///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 			///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 			///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 								///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
outreg2 using ../output/table3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	local i=`i'+1
	sca de coeff`i'=_b[propertyRight]
	sum constructedSurface if e(sample) & propertyRight==0
	mat tables[1,`i']=r(mean)
	sca de mean`i'=r(mean)
	sca de delta`i'=coeff`i'*100/mean`i'
	mat tables[2,`i']=delta`i'
	
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 					///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 			///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 			///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 								///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
outreg2 using ../output/table3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	local i=`i'+1
	sca de coeff`i'=_b[propertyRight]
	sum concreteSidewalk if e(sample) & propertyRight==0
	mat tables[1,`i']=r(mean)
	sca de mean`i'=r(mean)
	sca de delta`i'=coeff`i'*100/mean`i'
	mat tables[2,`i']=delta`i'
		
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 			///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 			///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 			///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 								///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
outreg2 using ../output/table3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	local i=`i'+1
	sca de coeff`i'=_b[propertyRight]
	sum overallHousingAppearance if e(sample) & propertyRight==0
	mat tables[1,`i']=r(mean)
	sca de mean`i'=r(mean)
	sca de delta`i'=coeff`i'*100/mean`i'
	mat tables[2,`i']=delta`i'
		

**** Table 4: Robustness of housing investment results: good walls *********************************
	* col 1
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 		///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 			///
	educYearsOrigSquatterMother educationOfTheMotherMiss 															///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	outreg2 using ../output/table4.xls,replace stats(coef tstat) bdec(3) tdec(3)  label

	* col 2
	reg goodWalls propertyRight																					///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* col 3
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 						///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	
	* col 4
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 		///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 			///
	educYearsOrigSquatterMother educationOfTheMotherMiss 															///
	if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	
	* col 5
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 		///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 			///
	educYearsOrigSquatterMother educationOfTheMotherMiss 															///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, 	///
	cluster(blockId)
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* col 6
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 		///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 			///
	educYearsOrigSquatterMother educationOfTheMotherMiss 															///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, 	///
	cluster(formerOwner)
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	
	* col 7
	reg goodWalls propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 		///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 			///
	educYearsOrigSquatterMother educationOfTheMotherMiss 															///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	
	* col 8
	ivreg goodWalls (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted 	///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 			///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 			///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 								///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* col 9
	reg goodWalls propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted 	///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 			///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 			///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 								///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	test propertyRightEarly=propertyRightLate
	mat tables[4,1]=r(F)
	***table 4: row 4 for matrix output matrix(tables)

	* col 10
		use "../new/investmentMatching.dta", clear
		drop if goodWalls == .
		set seed 1
	atts goodWalls propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* col 11 and 12
		use "../new/investmentMatching_altmatch.dta", clear
		drop if goodWalls == .
		set seed 1
	atts goodWalls propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,replace stats(coef tstat) bdec(3) tdec(3)  label
	atts goodWalls propertyRight,  pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts goodWalls propertyRight,  pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts goodWalls propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts goodWalls propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	mat n=J(1,1,.)
	local b=1
	atts goodWalls propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,replace stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,replace

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts goodWalls propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts goodWalls propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}				
	
	* col 11 (orig)
	snapshot restore 1
	reg goodWalls propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 						///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.
	outreg2 using ../output/table4.xls,append stats(coef tstat) bdec(3) tdec(3)  label

****************************************************************************************************

log off
use "../data/householdSize", clear
gen ageOsMiss=0
replace ageOsMiss=1 if ageOrigSquatter==.
*recode ageOfOrigSquatterDummy 0=. if ageOsMiss==1	// recode dummy var to missing if age is missing
gen argentinaFatherOsMiss=0
replace argentinaFatherOsMiss=1 if argentineOrigSquatterFather==.
replace argentineOrigSquatterFather=0 if argentineOrigSquatterFather==.
gen argentinaMotherOsMiss=0
replace argentinaMotherOsMiss=1 if argentineOrigSquatterMother==.
replace argentineOrigSquatterMother=0 if argentineOrigSquatterMother==.
gen educationOfTheFatherMiss=0
replace educationOfTheFatherMiss=1 if levelEducOfTheOrigSquatterFather==.
replace educYearsOrigSquatterFather=0 if levelEducOfTheOrigSquatterFather==.
gen educationOfTheMotherMiss=0
replace educationOfTheMotherMiss=1 if levelEducOfTheOrigSquatterMother==.
replace educYearsOrigSquatterMother=0 if levelEducOfTheOrigSquatterMother==.

***create logged income variables for robustness checks
foreach x of varlist householdHeadIncome totalHouseholdIncome totalHouseholdIncomePerCapita totalHouseholdIncomePerAdult	{
	replace `x'=`x'+1 if `x'==0
	gen ln`x'=ln(`x')
	local l`x': var lab `x'
	la var ln`x' "Logged `x'"
}

snapshot save, label("Household size dataset (#2)")
log on

*** Table 5: Household size ************************************************************************
	***table 5: row 6 for matrix output matrix(tables)

	* reg 1
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 	///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 			///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 				///
	educYearsOrigSquatterMother educationOfTheMotherMiss 																///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table5.xls,replace stats(coef tstat) bdec(3) tdec(3) label
	
	local i=1
	sum householdSize if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)

	* reg 2
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy 		///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather 			///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother 				///
	educYearsOrigSquatterMother educationOfTheMotherMiss 																///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum spouse if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)

	* reg 3
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 			///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 				///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 				///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 									///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	
	outreg2 using ../output/table5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum numberChildrensMoreThan14 if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)

	* reg 4
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 					///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 				///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 				///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 									///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum numberOtherRelatives if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)
	
	* reg 5
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 					///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 				///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 				///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 									///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum numberChildrens5_13 if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)
	
	* reg 6
	reg numberChildrens5_13 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner 				///
	distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter 						///
	educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather 			///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 			///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
	sum numberChildrens5_13 if e(sample) & propertyRight==0

	outreg2 using ../output/table5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum numberChildrens5_13 if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)
	
	* reg 7
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted 					///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter 				///
	argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss 				///
	argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 									///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum numberChildrens0_4 if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)
	
	* reg 8
	reg numberChildrens0_4 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner 				///
	distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter 						///
	educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather 			///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss 			///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum numberChildrens0_4 if e(sample) & propertyRight==0
	mat tables[6,`i']=r(mean)
	
****************************************************************************************************

log off
use "../data/education", clear
gen ageOsMiss=0
replace ageOsMiss=1 if ageOrigSquatter==.
*recode ageOfOrigSquatterDummy 0=. if ageOsMiss==1	// recode dummy var to missing if age is missing
gen argentinaFatherOsMiss=0
replace argentinaFatherOsMiss=1 if argentineOrigSquatterFather==.
replace argentineOrigSquatterFather=0 if argentineOrigSquatterFather==.
gen argentinaMotherOsMiss=0
replace argentinaMotherOsMiss=1 if argentineOrigSquatterMother==.
replace argentineOrigSquatterMother=0 if argentineOrigSquatterMother==.
gen educationOfTheFatherMiss=0
replace educationOfTheFatherMiss=1 if levelEducOfTheOrigSquatterFather==.
replace educYearsOrigSquatterFather=0 if levelEducOfTheOrigSquatterFather==.
gen educationOfTheMotherMiss=0
replace educationOfTheMotherMiss=1 if levelEducOfTheOrigSquatterMother==.
replace educYearsOrigSquatterMother=0 if levelEducOfTheOrigSquatterMother==.
snapshot save, label("Education dataset, full sample (#3)")
log on

*** Table 6: Education. Offspring of the household head ********************************************
	***table 6: row 8 for matrix output matrix(tables)

	* col 1
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,replace stats(coef tstat) bdec(3) tdec(3) label
	
	local i=1
	sum schoolAchievement if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	
	* col 2
	reg schoolAchievement propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather ///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother ///
	educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum schoolAchievement if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	
	* col 3
	keep if childAge>=13 & childAge<21
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum primarySchoolCompletion if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	
	* col 4
	reg primarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather ///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother ///
	educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum primarySchoolCompletion if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	
	* col 5
	keep if childAge>=18 & childAge<21
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum secondarySchoolCompletion if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	
	* col 6
	reg secondarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather ///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother ///
	educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum secondarySchoolCompletion if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	
	* col 7
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum postSecondaryEducation if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	
	* col 8
	reg postSecondaryEducation propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ///
	ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather ///
	argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother ///
	educationOfTheMotherMiss

	outreg2 using ../output/table6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum postSecondaryEducation if e(sample) & propertyRight==0
	mat tables[8,`i']=r(mean)
	

*** Table 7: Access to credit **********************************************************************
	***table 7: row 10 for matrix output matrix(tables)

	snapshot restore 2	//this recalls the householdSize dataset saved above
	* col 1
	reg creditCardBankAccount propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table7.xls,replace stats(coef tstat) bdec(3) tdec(3) label
	
	local i=1
	sum creditCardBankAccount if e(sample) & propertyRight==0
	mat tables[10,`i']=r(mean)
	
	* col 2
	reg nonMortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table7.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum nonMortgageLoan if e(sample) & propertyRight==0
	mat tables[10,`i']=r(mean)
	
	* col 3
	reg informalCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table7.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum informalCredit if e(sample) & propertyRight==0
	mat tables[10,`i']=r(mean)
	
	* col 4
	reg groceryStoreCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table7.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum groceryStoreCredit if e(sample) & propertyRight==0
	mat tables[10,`i']=r(mean)
	
	* col 5
	reg mortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter ///
	argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table7.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum mortgageLoan if e(sample) & propertyRight==0
	mat tables[10,`i']=r(mean)
	
	* col 6
	reg mortgageLoan propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table7.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum mortgageLoan if e(sample) & propertyRight==0
	mat tables[10,`i']=r(mean)
	

*** Table 8: Labor market **************************************************************************
	***table 8: row 12 for matrix output matrix(tables)

	* col 1
	reg householdHeadIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table8.xls,replace stats(coef tstat) bdec(3) tdec(3) label
	
	local i=1
	sum householdHeadIncome if e(sample) & propertyRight==0
	mat tables[12,`i']=r(mean)
	
	* col 2
	reg totalHouseholdIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table8.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum totalHouseholdIncome if e(sample) & propertyRight==0
	mat tables[12,`i']=r(mean)
	
	* col 3
	reg totalHouseholdIncomePerCapita propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table8.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum totalHouseholdIncomePerCapita if e(sample) & propertyRight==0
	mat tables[12,`i']=r(mean)
	
	* col 4
	reg totalHouseholdIncomePerAdult propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1

	outreg2 using ../output/table8.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum totalHouseholdIncomePerAdult if e(sample) & propertyRight==0
	mat tables[12,`i']=r(mean)
	
	* col 5
	reg employedHouseholdHead propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	

	outreg2 using ../output/table8.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	local i=`i'+1
	sum employedHouseholdHead if e(sample) & propertyRight==0
	mat tables[12,`i']=r(mean)

***now copy/paste results for Table 3 through 8 into main xlsx file using xls files created from outreg2 and data from temp1 sheet in main doc
	putexcel C7=mat(tables) using ../output/replicated_tables,modify sheet("tempmain") 

	***APPENDIX
mat append=J(18,10,.)
*** Table A.1: Good roof ***************************************************************************
	snapshot restore 1	
	* col 1
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter ///
	argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA1.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* col 2
	reg goodRoof propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 3
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 4
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter ///
	argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 5
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter ///
	argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 6
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter ///
	argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 7
	reg goodRoof propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter ///
	argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 8
	ivreg goodRoof (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 9
	reg goodRoof propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	test propertyRightEarly=propertyRightLate
		mat append[1,1]=r(F)

	* col 10 orig
		use "../new/investmentMatching.dta", clear
		drop if goodRoof == .
		set seed 1
	atts goodRoof propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 10 and 11
		use "../new/investmentMatching_altmatch.dta", clear
		drop if goodRoof == .
		set seed 1
	atts goodRoof propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts goodRoof propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts goodRoof propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts goodRoof propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts goodRoof propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts goodRoof propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts goodRoof propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts goodRoof propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}				
		
	* col 12 orig
	snapshot restore 1
	reg goodRoof propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.
		outreg2 using ../output/tableA1.xls,append stats(coef tstat) bdec(3) tdec(3) label

*** Table A.2: Constructed surface *****************************************************************
	* col 1
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA2.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* col 2
	reg constructedSurface propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 3
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 4
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 5
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 6
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 7
	reg constructedSurface propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss ///
	genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather ///
	educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 8
	ivreg constructedSurface (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 9
	reg constructedSurface propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ///
	ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss ///
	educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	test propertyRightEarly=propertyRightLate
		mat append[2,1]=r(F)

	* col 10
		use "../new/investmentMatching.dta", clear
		drop if constructedSurface == .
		set seed 1
	atts constructedSurface propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label

		* col 10 and 11
		use "../new/investmentMatching_altmatch.dta", clear
		drop if constructedSurface == .
		set seed 1
	atts constructedSurface propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label	
	atts constructedSurface propertyRight ,  pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts constructedSurface propertyRight ,  pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts constructedSurface propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts constructedSurface propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label


	local b=`b'+1
	atts constructedSurface propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts constructedSurface propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts constructedSurface propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
	
	* col 12
	snapshot restore 1
	reg constructedSurface propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ///
	if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.
		outreg2 using ../output/tableA2.xls,append stats(coef tstat) bdec(3) tdec(3) label

*** Table A.3: Concrete sidewalk *******************************************************************
	* col 1
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA3.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* col 2
	reg concreteSidewalk propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 3
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 4
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 5
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 6
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 7
	reg concreteSidewalk propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 8
	ivreg concreteSidewalk (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 9
	reg concreteSidewalk propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	test propertyRightEarly=propertyRightLate
		mat append[3,1]=r(F)

	* col 10
		use "../new/investmentMatching.dta", clear
		drop if concreteSidewalk == .
		set seed 1
		atts concreteSidewalk propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 10 and 11
		use "../new/investmentMatching_altmatch.dta", clear
		drop if concreteSidewalk == .
		set seed 1
	atts concreteSidewalk propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label	
	atts concreteSidewalk propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts concreteSidewalk propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts concreteSidewalk propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts concreteSidewalk propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts concreteSidewalk propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts concreteSidewalk propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts concreteSidewalk propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
	
	* col 12
	snapshot restore 1
	reg concreteSidewalk propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.
		outreg2 using ../output/tableA3.xls,append stats(coef tstat) bdec(3) tdec(3) label

*** Table A.4: Overall housing apppearance *********************************************************
	* col 1
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA4.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* col 2
	reg overallHousingAppearance propertyRight if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 3
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 4
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 5
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 6
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 7
	reg overallHousingAppearance propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 8
	ivreg overallHousingAppearance (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 9
	reg overallHousingAppearance propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	test propertyRightEarly=propertyRightLate
		mat append[4,1]=r(F)

	* col 10
		use "../new/investmentMatching.dta", clear
		drop if overallHousingAppearance == .
		set seed 1
	atts overallHousingAppearance propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
			outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 10 and 11
		use "../new/investmentMatching_altmatch.dta", clear
		drop if overallHousingAppearance == .
		set seed 1
	atts overallHousingAppearance propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label	
	atts overallHousingAppearance propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts overallHousingAppearance propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts overallHousingAppearance propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts overallHousingAppearance propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts overallHousingAppearance propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts overallHousingAppearance propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts overallHousingAppearance propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
	
	* col 12
	snapshot restore 1
	reg overallHousingAppearance propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 & repeatedParcel==0 & inBothDatasets==3 & nonSurveyed==.
		outreg2 using ../output/tableA4.xls,append stats(coef tstat) bdec(3) tdec(3) label

*** Table A.5: Durable consumption *****************************************************************
	* col 1
	reg hasRefrigetratorWithFreezer propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
		outreg2 using ../output/tableA5.xls,replace stats(coef tstat) bdec(3) tdec(3) label
	
	* col 2
	reg hasRefrigetratorWithoutFreezer propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
		outreg2 using ../output/tableA5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 3
	reg laundryMachine propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
		outreg2 using ../output/tableA5.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* col 4
	reg hasTv propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1	
		outreg2 using ../output/tableA5.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col5
	reg hasCellularPhone propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA5.xls,append stats(coef tstat) bdec(3) tdec(3) label

*** Table A.6: Number of household members *********************************************************
	snapshot restore 2
	* Col 1
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA6.xls,replace stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 2
	reg householdSize propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 4
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 5
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg householdSize propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 7
	ivreg householdSize propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg householdSize (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg householdSize propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	test propertyRightEarly=propertyRightLate
		mat append[6,1]=r(F)
		
	* Col 10
		use "../new/householdSizeMatching", clear
		drop if householdSize == .
		set seed 1
	atts householdSize propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 10 and 11
		use "../new/householdSizeMatching_altmatch", clear
		drop if householdSize == .
		set seed 1
	atts householdSize propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label	
	atts householdSize propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts householdSize propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA6.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts householdSize propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts householdSize propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts householdSize propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts householdSize propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts householdSize propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
		
*** Table A.7: Household head spouse ***************************************************************
	snapshot restore 2
	* Col 1
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA7.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg spouse propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg spouse propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 7
	ivreg spouse propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg spouse (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg spouse propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[7,1]=r(F)
	
	* Col 10
		use "../new/householdSizeMatching", clear
		drop if spouse == .
		set seed 1
	atts spouse propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 10 and 11
		use "../new/householdSizeMatching_altmatch", clear
		drop if spouse == .
		set seed 1
	atts spouse propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label	
	atts spouse propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts spouse propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA7.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts spouse propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts spouse propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts spouse propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts spouse propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts spouse propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
		
*** Table A.8: Number of offspring of the household head=14 years old ******************************
	snapshot restore 2
	* Col 1
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA8.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg numberChildrensMoreThan14 propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg numberChildrensMoreThan14 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 7
	ivreg numberChildrensMoreThan14 propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg numberChildrensMoreThan14 (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg numberChildrensMoreThan14 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[8,1]=r(F)
	
	* Col 10
		use "../new/householdSizeMatching", clear
		drop if numberChildrensMoreThan14 == .
		set seed 1
	atts numberChildrensMoreThan14 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 10 and 11
		use "../new/householdSizeMatching_altmatch", clear
		drop if numberChildrensMoreThan14 == .
		set seed 1
	atts numberChildrensMoreThan14 propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label	
	atts numberChildrensMoreThan14 propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrensMoreThan14 propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA8.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrensMoreThan14 propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrensMoreThan14 propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts numberChildrensMoreThan14 propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts numberChildrensMoreThan14 propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts numberChildrensMoreThan14 propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
			
*** Table A.9: Number of other relatives (no spouse or offspring of the household head) ************
	snapshot restore 2
	* Col 1
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA9.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg numberOtherRelatives propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg numberOtherRelatives propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 7
	ivreg numberOtherRelatives propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg numberOtherRelatives (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg numberOtherRelatives propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[9,1]=r(F)
		
	* Col 10
		use "../new/householdSizeMatching", clear
		drop if numberOtherRelatives == .
		set seed 1
	atts numberOtherRelatives propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 10 and 11
		use "../new/householdSizeMatching_altmatch", clear
		drop if numberOtherRelatives == .
		set seed 1
	atts numberOtherRelatives propertyRight, pscore(propscore_manual) blockid(matchingBlock_manual) boot reps(100)
		outreg2 using ../output/manualmatch.xls,append stats(coef tstat) bdec(3) tdec(3)  label	
	atts numberOtherRelatives propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberOtherRelatives propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA9.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberOtherRelatives propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberOtherRelatives propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts numberOtherRelatives propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts numberOtherRelatives propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts numberOtherRelatives propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
		
*** Table A.10: Number of offspring of the household head 5ñ13 years old ***************************
	snapshot restore 2
	* Col 1
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA10.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg numberChildrens5_13 propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg numberChildrens5_13 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 7
	ivreg numberChildrens5_13 propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 8
	ivreg numberChildrens5_13 (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg numberChildrens5_13 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[10,1]=r(F)
	
	* Col 10
		use "../new/householdSizeMatching", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 10 and 11
		use "../new/householdSizeMatching_altmatch", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts numberChildrens5_13 propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts numberChildrens5_13 propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts numberChildrens5_13 propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
		
	* Col 11
		use "../new/householdSizeMatchingEarly", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 12 and 13
		use "../new/householdSizeMatchingEarly_altmatch", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	
	* Col 12
		use "../new/householdSizeMatchingLate", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 14 and 15
		use "../new/householdSizeMatchingLate_altmatch", clear
		drop if numberChildrens5_13 == .
		set seed 1
	atts numberChildrens5_13 propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA10.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens5_13 propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

*** Table A.11: Number of offspring of the household head 0ñ4 years old ****************************
	snapshot restore 2
	* Col 1
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA11.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg numberChildrens0_4 propertyRight if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(blockId)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 6
	reg numberChildrens0_4 propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1, cluster(formerOwner)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 7
	ivreg numberChildrens0_4 propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 8
	ivreg numberChildrens0_4 (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg numberChildrens0_4 propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[11,1]=r(F)
		
	* Col 10
		use "../new/householdSizeMatching", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label
		
	* Col 10
		use "../new/householdSizeMatching_altmatch", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts numberChildrens0_4 propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts numberChildrens0_4 propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts numberChildrens0_4 propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
			
	* Col 11
		use "../new/householdSizeMatchingEarly", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 11
		use "../new/householdSizeMatchingEarly_altmatch", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* Col 12
		use "../new/householdSizeMatchingLate", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 12
		use "../new/householdSizeMatchingLate_altmatch", clear
		drop if numberChildrens0_4 == .
		set seed 1
	atts numberChildrens0_4 propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA11.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts numberChildrens0_4 propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

*** Table A.12: School achievement (offspring of the household head 6ñ20 years old) ****************
	snapshot restore 3
	keep if childAge>=6 & childAge<21
	* Col 1
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA12.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg schoolAchievement propertyRight male childAge
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg schoolAchievement propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 7
	reg schoolAchievement propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg schoolAchievement (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg schoolAchievement propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[12,1]=r(F)

		
	* Col 10 (All)
		use "../new/educationMatching.dta", replace
		keep if childAge>=6 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7507662
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest schoolAchievement, by(propertyRight) unequal 
		log on
		drop if schoolAchievement ==.
		sort personId
		set seed 1
	atts schoolAchievement propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 11 and 12
		use "../new/educationMatching_altmatch.dta", replace
		keep if childAge>=6 & childAge<21
		
		set seed 1
	atts schoolAchievement propertyRight, pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts schoolAchievement propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts schoolAchievement propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts schoolAchievement propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
			
	* Col 13 (early)
		use "../new/educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=6 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.6363688
		drop if propensityScore>0.7507662
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest schoolAchievement, by(propertyRight) unequal 
		log on
		drop if schoolAchievement ==.
		sort personId
		set seed 1
	atts schoolAchievement propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 14 and 15 (early)
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=6 & childAge<21
	
		set seed 1
	atts schoolAchievement propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* Col 16 (late)
		use "../new/educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=6 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7088112
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest schoolAchievement, by(propertyRight) unequal 
		log on
		drop if schoolAchievement ==.
		sort personId
		set seed 1
	atts schoolAchievement propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 17 and 18
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=6 & childAge<21
	
		set seed 1
	atts schoolAchievement propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA12.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts schoolAchievement propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

*** Table A.13: Primary school completion (offspring of the household head 13ñ20 years old) ********
	snapshot restore 3
	keep if childAge>=13 & childAge<21
	* Col 1
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA13.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg primarySchoolCompletion propertyRight male childAge
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 4
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg primarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 7
	reg primarySchoolCompletion propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg primarySchoolCompletion (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg primarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[13,1]=r(F)
			
	* Col 10 (all)
		use "../new/educationMatching.dta", replace
		keep if childAge>=13 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7503611
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label
			
	* Col 11 and 12
		use "../new/educationMatching_altmatch.dta", replace
		keep if childAge>=13 & childAge<21
	
		set seed 1
	atts primarySchoolCompletion propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts primarySchoolCompletion propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts primarySchoolCompletion propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
		
	* Col 11 (version in published paper) (now column 13)
		use "../new/educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=12 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7503611
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 14 and 15 (early)
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=12 & childAge<21

		set seed 1
	atts primarySchoolCompletion propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* Col 11 (version with corrected age interval) (now columns 16) (early)
		use "../new/educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=13 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7503611
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)	
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 11 (version with corrected age interval) (now columns 17 and 18) (early)
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=13 & childAge<21

		set seed 1
	atts primarySchoolCompletion propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* Col 19 (late)
		use "../new/educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=13 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7088112
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest primarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if primarySchoolCompletion ==.
		sort personId
		set seed 1
	atts primarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3) label
	
	* Col 20 and 21 (late)
		use "../new/educationMatching_altmatch.dta", replace
		keep if childAge>=13 & childAge<21
		drop if propertyRightEarly == 1

		set seed 1
	atts primarySchoolCompletion propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA13.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts primarySchoolCompletion propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

*** Table A.14: Secondary school completion (offspring of the household head 18ñ20 years old) ******
	snapshot restore 3
	keep if childAge>=18 & childAge<21
	* Col 1
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA14.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg secondarySchoolCompletion propertyRight male childAge
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg secondarySchoolCompletion propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 7
	reg secondarySchoolCompletion propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg secondarySchoolCompletion (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg secondarySchoolCompletion propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[14,1]=r(F)
		
	* Col 10 (all)
		use "../new/educationMatching.dta", replace
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5381833
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest secondarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if secondarySchoolCompletion ==.
		sort personId
		set seed 1
	atts secondarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label
		
	* Col 11 and 12 (all)
		use "../new/educationMatching_altmatch.dta", replace
		keep if childAge>=18 & childAge<21

		set seed 1
	atts secondarySchoolCompletion propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts secondarySchoolCompletion propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts secondarySchoolCompletion propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts secondarySchoolCompletion propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
		
	* Col 11
		use "../new/educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest secondarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if secondarySchoolCompletion ==.
		sort personId
		set seed 1
	atts secondarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 11
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=18 & childAge<21

		set seed 1
	atts secondarySchoolCompletion propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* Col 12
		use "../new/educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5519478
		drop if propensityScore>0.7014628
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest secondarySchoolCompletion, by(propertyRight) unequal 
		log on
		drop if secondarySchoolCompletion ==.
		sort personId
		set seed 1
	atts secondarySchoolCompletion propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 12
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=18 & childAge<21

		set seed 1
	atts secondarySchoolCompletion propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA14.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts secondarySchoolCompletion propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

*** Table A.15: Post-secondary education (offspring of the household head 18ñ20 years old) *********
	snapshot restore 3
	keep if childAge>=18 & childAge<21
	* Col 1
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA15.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* Col 2
	reg postSecondaryEducation propertyRight male childAge
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 3
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 4
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(householdId)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 5
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(blockId)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 6
	reg postSecondaryEducation propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss, cluster(formerOwner)	
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 7
	reg postSecondaryEducation propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 8
	ivreg postSecondaryEducation (propertyRight = propertyOffer) parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 9
	reg postSecondaryEducation propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted male childAge ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[15,1]=r(F)
	
	* Col 10
		use "../new/educationMatching.dta", replace
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5519478
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest postSecondaryEducation, by(propertyRight) unequal 
		log on
		drop if postSecondaryEducation ==.
		sort personId
		set seed 1
	atts postSecondaryEducation propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 10
		use "../new/educationMatching_altmatch.dta", replace
		keep if childAge>=18 & childAge<21

		set seed 1
	atts postSecondaryEducation propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	local b=`b'+1
	atts postSecondaryEducation propertyRight,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
		mat n[1,1]=r(ncs)+r(nts)
		outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
		putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify

	foreach x of varlist genderOrigSquatter educOSprimary	{
			local b=`b'+1
			atts postSecondaryEducation propertyRight if `x'==0,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
			local b=`b'+1
			atts postSecondaryEducation propertyRight if `x'==1,  pscore( ps_title_all ) blockid( block_title_all ) boot reps(100)
				mat n[1,1]=r(ncs)+r(nts)
				outreg2 using ../output/HoI_all.xls,append stats(coef tstat) bdec(3) tdec(3)  label
				putexcel B`b'=matrix(n) using ../output/HoI_allN.xlsx,modify
	}
	
	* Col 11
		use "../new/educationMatching.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.653023
		drop if propensityScore>0.7366924
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest postSecondaryEducation, by(propertyRight) unequal 
		log on
		drop if postSecondaryEducation ==.
		sort personId
		set seed 1
	atts postSecondaryEducation propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 11
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightLate == 1
		keep if childAge>=18 & childAge<21
	
		set seed 1
	atts postSecondaryEducation propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tablea15.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

	* Col 12
		use "../new/educationMatching.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=18 & childAge<21
		bysort propertyRight: su propensityScore, detail
		drop if propensityScore<0.5519478
		drop if propensityScore>0.7014628
		egen a1 = pctile(propensityScore) if propertyRight == 1, p(20)
		egen a2 = pctile(propensityScore) if propertyRight == 1, p(40)
		egen a3 = pctile(propensityScore) if propertyRight == 1, p(60)
		egen a4 = pctile(propensityScore) if propertyRight == 1, p(80)
		egen b1 = mean(a1)
		egen b2 = mean(a2)
		egen b3 = mean(a3)
		egen b4 = mean(a4)
		gen matchingBlock     = 1 if propensityScore <b1
		replace matchingBlock = 2 if propensityScore >=b1 & propensityScore<b2 
		replace matchingBlock = 3 if propensityScore >=b2 & propensityScore<b3 
		replace matchingBlock = 4 if propensityScore >=b3 & propensityScore<b4 
		replace matchingBlock = 5 if propensityScore >=b4
		log off
			sort matchingBlock propertyRight
			by matchingBlock: ttest propensityScore, by(propertyRight) unequal
			sort matchingBlock propertyRight
			by matchingBlock: ttest postSecondaryEducation, by(propertyRight) unequal 
		log on
		drop if postSecondaryEducation ==.
		sort personId
		set seed 1
	atts postSecondaryEducation propertyRight, pscore(propensityScore) blockid(matchingBlock) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* Col 12
		use "../new/educationMatching_altmatch.dta", replace
		drop if propertyRightEarly == 1
		keep if childAge>=18 & childAge<21

		set seed 1
	atts postSecondaryEducation propertyRight , pscore( ps_offer ) blockid( block_offer ) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight , pscore( ps_title ) blockid( block_title ) boot reps(100)
		outreg2 using ../output/tableA15.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight,  pscore( ps_title_gender ) blockid( block_title_gender ) boot reps(100)
		outreg2 using ../output/HoI_gender.xls,append stats(coef tstat) bdec(3) tdec(3)  label
	atts postSecondaryEducation propertyRight,  pscore( ps_title_educOSprimary ) blockid( block_title_educOSprimary ) boot reps(100)
		outreg2 using ../output/HoI_educOS.xls,append stats(coef tstat) bdec(3) tdec(3)  label

*** Table A.16: Access to credit *******************************************************************
	snapshot restore 2
	* col 1
	reg creditCardBankAccount propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* col 2
	reg creditCardBankAccount propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[16,2]=r(F)
		
	* col 3
	reg nonMortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 4
	reg nonMortgageLoan propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[16,4]=r(F)
		
	* col 5
	reg informalCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 6
	reg informalCredit propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[16,6]=r(F)
		
	* col 7
	reg groceryStoreCredit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 8
	reg groceryStoreCredit propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[16,8]=r(F)
		
	* col 9
	reg mortgageLoan propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 10
	reg mortgageLoan propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA16.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[16,10]=r(F)
		
*** Table A.17: Labor market ***********************************************************************
	* col 1
	reg householdHeadIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* col 2
	reg householdHeadIncome propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[17,2]=r(F)
		
	* col 3
	reg totalHouseholdIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 4
	reg totalHouseholdIncome propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[17,4]=r(F)
		
	* col 5
	reg totalHouseholdIncomePerCapita propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 6
	reg totalHouseholdIncomePerCapita propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[17,6]=r(F)
		
	* col 7
	reg totalHouseholdIncomePerAdult propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 8
	reg totalHouseholdIncomePerAdult propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[17,8]=r(F)
		
	* col 9
	reg employedHouseholdHead propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 10
	reg employedHouseholdHead propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[17,10]=r(F)

	putexcel C7=mat(append) using ../output/replicated_tables,modify sheet("tempappend") 


*** Table A.17_logged: Labor market ***********************************************************************
	* col 1
	reg lnhouseholdHeadIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,replace stats(coef tstat) bdec(3) tdec(3) label

	* col 2
	reg lnhouseholdHeadIncome propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[18,2]=r(F)
		
	* col 3
	reg lntotalHouseholdIncome propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 4
	reg lntotalHouseholdIncome propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[18,4]=r(F)
		
	* col 5
	reg lntotalHouseholdIncomePerCapita propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 6
	reg lntotalHouseholdIncomePerCapita propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[18,6]=r(F)
		
	* col 7
	reg lntotalHouseholdIncomePerAdult propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 8
	reg lntotalHouseholdIncomePerAdult propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[18,8]=r(F)
		
	* col 9
	reg employedHouseholdHead propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	* col 10
	reg employedHouseholdHead propertyRightEarly propertyRightLate parcelSurface distanceToCreek blockCorner distToNonSquatted ageOfOrigSquatterDummy ageOsMiss genderOrigSquatter argentineOrigSquatter educationYearsOrigSquatter argentineOrigSquatterFather argentinaFatherOsMiss educYearsOrigSquatterFather educationOfTheFatherMiss argentineOrigSquatterMother educYearsOrigSquatterMother educationOfTheMotherMiss if neighborhood<5 &  inBothDatasets==3 & nonSurveyed==. & householdArrivedBefore1986==1
		outreg2 using ../output/tableA17_logged.xls,append stats(coef tstat) bdec(3) tdec(3) label

	test propertyRightEarly=propertyRightLate
		mat append[18,10]=r(F)

	putexcel C7=mat(append) using ../output/replicated_tables,modify sheet("tempappend") 

****************************************************************************************************
log close

di `b'
