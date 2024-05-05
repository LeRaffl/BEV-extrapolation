# anteil BEV neuzulassungen
# https://www.eea.europa.eu/ims/new-registrations-of-electric-vehicles

#### packages ####
#install.packages("readxl")
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("reshape2") # for melt function
#install.packages("ggrepel")                     # coole kleine boxen in legende
library("ggrepel")
library(readxl)
library(tidyr) #to fill in the empty values of names Modellreihe with the value above it
library(dplyr) #his is for leaving out last 5 rows later on
library(ggplot2)
library(reshape2)
library(xts)  #for as.yearmon


#### read all the data and give a data.frame ####
# Get a list of all Excel files in the directory
data_eu <- read_sheet("https://docs.google.com/spreadsheets/d/17h0MJXfIJH4yn2Kk-vmS9Qx_bNJfXfCRqZjFS5__y0k/edit#gid=0", sheet = "registrations")

#plot(x=data_eu$year, y=data_eu$BEV)
#plot(x=data_eu$year, y=data_eu$TOTAL-data_eu$BEV)
#plot(x=data_eu$year, y=data_eu$TOTAL)

verschiebung <- floor(min(na.omit(data.frame(data_eu$year, data_eu$BEV))[,1])) # erstes Jahr mit Daten
extrapol <- 2040

#### estimate linear total sales n EU27 ####
start <- 1070000 #in 2010
end <- 14400000/12 # in 2028
EU_linear <- function(since2010){
  return(927000+since2010*(14400000/12-927399)/18)
}

#### optimize BEV ####
reg <- function(v,x){
  r <- EU_linear(x-verschiebung)*(1-exp(v[1]*(x-verschiebung)^v[2]))
}
f <- function(v){
  forecast<-reg(v,A$x)
  residuals<-A$y-forecast
  r<-sum(residuals^2)
  return(r)
}
xg <- data_eu$year
yg <- as.double(data_eu$BEV)
A <- data.frame(x=xg,y=yg)
A <- na.omit(A)
A <- subset(A, A$y>=2000)
control <- list(maxit = 100000, reltol=10^-30)  # Hier kannst du die maximale Anzahl der Iterationen anpassen
res <- optim(par=c(-0.0001, 6), fn=f, control=control)
res
xg <- seq(verschiebung, extrapol, by=1/12)#bis 75 zum extrapolieren
yg <- reg(v=res$par,xg)
BEV_extrapol <- data.frame(x=xg+1,y=yg)

#### optimize non-BEV aka ICE+Hybrids ####
reg <- function(v,x){
  r <- EU_linear(x-verschiebung)-(EU_linear(x-verschiebung)*(1-exp(v[1]*(x-verschiebung)^v[2])))
}
f <- function(v){
  forecast<-reg(v,A$x)
  residuals<-A$y-forecast
  r<-sum(residuals^2)
  return(r)
}
xg <- data_eu$year
yg <- as.double(data_eu$TOTAL-data_eu$BEV)
A <- data.frame(x=xg,y=yg)
A <- na.omit(A)
A <- subset(A, A$x>=2014)
control <- list(maxit = 100000, reltol=10^-30)  # Hier kannst du die maximale Anzahl der Iterationen anpassen
res <- optim(par=c(-0.0001, 6), fn=f, control=control)
res
xg <- seq(verschiebung, extrapol, by=1/12)#bis 75 zum extrapolieren
yg <- reg(v=res$par,xg)
ICE_extrapol <- data.frame(x=xg+1,y=yg)

#### plot valley of death ####
xg <- seq(2009, extrapol, by=1/12)#bis 75 zum extrapolieren
yg <- EU_linear(xg-verschiebung)
USUAL_DEMAND <- data.frame(x=xg+1,y=yg)

EU_valley_of_death <- ggplot() +
  geom_point(data = data_eu, aes(x = year + 1, y = BEV, color = "BEV Prognostiziert"), col = "green", cex = 0.5) +
  geom_point(data = subset(data_eu, data_eu$year>=2016), aes(x = year + 1, y = TOTAL-BEV, color="Non-BEV"), col = "black", cex = 0.5) +
  geom_point(data = ICE_extrapol, aes(x = x, y = y), col = "black", cex = 0.5) +
  geom_point(data = BEV_extrapol, aes(x = x, y = y), col = "green", cex = 0.5) +
  geom_point(data = ICE_extrapol, aes(x = x, y = y + BEV_extrapol$y), col = "violet", cex = 0.5) +
  geom_point(data = USUAL_DEMAND, aes(x = x, y = y), col = "blue", cex = 0.25) +
  ylim(0, 1500000) +  # Erweitern des Datenbereichs der y-Achse
  labs(title = "ICE and non-ICE Sales in EU27", subtitle = "including natural and expected demand",
       x = "Year", y = "Sales") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(2010, extrapol, by = 2), labels = function(x) paste0("Jan ", x)) +
  scale_color_manual(values = c("green", "black", "violet", "blue"), name = "Legend") +
  theme(legend.position = "top", legend.background = element_rect(fill = "gray99"))

EU_valley_of_death


flag_img <- readPNG("/Users/raphaelwellmann/Library/Mobile Documents/com~apple~CloudDocs/R/bev_share_EU/valley_of_death/eu.png")
EU_valley_of_death <- EU_valley_of_death + annotation_custom(grob = rasterGrob(as.raster(flag_img), interpolate = TRUE), xmin = extrapol-4, xmax = extrapol, ymin = 200000, ymax = 500000)
EU_valley_of_death <- EU_valley_of_death + annotate("text", x=extrapol, y=200000, label="By @LeRaffl", size=5,hjust=1, vjust=1)
current_date <- format(Sys.Date(), "%Y")
data_month <- (as.integer(((A$x%%1)*12+1)[length(A$x)])+1)%%12
#EU_valley_of_death <- EU_valley_of_death + annotate("text", x = extrapol, y = 100000, label = paste0("Data per ", Sys.Date()), size = 4, hjust = 1, vjust = 1)
#EU_valley_of_death <- EU_valley_of_death + annotate("text", x = extrapol, y = 0, label = paste0(""), size = 3, hjust = 1, vjust = 1)

EU_valley_of_death
