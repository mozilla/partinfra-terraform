node("master") {

    stage("Prep") {
        deleteDir() // Clean up the workspace
        checkout scm
        withCredentials([file(credentialsId: 'tfvars', variable: 'tfvars')]) {
            sh "cp $tfvars terraform.tfvars"
        }
        sh "terraform init --get=true"
    }

    stage("Plan") {
        sh "terraform plan -out=plan.out -no-color"
    }

    if (env.BRANCH_NAME == "master") {
        stage("Apply") {
            sh '''
            MSG="A Terraform change is waiting to be applied: ${BUILD_URL}console cc @yalam96 nemo-yiannis"
            SERVER=irc.mozilla.org
            CHANNEL=#communityops
            CHANNEL2=#partinfra
            USER=pequod
            (
            echo NICK $USER
            echo USER $USER 8 * : $USER
            sleep 1
            echo "JOIN $CHANNEL"
            sleep 1
            echo "PRIVMSG $CHANNEL" :$MSG
            sleep 1
            echo "JOIN $CHANNEL2"
            sleep 1
            echo "PRIVMSG $CHANNEL2" :$MSG
            sleep 1
            echo QUIT
            ) | nc $SERVER 6667
            '''
            input 'Do you want to apply this plan?'
            sh "terraform apply -no-color plan.out"
        }
    }
}
