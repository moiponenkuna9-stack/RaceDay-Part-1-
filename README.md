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
A GitHub Actions workflow (https://github.com/moiponenkuna9-stack/RaceDay-Part-1-/commit/93ac2ca67942429b0cbefb62198f04dab3e96f7f) runs on every push and confirms the `/docs` folder exists and contains the ERD, endpoint plan and SQL script.

**Successful build:**
<img width="1366" height="768" alt="Screenshot 2026-09-04 190406" src="https://github.com/user-attachments/assets/611ec23c-cabf-4b50-b663-1a8dd33e6150" />



## Walkthrough video
https://youtu.be/hNimI0ds8eo?si=Y7wN7lY_b0c7XCzL 

The Visual Studio website is a planning presentation of the database and API design. 

