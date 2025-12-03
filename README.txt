README.txt - CIS560 Final Project - Group 09 

Overview: The goal of this README is to explain the structure of the files in our submission, in hopes to aid the grader in finding the components mentioned in the assignment description. 

MAIN STRUCTURE:
	SQL/MOCK DATA: 'cis560-smss-setup'
	UI: 	       'CIS560 - Final Project/PhantomWatchUI'


Tables.sql
	- Location: cis560-smss-setup
	- purpose: the script used to create all of our tables such as "dbo.Behaviors , dbo.Cities, dbo.Entities, dbo.SightingBehaviors, dbo.Sightings, dbo.Users, dbo.UserSightings, dbo.UserVotes"

Procedures.sql
	- Location: cis560-smss-setup
	- purpose: the script used to create the functionality of our system. Included in here are the four aggregating queries "dbo.AverageCredibilityByReporter , dbo.RegionsWithHighScaryEntities, dbo.RepeatVsSingleReports , dbo.TopRegionsByCredibility". This is seen in SSMS in PhantomWatchDB->Programmability->Stored Procedures .

Data.sql
	- Location: cis560-smss-setup
	- purpose: the script used to populate our tables with initial data from our MOCKCSV's. 

Mock Data
	- Location: cis560-smss-setup/Mock_Data_CSVs
	- purpose: where our mock data is stored in excel sheets. This includes "BEHAVIORS_MOCK.csv , CITIES_MOCK.csv , ENTITIES_MOCK.csv , SIGHTINGBEHAVIORS_MOCK.csv , SIGHTINGS_MOCK.csv , USERSIGHTINGS_MOCK.csv , USERS_MOCK.csv "

Application Code
	- Location: CIS560 - Final Project/PhantomWatchUI

	/DataDelegates: this is where we bridge the SQL code and the application code, using a delegate for each table. 

	/Models: this is where we create a model class for each class so the C# UI code has an object to reference for each table. This is basically a property for each column in the table with { get ; set; } .

	/Program.cs: this is where we build the Razor Page application, link the delegates to the UI, and run the application. 

	/wwwroot: this is all of the css and stylization properties for the User Interface. 

	/Pages: this is where our Razor Pages are stored for the different User Interface views. This includes the Login screen, Home screen , Analytics Dashboard , Admin View, and so on. It is all cshtml or cshtml.cs . 
