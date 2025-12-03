# PhantomWatch – CIS 560 Final Project (Group 09)

This repository contains all components of the CIS 560 Final Project.  
The structure and purpose of each directory and file are outlined below to assist reviewers in locating the required materials.

---

## Repository Structure

### **SQL / Mock Data**
**Directory:** `cis560-smss-setup`  
Contains all SQL scripts and CSV mock data used to build and populate the database.

#### **Tables.sql**
- **Location:** `cis560-smss-setup`  
- **Purpose:** Creates all database tables:  
  `dbo.Behaviors`, `dbo.Cities`, `dbo.Entities`, `dbo.SightingBehaviors`,  
  `dbo.Sightings`, `dbo.Users`, `dbo.UserSightings`, `dbo.UserVotes`.

#### **Procedures.sql**
- **Location:** `cis560-smss-setup`  
- **Purpose:** Defines stored procedures and system functionality, including the four analytic procedures:  
  - `dbo.AverageCredibilityByReporter`  
  - `dbo.RegionsWithHighScaryEntities`  
  - `dbo.RepeatVsSingleReports`  
  - `dbo.TopRegionsByCredibility`  
  These are located in SSMS under: **PhantomWatchDB → Programmability → Stored Procedures**.

#### **Data.sql**
- **Location:** `cis560-smss-setup`  
- **Purpose:** Loads all mock CSV data into the database tables.

#### **Mock Data (CSV Files)**
- **Location:** `cis560-smss-setup/Mock_Data_CSVs`  
- **Purpose:** Stores all mock data files used to populate the system, including:  
  `BEHAVIORS_MOCK.csv`, `CITIES_MOCK.csv`, `ENTITIES_MOCK.csv`,  
  `SIGHTINGBEHAVIORS_MOCK.csv`, `SIGHTINGS_MOCK.csv`,  
  `USERSIGHTINGS_MOCK.csv`, `USERS_MOCK.csv`.

---

## Application Code
**Directory:** `CIS560 - Final Project/PhantomWatchUI`  
Contains the entirety of the C# Razor Pages front-end application.

### **/DataDelegates**
Bridge layer between the SQL database and the UI.  
Each delegate corresponds to a table or operation and encapsulates its queries.

### **/Models**
C# model classes representing each database table.  
Each property corresponds directly to a table column using `{ get; set; }`.

### **Program.cs**
Entry point for the Razor Pages web application.  
Configures services, binds delegates, and starts the application.

### **/wwwroot**
Holds static assets including CSS files and styling resources for the UI.

### **/Pages**
Contains all Razor Pages (`.cshtml` and `.cshtml.cs`) used throughout the application, including:
- Login
- Home Feed
- Analytics Dashboard
- Admin Interface
- Additional user-facing views

---

## Setup Hint

- Open SQL Server Management Studio and ensure you are connected to **localdb**.

- Run **Data.sql**  
  - Update all file paths to match your machine. Example:  
    `C:\Users\tjlar\OneDrive\Desktop\CIS560 - Final Project\Mock_Data_CSVs\[CSV NAME]`  
  - After updating paths, execute the script.

- Run **Procedures.sql**.

- Open **Visual Studio**.  
  You should be able to open the repository directly from GitHub.



## Summary

This repository integrates:
- A full SQL Server database with schema, stored procedures, and mock data.
- A Razor Pages web application.

