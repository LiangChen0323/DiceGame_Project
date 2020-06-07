pipeline{
    agent any
    stages{
        stage("Terraform Init"){
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
    }
}