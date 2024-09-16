#!groovy
@Library("bpldc_lib@jenkinsfile") _

def bpl_tool = new org.bpl.bpl_tools()

pipeline {
    agent any

    environment {
        RAILS_ENV = 'test'
        // RAILS_ENV = 'staging'
    } 

    options {
        ansiColor('xterm')
    }
    
    stages {

        stage('CheckoutCode') {
            steps {
                script {  
                    echo "bpl_tool is ${bpl_tool}"
                    echo "In Jenkinsfile phase: Checkout Source Code" 
                    bpl_tool.CheckoutCode() 
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
                    echo "In Jenkins phase: bundle install "                    
                    bpl_tool.RunBundleInstall() 
                }
            }
        }

        stage ('DB preparation'){
            steps {
                script {  
                    echo "In Jenkins phase: DB preparation " 
                    railsEnv = env.RAILS_ENV                
                    bpl_tool.RunDBpreparation(railsEnv) 
                }
            }
        }

        stage('CI') {
            steps {
                script {  
                    echo "In Jenkins phase: running CI testing "                   
                    bpl_tool.RunCI() 
                }
            }
        }

        stage("Deploy application to target servers") {
            steps {
                script {
                    echo "In Jenkins phase: Capistrano deploying "
                    railsEnv    = env.deploy_env

                    bpl_tool.RunDeployment(railsEnv)                
                }
            }
        }

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
