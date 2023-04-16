USE PortfolioProject

SELECT *
FROM dbo.CovidDeaths
ORDER BY 3,4

-- SELECT *
--FROM dbo.CovidVaccination
--ORDER BY 3,4

-- Select the data that we are going to be using

SELECT Location,date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Looking at total cases vs total deaths
-- shows liklihood of dying if you contract covid in your country

SELECT Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2


SELECT Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- looking at the total cases vs population
--shows what percentage of population got covid
SELECT Location,date,total_cases, population, (total_cases/population)*100 AS PecerntPopulationinfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%mbab%'
ORDER BY 1,2
-----------------------------------------------------------------------------------------------------------------------------------------------------------

--looking at countries with highest infection rate compared to population
SELECT Location,MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS Percentpopulationinfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%mbab%'
GROUP BY location, population
ORDER BY Percentpopulationinfected DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------


-- showing countries with highest deaths count per population
SELECT Location, MAX(Total_deaths) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%mbab%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY TotaldeathCount DESC;
----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Listing all countries where Continebt is not blank
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- lets break things by continent
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%mbab%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount DESC

--This is a partial SQL statement that retrieves the name of the continent with the highest total death count, based on a table with columns for continent and total deaths.
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

-- This is a partial SQL statement that retrieves the location with the highest total death count for countries where the continent is not specified, based on a table with columns for location, total deaths, and continent.
SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%mbab%'
WHERE continent is NULL
GROUP BY location
ORDER BY TotaldeathCount DESC
-----------------------------------------------------------------------------------------------------------------------------------------------------


-- showing the continent with highest death count
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%mbab%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount DESC
-------------------------------------------------------------------------------------------------------------------------------------------------------

--Global Numbers 
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%mbab%'
WHERE continent IS NOT NULL
Group By date
ORDER BY 1,2
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- looking at total population vs Vaccinations
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations, SUM(CAST(CovidVaccination.new_vaccinations AS INT)) OVER (Partition BY CovidDeaths.Location ORDER BY CovidDeaths.location)
FROM PortfolioProject..CovidDeaths
JOIN PortfolioProject..CovidVaccination
	ON CovidDeaths.location = CovidVaccination.location
	AND CovidDeaths.date = CovidVaccination.date
WHERE CovidDeaths.continent IS NOT NULL
ORDER BY 2,3
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use CTE

WITH VaccinationData AS (
	SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations,
	SUM(CAST(CovidVaccination.new_vaccinations AS INT)) OVER (Partition BY CovidDeaths.Location ORDER BY CovidDeaths.location) AS CumulativeVaccinations
	FROM PortfolioProject..CovidDeaths
	JOIN PortfolioProject..CovidVaccination
		ON CovidDeaths.location = CovidVaccination.location
		AND CovidDeaths.date = CovidVaccination.date
	WHERE CovidDeaths.continent IS NOT NULL
)
SELECT *
FROM VaccinationData
ORDER BY location, date;


--Analyzing the rate of vaccination
WITH VaccinationData AS (
	SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccination.new_vaccinations,
	SUM(CAST(CovidVaccination.new_vaccinations AS INT)) OVER (Partition BY CovidDeaths.Location ORDER BY CovidDeaths.location, CovidDeaths.date) AS CumulativeVaccinations
	FROM PortfolioProject..CovidDeaths
	JOIN PortfolioProject..CovidVaccination
		ON CovidDeaths.location = CovidVaccination.location
		AND CovidDeaths.date = CovidVaccination.date
	WHERE CovidDeaths.continent IS NOT NULL
)
SELECT *,
	(CumulativeVaccinations - LAG(CumulativeVaccinations, 1, 0) OVER (PARTITION BY location ORDER BY date)) / DATEDIFF(day, LAG(date, 1, 0) OVER (PARTITION BY location ORDER BY date), date) AS DailyVaccinationRate
FROM VaccinationData
ORDER BY location, date;





