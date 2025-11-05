pipeline {
    agent any

    environment {
        // إعداد المتغيرات العامة
        DOCKER_IMAGE = "lenaadel/jenkins-app"
        GIT_REPO = "https://github.com/AFAFADEL/jenkins_task.git"
    }

    stages {

        stage('Clone Repository') {
            steps {
                echo "🔹 Cloning repository..."
                git branch: 'main', url: "${GIT_REPO}"

                // للتأكد من وجود pom.xml
                sh 'echo "--- Project structure ---"'
                sh 'ls -R'
            }
        }

        stage('Build with Maven') {
            steps {
                echo "🔹 Building project with Maven..."
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🔹 Building Docker image..."
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                echo "🔹 Pushing image to DockerHub..."
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Update Deployment File') {
            steps {
                echo "🔹 Updating deployment file with new image..."
                sh """
                sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g' deployment.yaml
                cat deployment.yaml
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "🔹 Deploying to Kubernetes..."
                sh 'kubectl apply -f deployment.yaml --kubeconfig=/var/lib/jenkins/config'
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs above."
        }
        always {
            echo "📦 Pipeline finished."
        }
    }
}


