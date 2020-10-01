serviceAccount:
  create: false
  name: ${product_name}-jenkins
master:
  additionalPlugins: [${plugins}]
  JCasC:
    enabled: true
    configScripts:
      welcome-message: |
        jenkins:
          systemMessage: Welcome to our CI\CD server. This is the Jenkins instance for the product ${product_name}. This Jenkins is configured and managed 'as code' from https://github.com/liatrio/lead-terraform.
  sidecars:
    configAutoReload:
      enabled: true
      label: jenkins_config
      resources:
        requests:
          cpu: 100m
          memory: 64Mi
        limits:
          cpu: 800m
          memory: 256Mi
