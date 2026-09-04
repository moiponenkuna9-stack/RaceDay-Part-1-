# RaceDay System Planning

## System description
RaceDay is a race-event management system designed to support event organisers and participants. The planning package documents the database structure, REST API contract and SQL Server implementation before application development.

## Roles
### Organiser
Creates and manages race events, attaches race categories, views participant enrolments and records results.

### Participant
Maintains a profile, views events and categories, enrols in available races, cancels their own enrolments before the deadline and views published results.

## Planning deliverables
- `docs/RaceDay_ERD.png` — seven-entity ERD with PKs, FKs and cardinalities.
- `docs/RaceDay_API_Endpoint_Plan.md` — planned REST API endpoint table.
- `docs/RaceDay_API_Endpoint_Plan.pdf` — printable endpoint plan.
- `docs/RaceDay_Database.sql` — SQL Server database creation, constraints and sample data.

## CI/CD
A GitHub Actions workflow (`.github/workflows/validate-docs.yml`) runs on every push and confirms the `/docs` folder exists and contains the ERD, endpoint plan and SQL script.

**Successful build:**
<!-- TODO: paste a screenshot of the green Actions run here, e.g. -->
<!-- ![CI passing](docs/ci-success.png) -->

## Walkthrough video
<!-- TODO: replace with your unlisted YouTube link once recorded -->
[Watch the planning walkthrough](https://youtu.be/REPLACE_ME)

## Running the Visual Studio project
1. Open `RaceDay.Part1.sln` in Visual Studio with the ASP.NET and web development workload installed.
2. Set `RaceDay.Part1` as the startup project if necessary.
3. Run with **F5** or **Ctrl+F5**.
4. Use the navigation menu to view the Overview, Section A ERD, Section B API Endpoint Plan and Section C SQL section.
5. To execute the database script, open `docs/RaceDay_Database.sql` in SQL Server Management Studio (SSMS) and run it against a clean SQL Server instance.

The Visual Studio website is a planning presentation of the database and API design. 

