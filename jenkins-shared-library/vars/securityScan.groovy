def call(String target, String type = 'image') {
    if (type == 'fs') {
        sh "trivy fs ${target} --severity HIGH,CRITICAL --exit-code 0"
    } else {
        sh "trivy image --severity HIGH,CRITICAL --exit-code 0 ${target}"
    }
}