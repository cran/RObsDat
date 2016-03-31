export cranmirror='http://mirrors.softliste.de/cran'
sudo bash -c "echo deb $cranmirror/bin/linux/ubuntu `lsb_release -cs`/ > /etc/apt/sources.list.d/cran.list"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
#sudo add-apt-repository ppa:marutter/rrutter
sudo apt-get update
sudo apt-get install mysql-server  libmysqlclient-dev postgresql postgresql-contrib libpq-dev R-base r-cran-rmysql r-base-dev  libxml2-dev libcurl4-openssl-dev  libgeos-dev subversion
#password: really_secure
echo "create database if not exists obsdat_test; \n
      create user 'a_user'@'localhost' identified by 'secret';
      grant all privileges on obsdat_test.* to 'a_user'@'localhost';
      flush privileges; " | sudo mysql -preally_secure
#set up postgres database
echo "CREATE USER reusser WITH PASSWORD 'secret';" | sudo su -cpsql - postgres 
echo "CREATE DATABASE obsdat_test;" | sudo su -cpsql - postgres 
echo "GRANT ALL PRIVILEGES ON DATABASE obsdat_test to reusser;" | sudo su -cpsql - postgres 

R -e 'dir.create(Sys.getenv("R_LIBS_USER"))'
R -e "install.packages(c('sp', 'testthat','XMLSchema', 'SSOAP', 'xts', 'vwr', 'RSQLite', 'e1071', 'maptools', 'geonames', 'spacetime'), repos = c('http://www.omegahat.net/R', '$cranmirror'), lib=Sys.getenv('R_LIBS_USER'))"
R -e "install.packages(c('RMySQL', 'RPostgreSQL'), repos = '$cranmirror', lib=Sys.getenv('R_LIBS_USER'))"

svn checkout svn://svn.r-forge.r-project.org/svnroot/r-hydro/pkg/Rodm
R CMD INSTALL Rodm

sudo apt-get install texinfo texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-generic-recommended texlive-fonts-extra 
#maybe adjust port setting in test_longExample.R and test_db_engines.R
#turn on db_engines seperately (R crashes if both are used)
R CMD check Rodm
