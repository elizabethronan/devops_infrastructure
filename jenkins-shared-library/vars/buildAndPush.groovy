def call(String imageName, String imageTag, String credentialsId) {
    withCredentials([usernamePassword(
        credentialsId: credentialsId,
        usernameVariable: 'DOCKER_USER',
        passwordVariable: 'DOCKER_PASS'
    )]) {
        sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ''' + imageName + ':' + imageTag + '''
            docker push ''' + imageName + ''':latest
        '''
    }
}