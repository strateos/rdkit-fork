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