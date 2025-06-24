#!groovy
@Library("bpldc_jenkinsfile@main") _
// Above jenkinsfile shared library can be found here: 
// https://github.com/boston-library/jenkinsfile_shared_library

def bpl_tool = new org.bpl.bpl_tools()

pipeline {
    agent {
        node {
            label 'BPL_DAN'
            customWorkspace "/var/lib/jenkins/workspace/${env.JOB_NAME.replace('/', '-')}"
        }
    }


                // environment {
                //     RAILS_ENV = 'test'
                //     // RAILS_ENV = 'staging'
                // } 

    options {
        ansiColor('xterm')
    }
    
    stages {

        stage('GetCode') {
            steps {
                script {  
                    echo "bpl_tool is ${bpl_tool}"
                    echo "In Jenkinsfile phase: Checkout Source Code" 

                    def srcType    = 'Git' 
                    def branchName = params.BRANCH_NAME
                    def gitHttpURL = 'https://github.com/boston-library/ark-manager.git'
                    def credentialsId = 'bplwebmaster'
                    echo "srcType is ${srcType}"
                    echo "branchName is ${branchName}"
                    echo "gitHttpURL is ${gitHttpURL}"
                    echo "credentialsId is ${credentialsId}"

                    bpl_tool.GetCode(srcType,branchName,gitHttpURL,credentialsId)
                }
            }
        }
        
        stage('Preparation') {
            steps {
                script {  
                    echo "In Jenkinsfile phase: Preparation at the very begining"                   
                    bpl_tool.RunPreparation()
                }                
            }
        }

        stage ('Install new ruby'){
            steps {
                script {  
                    echo "In Jenkins phase: Install new ruby" 
                    def EXPECTED_RUBY = sh(returnStdout: true, script: 'cat .ruby-version')
                    // EXPECTED_RUBY = '3.2.5'
                    echo "EXPECTED_RUBY is $EXPECTED_RUBY"                    
                    bpl_tool.InstallNewRuby(EXPECTED_RUBY) 
                }
            }
        }

        stage ('Bundle Install'){
            steps {
                script {  
                    echo "\033[42m\033[97D In Jenkins phase: bundle install \033[0m"                    
                    bpl_tool.RunBundleInstall() 
                }
            }
        }

        stage('Create Docker Image'){
            steps {
                script {
                    // staging/production doesn't need to create docker image
                    if ( (env.DEPLOY_ENV != 'staging') &&  ( env.DEPLOY_ENV != 'production')) {
                        echo "creating docker image"
                                // bpl_tool.CreateBpldcAuthorityDockerImages()
                        bpl_tool.CreateDockerImage('ark-manager')
                    }else{
                        echo "No need create docker images. Skipping... "
                    }
                }
            }
        }

        // stage("Deploy application to target servers") {
        //     steps {
        //         script {
        //             echo "In Jenkins phase: Capistrano deploying "
        //             railsEnv    = env.deploy_env

        //             bpl_tool.RunDeployment(railsEnv)                
        //         }
        //     }
        // }

    }

    post {
        failure {
            emailext (
                subject: "Build failed in Jenkins: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """<p>Build failed in Jenkins:</p>
                        <p>Job: ${env.JOB_NAME}</p>
                        <p>Build Number: ${env.BUILD_NUMBER}</p>
                        <p>Build URL: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }

}    
