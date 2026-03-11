def call(String imageName, String imageTag, String credentials) {
    sh "docker build -t ${imageName}:${imageTag} ."
    sh "docker tag ${imageName}:${imageTag} ${imageName}:latest"
    sh "echo ${credentials.split(':')[1]} | docker login -u ${credentials.split(':')[0]} --password-stdin"
    sh "docker push ${imageName}:${imageTag}"
    sh "docker push ${imageName}:latest"
}