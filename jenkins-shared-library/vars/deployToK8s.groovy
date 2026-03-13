def call(String serviceName, String imageName, String imageTag, String namespace = 'dev') {
    withCredentials([usernamePassword(
        credentialsId: 'github-credentials',
        usernameVariable: 'GIT_USER',
        passwordVariable: 'GIT_PASS'
    )]) {
        sh """
            rm -rf /tmp/infrastructure
            git clone https://\${GIT_USER}:\${GIT_PASS}@github.com/elizabethronan/devops_infrastructure.git /tmp/infrastructure
            
            # Apply all base manifests with correct namespace
            for file in /tmp/infrastructure/kubernetes/base/${serviceName}/*.yaml; do
                sed 's/namespace: dev/namespace: ${namespace}/g' \$file | kubectl apply -f -
            done
            
            # Update image tag
            kubectl set image deployment/${serviceName} \
                ${serviceName}=${imageName}:${imageTag} \
                -n ${namespace}
                
            rm -rf /tmp/infrastructure
        """
    }
}