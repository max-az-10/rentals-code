pipeline {

        agent any

        environment {
                SONAR_SCANNER_HOME = tool 'SonarQubeScanner'
                IMAGE_TAG = 'latest'
                ECR_REPO = 'rentals-repo'
                ECR_REGISTRY = '381492139836.dkr.ecr.us-west-2.amazonaws.com'
                TRIVY_IMAGE = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
                ECS_CLUSTER = 'rentals-cluster'
                ECS_SERVICE = 'rentals-service'
                ECS_TASK_DEFINITION = 'rentals-taskdef'
        }

        stages {

                stage('Checkout Git') {
                        steps {
                        	git branch: 'main', changelog: false, credentialsId: 'Git-cred', poll: false, url: 'https://github.com/max-az-10/rentals-code.git'
			}
                }

                stage('SonarQube Analysis') {
                        steps {
                                withCredentials([string(credentialsId: 'Sonar-Token', variable: 'SONAR_TOKEN')]) {
                                        withSonarQubeEnv('SonarQube') {
                                                sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner"
                                        }
                                } }
                }

                stage('Login & Build image') {
                        steps {
                                withCredentials([usernamePassword(credentialsId: 'Aws-cred2', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                                        script {
                                                sh """
                                                        aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                                                        docker build -t ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG} .
                                                """
                                        }
                                }
                        }
                }
          
                stage('Trivy scan') {
                        steps {
                                withCredentials([usernamePassword(credentialsId: 'Aws-cred2', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                                        script {
                                                sh "trivy image --severity HIGH,MEDIUM --format table -o trivy-report.html ${TRIVY_IMAGE}"
                                        }
                                }
                        }
                }

                stage('Push to ECR') {
                        steps {
                                withCredentials([usernamePassword(credentialsId: 'Aws-cred2', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                                        script {
                                                sh """
                                                        docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                                                """
                                        }
                                }
                        }
                }

                stage('Update service in ECS') {
                        steps {
                                withCredentials([usernamePassword(credentialsId: 'Aws-cred2', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                                        script {
                                                sh "aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --task-definition ${ECS_TASK_DEFINITION} --force-new-deployment"
                                        }
                                }
                        }
                }
        }
}
 
