1. Setup Jenkins
```
find /usr/lib/jvm/java-1.8* | head -n 3
vim ~/.bash_profile -> add java path
java -version -> java-1.8+
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins
systemctl start jenkins
systemctl enable jenkins
// Get Jenkins password
cat /var/lib/jenkins/secrets/initialAdminPassword
Install suggest plugins
Create user
Create a freestyle project named: Dicegame
Source Code Management: Git
Repository URL: https://github.com/LiangChen0323/DiceGame_Project
Create a Personal access token on Github for webhook use
Add Personal access token to Jenkins configuration -> GitHub -> GitHub server -> Add (secret text)-> tick Manage hooks
Check github repo: weekhook
```

2. Terraform
```
```

3. Ansible
```
```
