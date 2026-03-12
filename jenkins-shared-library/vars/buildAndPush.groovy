def call(String imageName, String imageTag, String credentialsId) {
    // Build first
    sh "docker build -t ${imageName}:${imageTag} ."
    sh "docker tag ${imageName}:${imageTag} ${imageName}:latest"
    
    // Then push with same tag
    withCredentials([usernamePassword(
        credentialsId: credentialsId,
        usernameVariable: 'DOCKER_USER',
        passwordVariable: 'DOCKER_PASS'
    )]) {
        sh """
            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
            docker push ${imageName}:${imageTag}
            docker push ${imageName}:latest
        """
    }
}