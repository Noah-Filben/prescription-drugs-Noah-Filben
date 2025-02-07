--	Q1a
SELECT 
prescriber.npi AS npi,
SUM(prescription.total_claim_count) AS claim_count
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi
ORDER BY claim_count DESC;

--Q1b
SELECT 
prescriber.nppes_provider_first_name AS first_name, 
prescriber.nppes_provider_last_org_name AS last_name, 
prescriber.specialty_description AS specialty,
SUM(prescription.total_claim_count) AS claims
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
GROUP BY first_name, last_name, specialty, prescriber.npi
ORDER BY claims DESC;

--Q2a
SELECT 
prescriber.specialty_description AS specialty, 
SUM(prescription.total_claim_count) AS claims
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
GROUP BY specialty
ORDER BY claims DESC;

--Q2b
SELECT 
prescriber.specialty_description AS specialty,
SUM(prescription.total_claim_count) AS claims
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY specialty
ORDER BY claims desc;

--Q2c CHALLENGE QUESTION
SELECT specialty_description, COUNT(total_claim_count) AS claims
FROM prescriber
FULL JOIN prescription
	USING (npi)
GROUP BY specialty_description
ORDER BY claims;

--Q3a
SELECT drug.generic_name AS drug, MAX(prescription.total_drug_cost) AS cost
FROM drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
GROUP BY drug
ORDER BY cost DESC;

--Q3b
SELECT 
generic_name AS drug, 
ROUND(MAX(total_drug_cost) / (total_day_supply),2) AS cost_per_day
FROM prescription
INNER JOIN drug
USING (drug_name)
	GROUP BY drug, total_day_supply
	ORDER BY cost_per_day DESC
LIMIT 1;

--Q4a
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

--Q4b
SELECT 
SUM(prescription.total_drug_cost::money) AS cost,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
GROUP BY drug.opioid_drug_flag, drug.antibiotic_drug_flag
ORDER BY cost DESC;

--Q5a
SELECT COUNT(DISTINCT cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

--Q5b
SELECT cbsa, cbsaname, SUM(population) AS total_population
FROM population
	INNER JOIN cbsa
	ON population.fipscounty = cbsa.fipscounty
GROUP BY cbsa, cbsaname
ORDER BY sum(population) DESC;

--Q5c
SELECT cbsa, county, population
FROM cbsa
	FULL JOIN fips_county
	ON cbsa.fipscounty = fips_county.fipscounty
	INNER JOIN population
	ON fips_county.fipscounty = population.fipscounty
WHERE cbsa IS NULL
ORDER BY population DESC;

--Q6a
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--Q6b
SELECT drug.drug_name, total_claim_count,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'YES' ELSE 'NO' END AS is_opioid
FROM prescription
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
WHERE total_claim_count >= 3000 
ORDER BY total_claim_count DESC; 

--Q6c
SELECT 
nppes_provider_first_name AS first_name,
nppes_provider_last_org_name AS last_name,
total_claim_count AS claims,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'YES' ELSE 'NO' END AS is_opioid
FROM prescriber
	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
WHERE total_claim_count >= 3000
GROUP BY first_name, last_name, opioid_drug_flag, claims
ORDER BY is_opioid desc;

--Q7
SELECT prescriber.npi, drug.drug_name
FROM prescriber
CROSS JOIN drug
	WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';

--Q7b&c
WITH npi_drug_combo AS (
	SELECT prescriber.npi AS npi, drug.drug_name AS drug_name
	FROM prescriber
	CROSS JOIN drug
		WHERE specialty_description = 'Pain Management'
		AND nppes_provider_city = 'NASHVILLE'
		AND opioid_drug_flag = 'Y'
)
SELECT npi_drug_combo.npi,
npi_drug_combo.drug_name, 
COALESCE(SUM(prescription.total_claim_count),0) AS total_claim_count
FROM npi_drug_combo
LEFT JOIN prescription
	ON prescription.npi = npi_drug_combo.npi
	AND prescription.drug_name = npi_drug_combo.drug_name
GROUP BY npi_drug_combo.npi, npi_drug_combo.drug_name
ORDER BY total_claim_count DESC;









