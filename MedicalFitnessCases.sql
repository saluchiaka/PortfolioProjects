

-- Create Database and import tables using the import wizard

CREATE DATABASE MedicalFitnessCases

SELECT * 
FROM Cases

-- Replace all null values with 0 to signify Under Review in the Decision Class.

SELECT * 
FROM Cases
WHERE DECISION_CD IS NULL

SELECT DRIVER, CASE_SEQ_NO, CASE_OPENED_DT, CASE_CD, ORIGIN_CD, ISNULL(DECISION_CD, 0) DECISION_CD
FROM Cases

--Create MedicalFitnessCases table using Joins

SELECT cs.DRIVER, cs.CASE_SEQ_NO, cs.CASE_OPENED_DT, cs.CASE_CD, cs.ORIGIN_CD, ISNULL(cs.DECISION_CD, 0) DECISION_CD, ISNULL(dc.DECISION_DSC, 'UNDER REVIEW') DECISION_DSC, co.ORIGIN_DSC, ct.CASE_DSC
INTO MedicalFitnessCases
FROM Cases cs
LEFT JOIN decision_classes dc ON cs.DECISION_CD = dc.DECISION_CD
JOIN case_origins co ON cs.ORIGIN_CD = co.ORIGIN_CD
JOIN case_types ct ON cs.CASE_CD = ct.CASE_CD

SELECT * 
FROM MedicalFitnessCases

-- Export data as CSV file and import into Power BI for further analysis

/*
Of the cases where the Case Origin was a Physician, how many reached a decision with:
a. one of the decision types beginning with “FIT” and does not include “FITNESS
UNDETERMINED”
*/

SELECT ORIGIN_DSC, DECISION_DSC
FROM MedicalFitnessCases
WHERE ORIGIN_DSC = 'PHYSICIAN' AND DECISION_DSC LIKE 'FIT%' AND DECISION_DSC <> 'FITNESS UNDETERMINED'

SELECT COUNT (DECISION_DSC)
FROM MedicalFitnessCases
WHERE ORIGIN_DSC = 'PHYSICIAN' AND DECISION_DSC LIKE 'FIT%' AND DECISION_DSC <> 'FITNESS UNDETERMINED'

-- 2,939

/*
one of the decision types beginning with “UNFIT”
*/
SELECT ORIGIN_DSC, DECISION_DSC
FROM MedicalFitnessCases
WHERE ORIGIN_DSC = 'PHYSICIAN' AND DECISION_DSC LIKE 'UNFIT%' 

SELECT COUNT (DECISION_DSC)
FROM MedicalFitnessCases
WHERE ORIGIN_DSC = 'PHYSICIAN' AND DECISION_DSC LIKE 'UNFIT%' 

-- 4,515

/*
2. Instead of completing a medical fitness case, a driver may decide to stop driving and hand in their
driver’s licence, identified in the data with a Decision Class description of “Voluntary Surrender – All
Privileges”. Of cases with this decision type, how many originated from:
a. Police
b. Physician
*/

SELECT ORIGIN_DSC, DECISION_DSC
FROM MedicalFitnessCases
WHERE DECISION_DSC = 'VOLUNTARY SURRENDER - ALL PRIVILEGES'

SELECT COUNT(DECISION_DSC)
FROM MedicalFitnessCases
WHERE DECISION_DSC = 'VOLUNTARY SURRENDER - ALL PRIVILEGES' AND ORIGIN_DSC = 'POLICE'

-- 124

SELECT COUNT(DECISION_DSC)
FROM MedicalFitnessCases
WHERE DECISION_DSC = 'VOLUNTARY SURRENDER - ALL PRIVILEGES' AND ORIGIN_DSC = 'PHYSICIAN'

-- 403


/*
Violation tickets with a “contravention_num” beginning with “EA” are electronic tickets. Create a
visual which shows the proportion and counts of electronic violation tickets to paper tickets issued
each month. Briefly summarize your findings.
*/

SELECT * 
FROM ViolationTickets

SELECT *
FROM ViolationTickets
WHERE contravention_num LIKE 'EA%'

SELECT COUNT(DL_NUMBER)
FROM ViolationTickets
WHERE contravention_num LIKE 'EA%'

-- 206,429

SELECT *
FROM ViolationTickets
WHERE contravention_num <> 'EA%'

SELECT COUNT(DL_NUMBER)
FROM ViolationTickets
WHERE contravention_num <> 'EA%'

-- 465,182