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
                sh "terraform init ./terraform -input=false"
            }
        }
        stage("Terraform Plan"){
            steps{
                sh "terraform plan ./terraform -out=tfplan -input=false -var-file='dev.tfvars'"
            }
        }
        stage("Terraform Apply"){
            steps{
                input "Apply Plan"
                sh "terraform apply ./terraform  --input=false tfplan"
            }
        }
        stage("Deploy Dicegame source code to S3 bucket"){
            steps{
                echo "====++++Deploying Dicegame to S3++++===="
                withAWS(region:'eu-west-2', credentials: "AWScredentials") {
                  s3Delete(bucket:"testing-bucket-liangchen323",path:"/*")
                  s3Upload(bucket:"testing-bucket-liangchen323",file:"DiceGame")
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