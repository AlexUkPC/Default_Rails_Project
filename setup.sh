##move everything from default_project out
mv Default_Rails_Project/{*,.[^.]*} .
rm -rf Default_Rails_Project .git

##ask for project_name
##ask for db username and psw for dev
##ask for port
##ask for webpacker server port
read -p "Enter project name [untitled]:" project_name
project_name=${project_name:-untitled}
while [ "$choice" != "y" ] && [ "$choice" != "Y" ] && [ "$choice" != "n" ] && [ "$choice" != "N" ]
do
  read -p "Is this an API only app?" choice
  if [ "$choice" == "y" ] || [ "$choice" == "Y" ]
  then
    api="--api"
  else
    api=""
  fi
done
while [ $((10#$project_id + 0)) -lt 0 ] || [ $((10#$project_id + 0)) -gt 255 ] || [ `expr length "$project_id"` -ne 3 ]
do
  read -p "Enter project id (3 digits between 000-255, eg. 001):" project_id
done
PS3="Select Ruby version:"
select ruby_version in 2.7.2 2.7.6 3.0.0 3.1.2
do
  case $ruby_version in
    2.7.2)
      break
      ;;
    2.7.6)
      break
      ;;
    3.0.0)
      break
      ;;
    3.1.2)
      break
      ;;
    *)
      echo "Invalid selection"
      ;;
  esac
done
PS3="Select Rails version:"
select rails_version in 6.1.3 6.1.7 7.0.0 7.0.4
do
  case $rails_version in
    6.1.3)
      break
      ;;
    6.1.7)
      break
      ;;
    7.0.0)
      break
      ;;
    7.0.4)
      break
      ;;
    *)
      echo "Invalid selection"
      ;;
  esac
done

if [[ $rails_version == 7* ]]
then
  PS3="Select what to use as js bundling:"
  select js_bundling in import_maps webpack esbuild rollup
  do
    case $js_bundling in
      import_maps)
        break
        ;;
      webpack)
        break
        ;;
      esbuild)
        break
        ;;
      rollup)
        break
        ;;
      *)
        echo "Invalid selection"
        ;;
    esac
  done
  PS3="Select what to use as css bundling:"
  select css_bundling in css tailwind bootstrap bulma postcss sass
  do
    case $css_bundling in
      css)
        break
        ;;
      tailwind)
        break
        ;;
      bootstrap)
        break
        ;;
      bulma)
        break
        ;;
      postcss)
        break
        ;;
      sass)
        break
        ;;
      *)
        echo "Invalid selection"
        ;;
    esac
  done
  grep -RiIl --exclude=setup.sh '<webpacker_env>' | xargs sed -i 's/<webpacker_env>//g'
  grep -RiIl --exclude=setup.sh '<webpacker>' | xargs sed -i 's/<webpacker>//g'
  grep -RiIl --exclude=setup.sh '<webpacker_env_jenkins>' | xargs sed -i 's/<webpacker_env_jenkins>//g'
  grep -RiIl --exclude=setup.sh '<webpacker_jenkins>' | xargs sed -i 's/<webpacker_jenkins>//g'
  grep -RiIl --exclude=setup.sh '<webpacker_in_jenkins>' | xargs sed -i 's/<webpacker_in_jenkins>//g'
  grep -RiIl --exclude=setup.sh '<js_css>' | xargs sed -i 's/<js_css>/Js bundler: '$js_bundling'\nCss bundler: '$css_bundling'/g'
