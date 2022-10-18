// groovy
// curl -v --user username:password --data-binary @local-file -X PUT "http://<artifactory server >/artifactory/abc-snapshot-local/remotepath/remotefile"
pipeline {
    agent { label "compound-worker" }

    environment {
        AWS_DEFAULT_REGION = "us-west-2"
        BOOST_VERSION = "1.80.0"
        JAVA_VERSION = "17"

        BUILDDIR = "${pwd(tmp: true)}/build"
        RDKIT_INSTALL_PREFIX="${pwd(tmp: true)}/rdkit"
    }

    stages {

        stage("Setup packages") {
            steps {
                sh './Scripts/setup.sh && make -f Scripts/Makefile.strateos gradle-setup'
            }
        }

        stage("Setup dependencies") {
            steps {
                sh 'make -f Scripts/Makefile.strateos boost inchi'
            }
        }

        stage("Build") {
            steps {
                sh 'make -f Scripts/Makefile.strateos rdkit'
            }
        }

        stage('Publish Artifacts to artifactory') {
            //when { buildingTag() }
            environment {
                REPOSITORY_KEY = "rdkit-java-wrapper"
                ARTIFACTORY_USERNAME= "jenkins_rdkit_publish"
                ARTIFACTORY_PASSWORD = credentials('buildsecret.artifactory_rdkit_publish_token')
                PATH = "${env.BUILDDIR}/gradle/bin:${env.PATH}"
            }
            steps {
                sh 'gradle -b Scripts/build.gradle artifactoryPublish'
            }
        }
    }
}