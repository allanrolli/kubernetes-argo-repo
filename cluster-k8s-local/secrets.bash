kubectl create secret docker-registry <secret-name> \
      --namespace <namespace> \
      --docker-server=<registry-url> \
      --docker-username=<username> \
      --docker-password=<password-or-token> 