else
  grep -RiIl --exclude=setup.sh '<webpacker_env>' | xargs sed -i 's/<webpacker_env>/environment: \n      - WEBPACKER_DEV_SERVER_HOST=webpack_dev_server_<project_name>/g'
  grep -RiIl --exclude=setup.sh '<webpacker>' | xargs sed -i 's/<webpacker>/webpack_dev_server_<project_name>:\n    build:\n      context: .\n      args:\n        USER_ID: "${USER_ID:-1000}" \n        GROUP_ID: "${GROUP_ID:-1000}"\n    command: .\/bin\/webpack-dev-server\n    ports: \n      - "<port_webpacker>:<port_webpacker>"\n    volumes: \n      - .\/<project_name>:\/opt\/app\n      - gem_cache_<project_name>:\/gems\n    env_file: \n      - .env\/development\/database_<project_name>\n      - .env\/development\/web_<project_name>\n    environment: \n      - WEBPACKER_DEV_SERVER_HOST=0.0.0.0\n    networks:\n      - network_<project_name>/g'
  grep -RiIl --exclude=setup.sh '<webpacker_env_jenkins>' | xargs sed -i 's/<webpacker_env_jenkins>/environment: \n      - WEBPACKER_DEV_SERVER_HOST=webpack_dev_server_<project_name>_jenkins/g'
  grep -RiIl --exclude=setup.sh '<webpacker_jenkins>' | xargs sed -i 's/<webpacker_jenkins>/webpack_dev_server_<project_name>_jenkins:\n    build:\n      context: .\n      args:\n        USER_ID: "${USER_ID:-1000}"\n        GROUP_ID: "${GROUP_ID:-1000}"\n    command: .\/bin\/webpack-dev-server\n    ports: \n      - "1<port_webpacker>:<port_webpacker>"\n    volumes: \n      - .\/<project_name>:\/opt\/app\n      - gem_cache_<project_name>_jenkins:\/gems\n    env_file: \n      - .env\/jenkins\/database_<project_name>\n      - .env\/jenkins\/web_<project_name>\n    environment: \n      - WEBPACKER_DEV_SERVER_HOST=0.0.0.0\n    networks:\n      - network_<project_name>_jenkins/g'
  grep -RiIl --exclude=setup.sh '<webpacker_in_jenkins>' | xargs sed -i "s/<webpacker_in_jenkins>/stage('Webpacker Install') {\n            steps {\n                sh '\/usr\/local\/bin\/docker-compose -f docker-compose-jenkins.yml run --rm web_<project_name>_jenkins bin\/rails webpacker:install'\n            }\n        }/g"
  grep -RiIl --exclude=setup.sh '<js_css>' | xargs sed -i 's/<js_css>/Webpacker/g'
fi

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
choice=""
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

if [ "$js_bundling" == "" ] || [ "$css_bundling" == "" ]
then
  sed -i 's/<rails_dev>/rails", "s", "-b", "0.0.0.0/g' Dockerfile
  docker run -it --rm -v $PWD:/opt/app rails-toolbox-$project_name rails new $api -d postgresql --skip-bundle $project_name
else
  if [ "$js_bundling" == "import_maps" ] && [ "$css_bundling" == "css" ]
  then
    sed -i 's/<rails_dev>/rails/g' Dockerfile
    docker run -it --rm -v $PWD:/opt/app rails-toolbox-$project_name rails new $api -d postgresql --skip-bundle $project_name
  else
    sed -i 's/<rails_dev>/dev/g' Dockerfile
    if [ "$js_bundling" != "import_maps" ] && [ "$css_bundling" == "css" ]
    then
      docker run -it --rm -v $PWD:/opt/app rails-toolbox-$project_name rails new $api -d postgresql --skip-bundle -j $js_bundling $project_name
    else
      if [ "$js_bundling" == "import_maps" ] && [ "$css_bundling" != "css" ]
      then
        docker run -it --rm -v $PWD:/opt/app rails-toolbox-$project_name rails new $api -d postgresql --skip-bundle  -c $css_bundling $project_name
      else
        docker run -it --rm -v $PWD:/opt/app rails-toolbox-$project_name rails new $api -d postgresql --skip-bundle -j $js_bundling -c $css_bundling $project_name
      fi
    fi
  fi
fi

rm -r $project_name/.git
mv docker-entrypoint.sh $project_name
chmod +x $project_name/docker-entrypoint.sh
if [ "$js_bundling" == "import_maps" ] && [ "$css_bundling" == "css" ]
then
  grep -RiIl --exclude=setup.sh '<node_and_yarn>' | xargs sed -i 's/<node_and_yarn>//g'
  grep -RiIl --exclude=setup.sh '<node_and_yarn_install>' | xargs sed -i 's/<node_and_yarn_install>//g'
  sed -i 's/<node>//g' README.md
  sed -i 's/<yarn>//g' README.md
