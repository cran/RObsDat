### R code from vignette source 'RObsDat_tutorial.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: default (eval = FALSE)
###################################################
## getDefaultDB()


###################################################
### code chunk number 2: sqlite (eval = FALSE)
###################################################
## require("RObsDat")
## require("RSQLite")
## m <- dbDriver("SQLite")
## dbname = "database.db"
## con <- dbConnect(m, dbname = dbname)
## sqhandler <-  new("odm1_1Ver", con=con)
## options(odm.handler=sqhandler)


###################################################
### code chunk number 3: engines (eval = FALSE)
###################################################
## #connect to postgreSQL database
## require("RObsDat")
## require("RPostgreSQL")
## m <- dbDriver("PostgreSQL")
## con <- dbConnect(m, user="a_user", password="secret", dbname="obsdat")
## sqhandler <-  new("odm1_1Ver", con=con)
## options(odm.handler=sqhandler)
## 
## #connect to MySQL database
## require("RObsDat")
## require("RMySQL")
## m <- dbDriver("MySQL")
## con <- dbConnect(m, user="a_user", password="secret", dbname="obsdat")
## sqhandler <-  new("odm1_1Ver", con=con)
## options(odm.handler=sqhandler)


###################################################
### code chunk number 4: part1
###################################################
require("RObsDat")
getDefaultDB()


###################################################
### code chunk number 5: part2
###################################################
#Store metadata in database
getMetadata("SpatialReference", SRSName="WGS84", exact=TRUE)

addSite(Code="testLocation", Name="Virtual test site", x=-5, y=46,
	LatLongDatum="WGS84", Elevation=1500, State="Germany")

getMetadata("Units", Abbreviation="cm")
getMetadata("VariableName", Term="Distance")

addVariable(Name="Distance", Unit="cm", ValueType="Field Observation",
	GeneralCategory="Instrumentation", Code="test_dist")

addQualityControlLevel(ID=6,Code="ok", Definition="The default")

addISOMetadata(TopicCategory="Unknown", Title="Testdata",
	Abstract="This data is created to test the functions of RObsDat")
addSource(Organization="Your Org", SourceDescription="Madeup data", 
	SourceLink="RObsDat Documentation", ContactName="Yourself",
	Metadata="Testdata")


###################################################
### code chunk number 6: part2
###################################################
library(xts)

example.data <- xts(1:366, seq(as.POSIXct("2010-01-01", tz="UTC"), 
		as.POSIXct("2011-01-01", tz="UTC"), length.out=366))
example.data[50] <- 100
example.data[200] <- 40


###################################################
### code chunk number 7: part3
###################################################
addDataValues(example.data[1:100], Site="testLocation", Variable="test_dist",  
	Source="Madeup", QualityControlLevel="ok")
#Avoid duplicates autmatically
example.data[75] <- 100
addDataValues(example.data, Site="testLocation", Variable="test_dist",  
	Source="Madeup", QualityControlLevel="ok")


###################################################
### code chunk number 8: part4
###################################################
inDB <- getDataValues(Site="test")
plot(inDB)


###################################################
### code chunk number 9: part4
###################################################
#Version management
to.correct <- which(inDB@values < 100 & 
	index(inDB@values) > as.POSIXct("2010-06-01"))
inDB@values[to.correct] <- 200
inDB@values[50] <- 50

updateDataValues(inDB, "Correction of wrong value")

ver2 <- inDB
ver2@values[50:60] <- 90
updateDataValues(ver2, "Changing more data")

ver3 <- inDB
ver3@values[50:60] <- 190
updateDataValues(ver3, "Ups, I used 90 instead of 190 by mistake")

deleteDataValues(inDB[250],  "And finally remove a value")

getDataVersions()

versionQuery <- getDataValues(Site=1, VersionID=1)

plot(versionQuery)
versionQuery <- getDataValues(Site=1, VersionID=2)
plot(versionQuery)


