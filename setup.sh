##move everything from default_project out
mv Default_Rails_Project/{*,.[^.]*} .
rm -rf Default_Rails_Project .git

##ask for project_name
##ask for db username and psw for dev
##ask for port
##ask for webpacker server port
read -p "Enter project name [untitled]:" project_name
project_name=${project_name:-untitled}
read -p "Database [postgres]:" database
database=${database:-postgres}
if ["$database" == "postgres"]
then
  read -p "Version [13]:" postgres_version
  postgres_version=${postgres_version:-13}
  read -p "Enter postgres username [postgres]:" postgres_user
  postgres_user=${postgres_user:-postgres}
  read -p "Enter postgres psw [password]:" postgres_psw
  postgres_psw=${postgres_psw:-password}
fi
read -p "Enter project port [3000]:" project_port
project_port=${project_port:-3000}
read -p "Enter project webpacker port [3035]:" webpacker_port
webpacker_port=${webpacker_port:-3035}

##replace <project_name>,dev db username and psw, port and webpacker port in all files
##rename files with <project_name> where needed

grep -RiIl --exclude=setup.sh '<project_name>' | xargs sed -i 's/<project_name>/'$project_name'/g'
grep -RiIl --exclude=setup.sh '<postgres_user>' | xargs sed -i 's/<postgres_user>/'$postgres_user'/g'
grep -RiIl --exclude=setup.sh '<postgres_psw>' | xargs sed -i 's/<postgres_psw>/'$postgres_psw'/g'
grep -RiIl --exclude=setup.sh '<port>' | xargs sed -i 's/<port>/'$project_port'/g'
grep -RiIl --exclude=setup.sh '<port_webpacker>' | xargs sed -i 's/<port_webpacker>/'$webpacker_port'/g'

# cp -r env_example/ .env
# mv .env/development/web .env/development/web_$project_name
# mv .env/development/database .env/development/database_$project_name
# mv .env/production/web .env/production/web_$project_name
# mv .env/production/database .env/production/database_$project_name
# mv env_example/development/web env_example/development/web_$project_name
# mv env_example/development/database env_example/development/database_$project_name
# mv env_example/production/web env_example/production/web_$project_name
# mv env_example/production/database env_example/production/database_$project_name
# mv docker-compose-project_name.yml docker-compose-$project_name.yml

# docker build -t rails-toolbox-$project_name --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -f Dockerfile.rails .
# docker run -it --rm -v $PWD:/opt/app rails-toolbox-$project_name rails new -d postgresql --skip-bundle $project_name

# rm -r $project_name/.git
# mv docker-entrypoint.sh $project_name
# chmod +x $project_name/docker-entrypoint.sh

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

# docker-compose run --rm web_$project_name bundle install
# docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name bin/rails webpacker:install
