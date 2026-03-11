def call(String serviceName, String imageName, String imageTag, String namespace = 'dev') {
    sh "kubectl set image deployment/${serviceName} ${serviceName}=${imageName}:${imageTag} -n ${namespace}"
}