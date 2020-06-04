pipeline{
    agent any
    stages{
        stage("Build") {
          steps {
              echo "========Downloading latest Dicegame source code========"
              sh "git clone https://github.com/LiangChen0323/DiceGame_Project.git dist/tmp/"
          }
        }
        stage("Create S3 bucket and Cloudfront"){
          when {
            branch "S3"
          }
            steps{
                echo "========Creating S3 and Cloudfront========"

            }
            post{
                always{
                    echo "========always========"
                }
                success{
                    echo "========A executed successfully========"
                }
                failure{
                    echo "========A execution failed========"
                }
            }
        }
        stage("Deploy Dicegame source code to S3 bucket"){
            steps{
                echo "====++++Deploying Dicegame to S3++++===="
                withAWS(region:'eu-west-2', credentials: "AWScredentials") {
                  s3Delete(bucket:"testing-bucket-liangchen323",path:"LiangChen_CV.pdf")
                  s3Upload(bucket:"testing-bucket-liangchen323",path:"dist/tmp/",includePathPattern:'**/*')
                }
            }
            post{
                always{
                    echo "====++++always++++===="
                }
                success{
                    echo "====++++A executed successfully++++===="
                }
                failure{
                    echo "====++++A execution failed++++===="
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