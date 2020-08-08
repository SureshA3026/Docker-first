node
{
    def buildNumber = BUILD_NUMBER
    stage("Git Clone") 
    {
        git url:"https://github.com/SureshA3026/java-web-app-docker.git", branch:'master'
    }
    stage("BuildWar")
    {
        def mavenHome= tool name: "Maven3.6.3"
        
        sh "${mavenHome}/bin/mvn clean package"
    }
    stage("BuildDockerImage")
    
    {
        sh "docker build -t suresha3026/java-web-app-docker:${buildNumber} ."
    }
    
    stage("DockerLogin And Push")
    {
        withCredentials([string(credentialsId: 'Docker_hub', variable: 'Docker_hub')]) 
        {
        sh "docker login -u suresha3026 -p ${Docker_hub}"
        }

        sh "docker push suresha3026/java-web-app-docker:${buildNumber}"
}
stage("DeployAppIntoDcokerDeploymentServer")
{
sshagent(['Docker_Deploy'])
{
    sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.43.126 docker rm -f javawebappcontainer || true"
    
    sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.43.126 docker run -d -p 8080:8080 --name javawebappcontainer suresha3026/java-web-app-docker:${buildNumber}"
}
}
}
