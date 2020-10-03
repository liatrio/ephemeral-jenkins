jenkins:
  clouds:
    - kubernetes:
        name: "kubernetes"
        serverUrl: "https://kubernetes.default"
        jenkinsUrl: "http://jenkins:8080"
        jenkinsTunnel: "jenkins-agent:50000"
        connectTimeout: 0
        readTimeout: 0
        containerCapStr: 15
        podRetention: never
        maxRequestsPerHostStr: 32
        waitForPodSec: 600
        templates:
          - name: "agent"
            label: "default-agent"
            nodeUsageMode: NORMAL
            containers:
              - name: "maven"
                image: "maven"
                alwaysPullImage: false
                workingDir: "/home/jenkins/agent"
                command: "/bin/sh -c"
                args: "cat"
                ttyEnabled: true
                resourceRequestCpu: 250m
                resourceLimitCpu: 500m
                resourceRequestMemory: 256Mi
                resourceLimitMemory: 512Mi
              - name: "node"
                image: "node"
                alwaysPullImage: false
                workingDir: "/home/jenkins/agent"
                command: "/bin/sh -c"
                args: "cat"
                ttyEnabled: true
                resourceRequestCpu: 250m
                resourceLimitCpu: 500m
                resourceRequestMemory: 256Mi
                resourceLimitMemory: 512Mi
              - name: "ruby"
                image: "ruby"
                alwaysPullImage: false
                workingDir: "/home/jenkins/agent"
                command: "/bin/sh -c"
                args: "cat"
                ttyEnabled: true
                resourceRequestCpu: 250m
                resourceLimitCpu: 500m
                resourceRequestMemory: 256Mi
                resourceLimitMemory: 512Mi
