pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')   // اسم الـ credentials في Jenkins
        DOCKER_IMAGE = "lenaadel/jenkins-app"
        GIT_REPO = "https://github.com/AFAFADEL/jenkins_task.git"
        APP_PATH = "lab30_jenk/Jenkins_App"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Run Unit Tests') {
            steps {
                dir("${APP_PATH}") {
                    sh 'echo "Running unit tests..."'
                    // مثال لو عندك tests فعليًا
                    // sh 'pytest tests/'
                }
            }
        }

        stage('Build Appwith Maven') {
            steps {
                dir("${APP_PATH}") {
                    sh 'mvn clean package'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${APP_PATH}") {
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Delete Local Image') {
            steps {
                sh "docker rmi ${DOCKER_IMAGE}:${BUILD_NUMBER} || true"
            }
        }

        stage('Update Deployment File') {
            steps {
                dir("${APP_PATH}") {
                    sh """
                    sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g' deployment.yaml
                    cat deployment.yaml
                    """
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                dir("${APP_PATH}") {
                    sh 'kubectl apply -f deployment.yaml --kubeconfig=/var/lib/jenkins/config'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
