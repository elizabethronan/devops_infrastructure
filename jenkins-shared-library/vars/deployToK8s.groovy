def call(String serviceName, String imageName, String imageTag, String namespace = 'dev') {
    sh """
        kubectl create deployment ${serviceName} \
            --image=${imageName}:${imageTag} \
            --namespace=${namespace} \
            --dry-run=client -o yaml | kubectl apply -f -
        kubectl set image deployment/${serviceName} \
            ${serviceName}=${imageName}:${imageTag} \
            -n ${namespace}
    """
}