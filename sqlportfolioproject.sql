--Creating the Table and importing the CSV File

CREATE TABLE Public."covid_deaths"(iso_code varchar(15), continent varchar(100), location varchar(100), 
date date, population int8, total_cases int, new_cases int, new_cases_smoothed float, total_deaths int, new_deaths int, 
new_deaths_smoothed float, total_cases_per_million float, new_cases_per_million float,
new_cases_smoothed_per_million float, total_deaths_per_million float, new_deaths_per_million float,
new_deaths_smoothed_per_million float, reproduction_rate float, icu_patients int, 
icu_patients_per_million float, hosp_patients int, hosp_patients_per_million float,
weekly_icu_admissions int, weekly_icu_admissions_per_million float, weekly_hosp_admissions int,
weekly_hosp_admissions_per_million float);

SELECT * FROM Public."covid_deaths" LIMIT 10;

SELECT location, new_cases, total_cases, total_deaths, population
FROM Public."covid_deaths";

/* Total deaths VS Total cases */
SELECT location, date, total_cases, total_deaths, population, (cast(total_deaths as decimal)/total_cases)*100 as percentage_death
FROM Public."covid_deaths"
WHERE location LIKE 'Nigeria'
ORDER BY 1,2;

/* Total cases VS Population */ 
SELECT location, date, total_cases, total_deaths, population, (cast(total_cases as decimal)/population)*100 as percentage_infected
FROM Public."covid_deaths"
WHERE location LIKE 'Nigeria'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as decimal)/population)*100) as percentage_infected
FROM Public."covid_deaths"
--WHERE location LIKE 'Nigeria'
GROUP BY location, population
ORDER BY percentage_infected DESC;

-- Showing the countries with highest death count per population
SELECT location, MAX(total_deaths) as HighestDeathCount
FROM Public."covid_deaths"
--WHERE location LIKE 'Nigeria'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Showing the continents with highest death count per population
SELECT continent, MAX(total_deaths) as HighestDeathCount
FROM Public."covid_deaths"
--WHERE location LIKE 'Nigeria'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

SELECT location, MAX(total_deaths) as HighestDeathCount
FROM Public."covid_deaths"
--WHERE location LIKE 'Nigeria'
WHERE continent is NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(cast(new_deaths as decimal))/SUM(new_cases)*100 as percentage_death
FROM Public."covid_deaths"
--WHERE location LIKE 'Nigeria'
WHERE continent is NOT null
GROUP BY DATE
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(cast(new_deaths as decimal))/SUM(new_cases)*100 as percentage_death
FROM Public."covid_deaths"
--WHERE location LIKE 'Nigeria'
WHERE continent is NOT null
--GROUP BY DATE
ORDER BY 1,2;


CREATE TABLE Public."covid_vacinations"(iso_code varchar(15), continent varchar(100), location varchar(100), 
date date, new_tests int, total_tests_per_thousand float, new_tests_per_thousand float, new_tests_smoothed float,
new_tests_smoothed_per_thousand float, positive_rate float, tests_per_case float, tests_units varchar(100),
total_vaccinations int8, people_vaccinated int8, people_fully_vaccinated int8, total_boosters int,
new_vaccinations int, new_vaccinations_smoothed int, total_vaccinations_per_hundred float,
people_vaccinated_per_hundred float, people_fully_vaccinated_per_hundred float, 
total_boosters_per_hundred float, new_vaccinations_smoothed_per_million float,
new_people_vaccinated_smoothed float, new_people_vaccinated_smoothed_per_hundred float,
stringency_index float, population int8, population_density float, median_age float, aged_65_older float,
aged_70_older float, gdp_per_capita float, extreme_poverty float, cardiovasc_death_rate float, 
diabetes_prevalence float, female_smokers float, male_smokers float, handwashing_facilities float,
hospital_beds_per_thousand float, life_expectancy float, human_development_index float,
excess_mortality_cumulative_absolute float, excess_mortality_cumulative float, excess_mortality float,
excess_mortality_cumulative_per_million float)



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
AS 	CummulativePeopleVaccinated
FROM Public."covid_deaths" dea
JOIN Public."covid_vacinations" vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--USING CTE 
With PopvsVac(continent, location, date, population, new_vaccinations, cummulativepeoplevaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
AS 	CummulativePeopleVaccinated
FROM Public."covid_deaths" dea
JOIN Public."covid_vacinations" vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (cast(CummulativePeopleVaccinated as decimal)/population)*100 CumPerPeopleVaccinated
FROM PopvsVac;

--USING TEMP TABLE
SELECT
continent,
location,
date,
population,
new_vaccinations,
cummulativepeoplevaccinated
INTO TABLE PercentPopulationVaccinated
FROM(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
AS CummulativePeopleVaccinated
FROM Public."covid_deaths" dea
JOIN Public."covid_vacinations" vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3
) AS SUB

SELECT *, (cast(CummulativePeopleVaccinated as decimal)/population)*100 CumPerPeopleVaccinated
FROM PercentPopulationVaccinated; 
 

CREATE VIEW PercentPopulationVaccinatedView AS SELECT * FROM PercentPopulationVaccinated;


