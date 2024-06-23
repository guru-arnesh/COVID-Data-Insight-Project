--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, population
FROM [Portfolio Project]..covid_deaths
ORDER BY 1,2

--Looking at Death Rate location wise

SELECT location, date, total_cases, total_deaths, 
CAST(ROUND((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100, 2) AS VARCHAR) + '%' as Death_Percentage
FROM [Portfolio Project]..covid_deaths
WHERE location = 'India'
ORDER BY 1,2

--Looking Total Cases vs Population
--Shows what percentage of population got infected by COVID 

SELECT location, total_cases, population,
CAST(ROUND((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100, 2) AS VARCHAR) + '%' as Percentage_Infected
FROM [Portfolio Project]..covid_deaths
WHERE location = 'China'
ORDER BY 1,2

--Looking at countries having highest Infection Rate comapred to Population

SELECT location,population, MAX(total_cases) AS Highest_Infection_Count,
MAX(CAST(ROUND((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100, 2) AS VARCHAR) + '%') as Percentage_Population_Infected
FROM [Portfolio Project]..covid_deaths
--WHERE location = 'India'
GROUP BY location, population
ORDER BY Percentage_Population_Infected desc

--Looking for Countries with the highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) as Total_Death_Count
FROM [Portfolio Project]..covid_deaths
--WHERE location = 'China'
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count desc

--Breaking it down by Continent

SELECT continent, MAX(CAST(total_deaths AS int)) as Total_Death_Count
FROM [Portfolio Project]..covid_deaths
--WHERE location = 'China'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc

--Looking at GLOBAL numbers

SELECT date,
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    CAST(ROUND(SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100, 2) as varchar) + '%' AS DeathPercentage
FROM [Portfolio Project]..covid_deaths
WHERE continent IS NOT NULL 
GROUP BY date
order by 1,2

--Looking at Total Population vs Vaccinations
--Looking at Total vaccination loacation wise (use of WINDOWS FUNCTION)

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as Cumulative_vaccinations
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Looking at Total Population vs Vaccinations(Using CTE)

WITH PopvsVac
AS 
(
SELECT 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS Cumulative_vaccinations
FROM 
[Portfolio Project]..covid_deaths dea
JOIN 
[Portfolio Project]..covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE 
dea.continent IS NOT NULL
)
SELECT *, round(((Cumulative_vaccinations/population)*100),1) as Percentage_vaccinated
FROM PopvsVac
ORDER BY location, date;


--Creating VIEW for Data Visualisation

CREATE VIEW vaccination_Percentage as
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as Cumulative_vaccinations
FROM [Portfolio Project]..covid_deaths dea
JOIN [Portfolio Project]..covid_vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM vaccination_Percentage