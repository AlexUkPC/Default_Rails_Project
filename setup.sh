##move everything from default_project out
mv Default_Rails_Project/{*,.[^.]*} .
rm -rf Default_Rails_Project .git

##ask for project_name
##ask for db username and psw for dev
##ask for port
##ask for webpacker server port
read -p "Enter project name [untitled]:" project_name
project_name=${project_name:-untitled}
while [ $((10#$project_id + 0)) -lt 0 ] || [ $((10#$project_id + 0)) -gt 255 ] || [ `expr length "$project_id"` -ne 3 ]
do
  read -p "Enter project id (3 digits between 000-255, eg. 001):" project_id
done
PS3="Select Ruby version:"
select ruby_version in 2.7.2
do
  case $ruby_version in
    2.7.2)
      break
      ;;
    *)
      echo "Invalid selection"
      ;;
  esac
done
PS3="Select Rails version:"
select rails_version in 6.1.3
do
  case $rails_version in
    6.1.3)
      break
      ;;
    *)
      echo "Invalid selection"
      ;;
  esac
done

read -p "Database [postgres]:" database
database=${database:-postgres}
if [ "$database" == "postgres" ]
then
  read -p "Version [13]:" postgres_version
  postgres_version=${postgres_version:-13}
  read -p "Enter postgres username [postgres]:" postgres_user
  postgres_user=${postgres_user:-postgres}
  read -p "Enter postgres psw [password]:" postgres_psw
  postgres_psw=${postgres_psw:-password}
fi
while [ "$choice" != "y" ] && [ "$choice" != "Y" ] && [ "$choice" != "n" ] && [ "$choice" != "N" ]
do
  read -p "Do you want to use the default ports and subnetworks generated from project id(project port: 3$project_id | webpacker port: 4$project_id | subnet: 172.10.$project_id.0 | jenkins subnet: 172.11.$project_id.0)? [y/n]:" choice
  if [ "$choice" == "n" ] || [ "$choice" == "N" ]
  then
    read -p "Enter project port [3$project_id]:" project_port
    read -p "Enter webpacker port [4$project_id]:" webpacker_port
    read -p "Enter subnet [172.10.$project_id.0]:" subnet
    read -p "Enter jenkins subnet [172.11.$project_id.0]:" jenkins_subnet
  fi
  project_port=${project_port:-3$project_id}
  webpacker_port=${webpacker_port:-4$project_id}
  subnet=${subnet:-172.10.$project_id.0}
  jenkins_subnet=${jenkins_subnet:-172.11.$project_id.0}
done

##replace <project_name>,dev db username and psw, port and webpacker port in all files
##rename files with <project_name> where needed

grep -RiIl --exclude=setup.sh '<project_name>' | xargs sed -i 's/<project_name>/'$project_name'/g'
grep -RiIl --exclude=setup.sh '<postgres_version>' | xargs sed -i 's/<postgres_version>/'$postgres_version'/g'
grep -RiIl --exclude=setup.sh '<postgres_user>' | xargs sed -i 's/<postgres_user>/'$postgres_user'/g'
grep -RiIl --exclude=setup.sh '<postgres_psw>' | xargs sed -i 's/<postgres_psw>/'$postgres_psw'/g'
grep -RiIl --exclude=setup.sh '<port>' | xargs sed -i 's/<port>/'$project_port'/g'
grep -RiIl --exclude=setup.sh '<port_webpacker>' | xargs sed -i 's/<port_webpacker>/'$webpacker_port'/g'
grep -RiIl --exclude=setup.sh '<subnet>' | xargs sed -i 's/<subnet>/'$subnet'/g'
grep -RiIl --exclude=setup.sh '<jenkins_subnet>' | xargs sed -i 's/<jenkins_subnet>/'$jenkins_subnet'/g'
grep -RiIl --exclude=setup.sh '<ruby_version>' | xargs sed -i 's/<ruby_version>/'$ruby_version'/g'
grep -RiIl --exclude=setup.sh '<rails_version>' | xargs sed -i 's/<rails_version>/'$rails_version'/g'

mv env_example/development/web env_example/development/web_$project_name
mv env_example/development/database env_example/development/database_$project_name
mv env_example/production/web env_example/production/web_$project_name
mv env_example/production/database env_example/production/database_$project_name
mv env_example/jenkins/web env_example/jenkins/web_$project_name
mv env_example/jenkins/database env_example/jenkins/database_$project_name
cp -r env_example/ .env
mv docker-compose-project_name.yml docker-compose-$project_name.yml

docker build -t rails-toolbox-$project_name --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -f Dockerfile.rails .
docker run -it --rm -v $PWD:/opt/app rails-toolbox-$project_name rails new -d postgresql --skip-bundle $project_name

rm -r $project_name/.git
mv docker-entrypoint.sh $project_name
chmod +x $project_name/docker-entrypoint.sh

####### this part doesn't working right now ######
# grep -RiIl --exclude=setup.sh --exclude-dir=bkp 'pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>' | xargs sed -i 's/pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>/pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>\n  host: <%= ENV.fetch("DATABASE_HOST"){ "none" }  %>\n  username: <%= ENV.fetch("POSTGRES_USER"){ "none" }  %>\n  password: <%= ENV.fetch("POSTGRES_PASSWORD"){ "none" }  %>\n  database: <%= ENV.fetch("POSTGRES_DB"){ "none" }  %>\n  timeout: 5000/g'
# grep -RiIl --exclude=setup.sh --exclude-dir=bkp 'database: '$project_name'_development' | xargs sed -i 's/database: '$project_name'_development/''/g'
# grep -RiIl --exclude=setup.sh --exclude-dir=bkp << EndOfMessage database: '$project_name'_production\n  username: '$project_name'\n  password: <%= ENV['
# EndOfMessage
# $project_name^^<< EndOfMessage _DATABASE_PASSWORD''] %> 
# EndOfMessage | xargs sed -i 's/'<< EndOfMessage database: '$project_name'_production\n  username: '$project_name'\n  password: <%= ENV['
# EndOfMessage
# '/''/g'
####### this part doesn't working right now ######

docker-compose run --rm web_$project_name bundle install
docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name bin/rails webpacker:install
