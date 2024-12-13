Create 4 ubuntu instances with t2.medium instance type
create security group for jenkins with ssh -22 and custom TCP port 8080 allowed
create security group for sonarcube with ssh-22 Custom TCP 9000 and all-traffic from jenkins sg
create security group for nexus server with ssh-22 Custom TCP 8081 and all-traffic from jenkins sg
create security group for tomcat server with ssh-22 Custom TCP 8080 and all-traffic from jenkins sg

--------------Installation of jenkins -----------
https://www.jenkins.io/doc/book/installing/linux/ 
1.follow the steps given in above url and use the long term release for jenkins
2.pre-requisite for Jenkins is Java. so install the JDK 11 from the steps given with same link above
3.once installation completes, access the jenkins with its public ip:8080 
4.It asks for initial admin password, get it from the path and write.
5.Then login with admin and install all suggested plugins.
6. Install the git in the jenkins server with below commands
   sudo apt update -y
   sudo apt install git
7. Install the maven with specific version use the below link
   https://linux.how2shout.com/how-to-install-maven-on-ubuntu-24-04-lts-and-other-versions/
   also use the maven.sh in the current directory
   
----------------Installation of Nexus -------
Use the bash script nexus.sh in the current directory, while creating the ec2 instance add this in userdata place.
Check for latest version before using the wget command to download the neux .tar file. If required the script file to latest version.
once logged into nexus console, change the admin password.
-go to browse
-repositories
-create new repository 
- under maven2 hosted create an repository. 
-give an name
-select version policy as mixed
-rest all the option are default 
-click on create


------------Installation of Sonarqube -----------
(follow the below website for installing sonarqube)
https://zacs-tech.com/how-to-install-sonarqube-using-docker-compose-on-ubuntu-22-04/

follow the steps and install the sonarqube as docker conatiner and everytime need start the conatiner when you login to server.
Once installed, login to console with admin and chenge password for admin if requested.
Go to my accounnt in the top right corner, go to security tab
under tokens, click on generate token with classic option. 
copy the tokcen immediately and save it for integrating with jenkins.

-------------Installation of Tomcat 10 ---------
tomcat 9 installation(Extra part)
https://linuxconfig.org/ubuntu-20-04-tomcat-installation

tomcat 10 installation
https://linuxize.com/post/how-to-install-tomcat-10-on-ubuntu-22-04/
https://docs.vultr.com/install-apache-tomcat-on-ubuntu-20-04-39123?utm_source=google-apac&utm_medium=paidmedia&obility_id=16876059738&utm_adgroup=&utm_campaign=&utm_term=&utm_content=&gclid=EAIaIQobChMIgMiIs_D89wIV-dpMAh0xgQ3dEAAYASAAEgLWpfD_BwE
use these links and install tomcat

-------Create the passwordless authentication for jenkins with all the other servers ----
1. Connect Jenkins server
2. generate ssh key  using the below  cmd 
     ssh-keygen 
3. select the default options for the key genaration
4. locate the id_rsa.pub and copy the contents using cat cmd paste it in all the other 3 servers under below path
   /home/ubuntu/.ssh/authorozed_keys 
   
   
-------Installlation of required plugins for jenkins to integrate with other servers --
login Jenkins UI page
go to manage jenkins -plugins - available plugins
select below plugins and install without restart
1. Build pipeline
2. pipeline stage view
3.Sonarqube scanner plugin
4.nexus artifact uploader
5.pipeline utility steps
6.SSh-Agent


--Integrating maven with jenkins---
go to manage jenkins- global tool configuration--add maven
give name for maven as maven3
also give maven home --as /opt/maven/


-----Integrating Sonarqube with jenkins ---
set the  environment variable for sonarqube
1.go to manage jenkins-configure system- sonarqube server
2.check the environment variable checkbox
3 give a name for variable and give the private ip:9000 of the sonarqube server
4.also add the generated token in sonarqube console as secret text in credentials manger of jenkins
save the configuration

-----nexus integration with jenkins---
under pipeline syntax --select the nexusArtifactUploader 

 nexusArtifactUploader artifacts: [[artifactId: 'helloworld', 
                    classifier: '', 
                    file: '/var/lib/jenkins/.m2/repository/example/demo/helloworld/1.0-SNAPSHOT/helloworld-1.0-SNAPSHOT.war', 
                    type: 'war']], 
                    credentialsId: 'nexus',
                    groupId: 'example.demo',
                    nexusUrl: '172.31.43.255:8081', 
                    nexusVersion: 'nexus3',
                    protocol: 'http', 
                    repository: 'test', 
                    version: '1.0-SNAPSHOT'
					
Fill the detils from pom.xml
add the credentials of nexus under add credentials tab- select username and password 
given nexus console login credentials here.

------create an pipeline job------

under pipline section select pipeline script from SCM
give the github url and give credentialsif its having and give scriptfile as Jenkisfile
save the job and run

jenkins file- explaination
it has 6 stages

Stage 1--It is to download the code from the git hub repository
Stage 2--maven clean install -DskipTests it will skip the testing phase in maven clean life cycle and gernates an artifact
stage 3-Here it is gloing to do the unit test by using mvn test command
stage 4-quality gate check for static code analysis, here we are using the environment variable that we have given during configuration
	maven is having the sonar plugin which has sonar goal to check for quality of code	
	mvn sonar:sonar is used
stage 5--in this stage we are copying the generated artifactinto nexus repository. for generating the code, make use of syntax generator
	select the nexus artifact uploader option fill the details as per your configuaration generte the code, use it in pipeline
stage 6--in this stage we are copying the artifact to tomcat server using sshagent
	 sshagent(['tomcat-deploy']) {
                    sh 'scp -o StrictHostKeyChecking=no /var/lib/jenkins/workspace/latest/webapp/target/*.war ubuntu@10.0.10.19:/opt/tomcat/webapps/'
                    }
					

got ssh-agent add credentials using secret text and add .pem file conect as secret.
also change the file permission in tomcat for webapps/ folder
sudo chown ubuntu:ubuntu /opt/tomcat/webapps/



