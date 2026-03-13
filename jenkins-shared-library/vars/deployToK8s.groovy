def call(String serviceName, String imageName, String imageTag, String namespace = 'dev') {
    withCredentials([usernamePassword(
        credentialsId: 'github-credentials',
        usernameVariable: 'GIT_USER',
        passwordVariable: 'GIT_PASS'
    )]) {
        sh """
            rm -rf /tmp/infrastructure
            git clone https://\${GIT_USER}:\${GIT_PASS}@github.com/elizabethronan/devops_infrastructure.git /tmp/infrastructure

            # Apply base manifests except nodeport
            for file in /tmp/infrastructure/kubernetes/base/${serviceName}/*.yaml; do
                if [[ \$file != *"nodeport"* ]] && [[ \$file != *"ingress"* ]]; then
                    sed 's/namespace: dev/namespace: ${namespace}/g' \$file | kubectl apply -f -
                fi
            done

            # Apply environment-specific nodeport
            if [ -f /tmp/infrastructure/kubernetes/${namespace}/${serviceName}-nodeport.yaml ]; then
                kubectl apply -f /tmp/infrastructure/kubernetes/${namespace}/${serviceName}-nodeport.yaml
            fi

            # Update image tag
            kubectl set image deployment/${serviceName} \
                ${serviceName}=${imageName}:${imageTag} \
                -n ${namespace}

            rm -rf /tmp/infrastructure
        """
    }
}