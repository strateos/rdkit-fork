// groovy
pipeline {
    agent { label "compound-worker" }

    environment {
        AWS_DEFAULT_REGION = "us-west-2"
    }
    stages {

        stage("Setup") {
            steps {
                sh './Scripts/setup.sh'
            }
        }

        stage("Install Dependencies") {
            steps {
                sh './Scripts/install_deps.sh'
            }
        }

        stage("Build") {
            steps {
                sh './Scripts/build.sh'
            }
        }

        stage('Publish Artifacts to artifactory') {
         when { branch 'master' }
          environment {
            REPOSITORY_KEY = "rdkit_java_wrapper"
            ARTIFACTORY_USERNAME= "jenkins_rdkit_publish"
            //ARTIFACTORY_PASSWORD = credentials('buildsecret.artifactory_rdkit_publish_token')
          }
          steps {
            sh 'make -j $(nproc) && make install'
          }
        }
    }
}