else
  PS3="Select Node version:"
  select node_version in 16 18 20 lts
  do
    case $node_version in
      16)
        break
        ;;
      18)
        break
        ;;
      20)
        break
        ;;
      lts)
        break
        ;;
      *)
        echo "Invalid selection"
        ;;
    esac
  done
  grep -RiIl --exclude=setup.sh '<node_and_yarn>' | xargs sed -i 's/<node_and_yarn>/RUN curl -sS https:\/\/dl.yarnpkg.com\/debian\/pubkey.gpg -o \/root\/yarn-pubkey.gpg \&\& apt-key add \/root\/yarn-pubkey.gpg\nRUN echo "deb https:\/\/dl.yarnpkg.com\/debian\/ stable main" > \/etc\/apt\/sources.list.d\/yarn.list\nRUN curl -fsSL https:\/\/deb.nodesource.com\/setup_'$node_version'.x | bash -\n/g'
  grep -RiIl --exclude=setup.sh '<node_and_yarn_install>' | xargs sed -i 's/<node_and_yarn_install>/ nodejs yarn/g'
fi

docker-compose run --rm web_$project_name bundle install
if [ "$js_bundling" == "import_maps" ] && [ "$css_bundling" == "css" ]
then
  break
else
  node_v=$(docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name node -v)
  sed -i 's/<node>/Node: '$node_v'/g' README.md
  yarn_v=$(docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name yarn -v)
  sed -i 's/<yarn>/Yarn: '$yarn_v'/g' README.md
fi
if [ "$js_bundling" == "" ] || [ "$css_bundling" == "" ]
then
  docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name bin/rails webpacker:install
  sed -i '/port: 3035/{
  N 
  s/port: 3035\n    public: localhost:3035/port: '$webpacker_port'\n    public: 0.0.0.0:'$webpacker_port'/
  }' $project_name/config/webpacker.yml
  sed -i "s/ignored: '\*\*\/node_modules\/\*\*'/ignored: '\*\*\/node_modules\/\*\*'\n      poll: true/g" $project_name/config/webpacker.yml
else
  if [ "$js_bundling" != "import_maps" ] && [ "$css_bundling" == "css" ]
  then
    docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name bin/rails javascript:install:$js_bundling
  else
    if [ "$js_bundling" == "import_maps" ] && [ "$css_bundling" != "css" ]
    then
      docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name bin/rails css:install:$css_bundling
    else
      docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name bin/rails javascript:install:$js_bundling
      docker-compose run --rm --user "$(id -u):$(id -g)" web_$project_name bin/rails css:install:$css_bundling
    fi
  fi
  docker-compose run --rm web_$project_name bundle install
  sed -i 's/web: bin\/rails server -p 3000/web: bin\/rails server -p 3000 -b 0.0.0.0/g' $project_name/Procfile.dev
fi

sed -i 's/pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>/pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>\n  host: <%= ENV.fetch("DATABASE_HOST"){ none}  %>\n  username: <%= ENV.fetch("POSTGRES_USER"){ none}  %>\n  password: <%= ENV.fetch("POSTGRES_PASSWORD"){ none}  %>\n  database: <%= ENV.fetch("POSTGRES_DB"){ none}  %>\n  timeout: 5000/g' $project_name/config/database.yml
sed -i 's/database: '$project_name'_development//g' $project_name/config/database.yml
sed -i 's/database: '$project_name'_test//g' $project_name/config/database.yml
sed -i 's/database: '$project_name'_production//g' $project_name/config/database.yml
sed -i 's/username: '$project_name'//g' $project_name/config/database.yml
sed -i "s/password: <%= ENV\['"${project_name^^}"_DATABASE_PASSWORD'\] %>//g" $project_name/config/database.yml

docker-compose up