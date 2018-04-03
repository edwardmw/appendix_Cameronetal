

************************************************************************************************************************************************
********************************************** Creates matching dataset for investment *********************************************************
************************************************************************************************************************************************

cd "/Users/JOR/Dropbox/Replication/data/new_jun13/do"

use "../data/investment", clear
keep if neighborhood <5 
keep if inBothDatasets ==3 
keep if nonSurveyed  ==.

***Original analysis excluded repeated parcels from predicting propensity score and from atts. Will drop before running pscore.

keep if householdArrivedBefore1986 == 1 
keep if repeatedParcel==0

merge 1:1 parcelId householdId using ../data/householdSize
keep if _m==3
drop _m

***first create pscore manually so we can compare for one outcome and discuss any differences
logit propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted
predict propscore_manual
label variable propscore_manual "Propensity score (using rights) calculated manually as done in original analysis"

**** Drop observations outside of common support *****
bys propertyRight: su propscore_manual, detail
gen comsup_manual=1
replace comsup_manual=0 if propscore_manual < r(min)
replace comsup_manual=0 if propscore_manual > r(max)


su propscore_manual if propertyRight == 1&comsup_manual==1, detail
gen b1 = r(p10)
gen b2 = r(p25)
gen b3 = r(p50)
gen b4 = r(p75)
gen b5 = r(p90)

su b1-b5

gen matchingBlock_manual = 1 if propscore_manual<b1&comsup_manual==1
replace matchingBlock_manual = 2 if propscore_manual >=b1 & propscore_manual<b2 &comsup_manual==1
replace matchingBlock_manual = 3 if propscore_manual >=b2 & propscore_manual<b3 &comsup_manual==1
replace matchingBlock_manual = 4 if propscore_manual >=b3 & propscore_manual<b4 &comsup_manual==1
replace matchingBlock_manual = 5 if propscore_manual >=b4 & propscore_manual<b5&comsup_manual==1
replace matchingBlock_manual = 6 if propscore_manual >=b5&comsup_manual==1

preserve
keep if comsup_manual==1
sort matchingBlock_manual propertyRight
by matchingBlock_manual: ttest propscore_manual, by(propertyRight) unequal

sort matchingBlock_manual propertyRight
by matchingBlock_manual: ttest parcelSurface, by(propertyRight) unequal  
by matchingBlock_manual: ttest distanceToCreek, by(propertyRight) unequal 
by matchingBlock_manual: ttest blockCorner, by(propertyRight) unequal 
by matchingBlock_manual: ttest distToNonSquatted, by(propertyRight) unequal 
restore
label variable matchingBlock_manual "Block identifier of the estimated propensity score (manual)"



***NOW use pscore command for analysis
pscore propertyOffer parcelSurface distanceToCreek blockCorner distToNonSquatted,pscore(ps_offer) numblo(3) blockid(block_offer) comsup
ren comsup comsup_offer
pscore propertyRight parcelSurface distanceToCreek blockCorner distToNonSquatted,pscore(ps_title) numblo(3) blockid(block_title) comsup
ren comsup support_title

*****Heterogeneity of Impact tests
*gender (1=female)
pscore propertyRight genderOrigSquatter parcelSurface distanceToCreek blockCorner distToNonSquatted,pscore(ps_title_gender) numblo(3) blockid(block_title_gender) comsup
ren comsup support_gender
*education level of head (levelEducationOfHH is range 1-6, will define dummy as having completed primary or not; 1=yes -->63%, 2=no)
gen educOSprimary=levelEducationOfOriginalSquatter>1&levelEducationOfOriginalSquatter!=.
replace educOSprimary=. if levelEducationOfOriginalSquatter==.
pscore propertyRight educOSprimary parcelSurface distanceToCreek blockCorner distToNonSquatted,pscore(ps_title_educOSprimary) numblo(3) blockid(block_title_educOSprimary) comsup
ren comsup support_educ

*all three
/*
RUN PSCORE FOR ALL THREE
THEN RUN ATTS TWICE FOR EACH HET VARIABLE; ONCE FOR 0, ONCE FOR 1
REPORT IN TABLE WITH COLUMNS FOR HET VARIABLES (6 TOTAL) AND ROWS FOR OUTCOMES
*/

pscore propertyRight genderOrigSquatter educOSprimary parcelSurface distanceToCreek blockCorner distToNonSquatted,pscore(ps_title_all) numblo(3) blockid(block_title_all) comsup
ren comsup support_all

*Store HoI vars in a separate file
preserve 
keep parcelId householdId genderOrigSquatter educOSprimary
save ../new/HoIvars,replace
restore

* Stores pscores in a temporal dataset 
preserve
sort parcelId
tempfile propensityScore
save `propensityScore'
restore

* Preserves current state of the dataset for future use in household size matching dataset
preserve
sort householdId
*keep parcelId householdId propertyRight concreteSidewalk constructedSurface overallHousingAppearance goodWalls goodRoof ps_* block_*
save "../new/investmentMatching_altmatch.dta", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for education **********************************************************
************************************************************************************************************************************************

use "../data/education", clear

* merges prop score results
merge m:1 parcelId using `propensityScore'
keep if _m==3
drop _m

*bring in HoI vars
merge m:1 parcelId using ../new/HoIvars
keep if _merge == 3
drop _m

*keep schoolAchievement primarySchoolCompletion secondarySchoolCompletion postSecondaryEducation childAge propertyRightEarly propertyRightLate ///
*parcelId householdId personId propertyRight ps_* block_* 
save "../new/educationMatching_altmatch.dta", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for household size *****************************************************
************************************************************************************************************************************************

use "../data/householdSize", clear

* Stores households with data in a temporal dataset
sort householdId
keep if householdId != .
tempfile hhSizeNoMissings
save `hhSizeNoMissings'

* Restores the previously preserved dataset in line 71
restore

* preserve for early and late matching datasets
preserve
* Adds household size data to current to dataset
sort householdId
merge householdId using `hhSizeNoMissings'
keep if _merge == 3
drop _m

*bring in HoI variables created above
merge 1:1 householdId using ../new/HoIvars
drop _m

*keep  parcelId householdId householdSize propertyRight ps_* block_*  numberChildrens5_13 numberChildrens0_4 spouse numberOtherRelatives numberChildrensMoreThan14
save "../new/householdSizeMatching_altmatch.dta", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for household size early ***********************************************
************************************************************************************************************************************************

restore
preserve

* Keep Early and Control
drop if propertyRightLate == 1

*bring in HoI variables created above
merge 1:1 householdId using ../new/HoIvars
keep if _m==3
drop _m

* Adds household size data to current to dataset
sort householdId
merge householdId using `hhSizeNoMissings'
keep if _merge == 3
drop _m
*keep parcelId householdId propertyRight ps_* block_*  numberChildrens5_13 numberChildrens0_4
save "../new/householdSizeMatchingEarly_altmatch", replace

************************************************************************************************************************************************
********************************************** Creates matching dataset for household size late ************************************************
************************************************************************************************************************************************

restore

* Keep Late and Control
drop if propertyRightEarly == 1

*bring in HoI variables created above
merge 1:1 householdId using ../new/HoIvars
keep if _m==3
drop _m

* Adds household size data to current to dataset
sort householdId
merge householdId using `hhSizeNoMissings'
keep if _merge == 3
drop _m
*keep parcelId householdId propertyRight ps_* block_* numberChildrens5_13 numberChildrens0_4
save "../new/householdSizeMatchingLate_altmatch", replace
