// Check which Jenkins instanice we're using
def getJenkinsMaster() {
    return env.BUILD_URL.split('/')[2].split(':')[0]
}

// Execute this before anything else, including requesting any time on an agent
masterURL = getJenkinsMaster()
println("INFO: Jenkins Master URL: " + masterURL)
if (! masterURL.equals("jenkins.core.internal.strateos.com")) {
   println("INFO: Incorrect Jenkins instance. This job should only build on our 'Core' instance in EKS (https://jenkins.core.internal.strateos.com).")
   currentBuild.result = 'ABORTED'
   error("ABORTED. This build should run on our 'Core' instance in EKS.")
}

// Run tests: RDBASE=$(pwd) ctest --test-dir ${BUILDDIR}
pipeline {

    agent { label 'compound-worker' }

    environment {
        BUILDDIR = "${pwd(tmp: true)}/build"
        PG_VERSION = "12"
    }

    stages {

        stage('RDKit') {
            agent {
                dockerfile {
                    additionalBuildArgs  "--build-arg JAVA_VERSION=17 --build-arg PG_VERSION_MAJOR=${env.PG_VERSION}"
                    dir 'Scripts'
                    filename 'RDKitBuilder.Dockerfile'
                    label 'compound-worker'
                    reuseNode true
                }
            }

            environment {
                BOOST_VERSION = "1.80.0"
                RDKIT_INSTALL_PREFIX="${pwd(tmp: true)}/rdkit"
            }

            stages{
                stage("RDKit: dependencies") {
                    steps {
                        sh 'make -f Scripts/Makefile.strateos boost'
                    }
                }

                stage("RDKit: libraries") {
                    steps {
                        sh 'make -f Scripts/Makefile.strateos rdkit-java rdkit-pgsql-deb'
                    }
                    post {
                        failure {
                            // Show CMake output files on error
                            sh 'find ${BUILDDIR} -name CMakeOutput.log -printf "\n====> CMAKE OUTPUT: %P\n" -exec cat {} +'
                        }
                    }
                }

                stage('RDKit: Publishing') {
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

        stage('Postgresql') {

            environment {
                AWS_DEFAULT_REGION = "us-west-2"
                PGKIT_IMAGE = "742073802618.dkr.ecr.us-west-2.amazonaws.com/strateos/kupsilla/postgresql-rdkit:latest"
            }

            options { skipDefaultCheckout() }

            stages{
                stage("Postgresql: image") {
                    steps {
                        sh '''
                        docker build --rm --build-arg PG_VERSION_MAJOR=${PG_VERSION} \
                                     --tag "${PGKIT_IMAGE}" \
	                                 --file Scripts/Postgres-RDKit.Dockerfile \
                                     "${BUILDDIR}/rdkit"
                        '''
                    }
                }
                stage("Postgresql: publishing") {
                    steps {
                        sh 'aws ecr get-login --no-include-email | sh'
                        sh 'docker push "${PGKIT_IMAGE}"'
                    }
                }
            }
        }
    }
}
