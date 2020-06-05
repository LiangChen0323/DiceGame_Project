pipeline{
    agent any
    stages{
        stage("Build") {
          steps {
              echo "========Downloading latest Dicegame source code========"
              // sh "rm -rf s3"
              // sh "git clone --single-branch --branch S3 https://github.com/LiangChen0323/DiceGame_Project.git s3/"
          }
        }
        stage("Terraform Init - Create S3 bucket and Cloudfront"){
          // when {
          //   branch "S3"
          // }
            steps{
                sh "/bin/terraform/terraform init"
            }
        }
        stage("Terraform Plan"){
            steps{
                sh "/bin/terraform/terraform plan"
            }
        }
        stage("Terraform Apply"){
            steps{
                input "Apply?"
                sh "/bin/terraform/terraform apply -auto-approve"
            }
        }
        stage("Deploy Dicegame source code to S3 bucket"){
            steps{
                echo "====++++Deploying Dicegame to S3++++===="
                withAWS(region:'eu-west-2', credentials: "AWScredentials") {
                  s3Delete(bucket:"testing-bucket-liangchen323-123",path:"/*")
                  s3Upload(bucket:"testing-bucket-liangchen323-123",file:"DiceGame")
                }
            }
        }
    }
    post{
        always{
            echo "========always========"
        }
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}