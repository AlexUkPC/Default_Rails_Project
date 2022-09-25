pipeline {
    agent {
        label 'ssh'  
    }
    parameters {
        string(name: 'REF', defaultValue: '\${ghprbActualCommit}', description: 'Commit to build')
    }
    stages {
        stage('Prepare x files') {
           steps {
                sh 'chmod +x *.sh'
                sh 'chmod +x <project_name>/docker-entrypoint.sh'
                sh 'chmod +x <project_name>/bin/*'
            }
        }
        stage('Bundle Install') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml run --rm web_<project_name>_jenkins bundle install'
            }
        }
        <webpacker_in_jenkins>
        stage('Stop old containers') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml stop'
            }
        }
        stage('Start server') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml up -d --remove-orphans --force-recreate'
            }
        }
        stage('Create database') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml exec -T --user "$(id -u):$(id -g)" web_<project_name>_jenkins bin/rails db:drop'
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml exec -T --user "$(id -u):$(id -g)" web_<project_name>_jenkins bin/rails db:create'
            }
        }
        stage('Migrate database') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml exec -T --user "$(id -u):$(id -g)" web_<project_name>_jenkins bin/rails db:migrate'
            }
        }
        stage('Seed database') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml exec -T --user "$(id -u):$(id -g)" web_<project_name>_jenkins bin/rails db:seed'
            }
        }
        stage('Wait for server to start') {
            steps {
                timeout(10) {
                    waitUntil {
                        script {
                            try {
                                def response = httpRequest 'http://0.0.0.0:1<port>'
                                return (response.status == 200)
                            }
                            catch (exception) {
                                return false
                            }
                        }
                    }
                }
            }
        }
        stage('Unit test') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml exec -T --user "$(id -u):$(id -g)" web_<project_name>_jenkins bin/rails test:models'
            }   
        } 
        stage('Stop containers') {
            steps {
                sh '/usr/local/bin/docker-compose -f docker-compose-jenkins.yml stop'
            }
        }
    }
}