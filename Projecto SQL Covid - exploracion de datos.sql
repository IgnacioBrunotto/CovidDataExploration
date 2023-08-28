select *
from ProjectCovid..CovidDeaths$
Where continent is not null
order by 3,4

--select *
--from ProjectCovid..CovidVaccinations$
--order by 3,4

--Informacion que realmente usaremos

Select location, date, total_cases, new_cases, total_deaths, population
from ProjectCovid..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
--Muestra la probabilidad de supervivencia al estar infectado en determinado momento.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as 'Deaths percentage'
from ProjectCovid..CovidDeaths$
Where location like '%argentina%'
order by 1,2

--Looking at total cases vs population
--Muestra el porcentage de la poblacion infectada en determinado momento.
	
Select location, date, total_cases, population, (total_cases/population) *100 as 'Infected percentage of the population'
from ProjectCovid..CovidDeaths$
where location like '%argentina%'
order by 1,2

--Looking for countries with highest infection rate compared with population
	
Select location,  population ,MAX(total_cases) AS highest_infection_count , MAX((total_cases/population)) *100 as PercentPopulationInfected
from ProjectCovid..CovidDeaths$
Group by population, location
order by PercentPopulationInfected desc

--Looking for countries with highest death count by population
	
Select location,MAX(cast(total_deaths as int)) AS highest_death_count
from ProjectCovid..CovidDeaths$
Where continent is not null
Group by location
order by highest_death_count desc

--Break down by continents
	
Select location ,MAX(cast(total_deaths as int)) AS highest_death_count
from ProjectCovid..CovidDeaths$
Where continent is null 
Group by location
order by highest_death_count desc

--global numbers
	
Select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercetange 
from ProjectCovid..CovidDeaths$
Where continent is not null
--Group by date
order by 1,2

--Join de las tablas
--Poblacion total vacunaciones
	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_ball_vac
from ProjectCovid..CovidDeaths$ dea
join ProjectCovid..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, rolling_people_vac)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vac
from ProjectCovid..CovidDeaths$ dea
join ProjectCovid..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (rolling_people_vac/population)*100
From PopvsVac
