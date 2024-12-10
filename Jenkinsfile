pipeline {
    agent any
    
    tools{
        maven "maven3"
    }

    stages {
        stage("Clone code from GitHub") {
            steps {
                script {
                    git branch: 'main',  url: 'https://github.com/PSSahana/SuperApp.git';
                }
            }
        }
        stage('BUILD'){
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }
        stage('test') {
            steps {
                sh 'mvn test'
            }
        }
		stage('SonarQube Analysis') {
            steps{
                script{
                withSonarQubeEnv(credentialsId:'sonar-token') {
                    sh "mvn clean verify sonar:sonar -Dsonar.projectKey=Vitusa -Dsonar.projectName='Vitusa'"
                }
                }
            }    
        }
        stage('Quality Gate Status Check'){
            steps{
                script{
                    withSonarQubeEnv(credentialsId:'sonar-token') { 
                        sh "mvn sonar:sonar"
                    }
                    timeout(time: 10 , unit: 'MINUTES') {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                       error "Pipeline aborted due to quality gate failure: ${qg.status}"
                    }
                    }
		            sh "mvn clean install"
                }
     
            } 
            
            
        }
         stage("Publish to Nexus Repository Manager") {
            steps{
                    nexusArtifactUploader artifacts: [[artifactId: 'helloworld', 
                    classifier: '', 
                    file: '/var/lib/jenkins/workspace/Demo/target/helloworld-1.0-SNAPSHOT.war', 
                    type: 'war']], 
                    credentialsId: 'nexus',
                    groupId: 'example.demo',
                    nexusUrl: '172.31.43.255:8081', 
                    nexusVersion: 'nexus3',
                    protocol: 'http', 
                    repository: 'test', 
                    version: '1.0-SNAPSHOT'

               
            }
    
             
         }
        stage('Deploy tomcat') {
            steps{
                script{
                    sshagent(['ssh']) {
                    sh 'scp -o StrictHostKeyChecking=no /var/lib/jenkins/workspace/Demo/target/*.war ubuntu@172.31.22.185:/opt/tomcat/webapps/'
                    }
                }
            }
            
        
   	    }
    }
}