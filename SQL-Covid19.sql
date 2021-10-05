
Select *
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject.dbo.CovidVaccinations$
--Order by 3, 4

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
order by 1,2

-- Total cases vs Total deaths

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

-- Total cases vs Population

Select Location, Date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
Where continent is not null
order by 1,2

-- Contries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Countries with Highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- break thing down by continent

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Continent with Highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global number

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
From PortfolioProject.dbo.CovidDeaths$
-- where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

-- Total population vs Vaccinations
-- convert(int,vac.new_vaccinations) = cast(vac.new_vaccinations as int)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE
With PopVsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopVsVac



-- Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated



--Creating view to store data for later visualizations

Drop view if exists PercentagePopulationVaccinated
Create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select*
From PercentagePopulationVaccinated



