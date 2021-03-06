# micro-env-publish-app
## 1. Git
```bash
* git init

* git add README.md

* git commit -m "first commit"

* git branch -M main

* git remote add origin https://github.com/bomc/spp.git

* git push -u origin main
```

## 2. Build, Run and Deploy on Kubernetes

```bash
# in /publish
gradle jibDockerBuild
```

## 3. Swagger OpenAPI
local:
* http://localhost:8081/api-docs

* http://localhost:8081/webjars/swagger-ui/index.html?configUrl=/api-docs/swagger-config#/

minikube:

```bash
minikube service list
```

e.g. output:

| NAMESPACE | NAME | TARGET PORT | URL |
| --- | --- | --- | --- |
| bomc-consumer        | consumer-service                 | No node port                |
| bomc-publish         | publish-service-nodeport-ingress | http://192.168.99.104:30194 |

Invoke with given address from above:

* http://192.168.99.104:30194/webjars/swagger-ui/index.html?configUrl=/api-docs/swagger-config#/

## 4. REST urls

* curl -X POST "http://10.111.50.176/bomc/api/metadata/annotation-validation" -H  "accept: application/json" -H  "X-B3-TraceId: 82f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 11e3ac9a4f6e3b90" -H  "Content-Type: application/json" -d "{\"id\":\"42\",\"name\":\"bomc\"}"

* curl -X POST "http://localhost:8081/api/metadata/annotation-validation" -H  "accept: application/json" -H  "X-B3-TraceId: 82f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 11e3ac9a4f6e3b90" -H  "Content-Type: application/json" -d "{\"id\":\"42\",\"name\":\"bomc\"}"


* curl -X GET "http://localhost:8081/api/metadata/" -H  "accept: application/json" -H  "X-B3-TraceId: 70f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 15e3ac9a4f6e3b90"


* curl -X GET "http://localhost:8081/api/metadata/42" -H  "accept: application/json" -H  "X-B3-TraceId: 60f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 05e3ac9a4f6e3b90"


* curl -X PUT "http://localhost:8081/api/metadata/" -H  "accept: */*" -H  "X-B3-TraceId: 80f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 45e3ac9a4f6e3b90" -H  "Content-Type: application/json" -d "{\"id\":\"42\",\"name\":\"test\"}"


* curl -X DELETE "http://localhost:8081/api/metadata/42" -H  "accept: application/json" -H  "X-B3-TraceId: 70f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 25e3ac9a4f6e3b90"

## 5. Actuator
On local machine:
* curl -v GET http://localhost:8082/actuator/info

If running with nodeport:
curl -v GET http://192.168.99.104:30194/actuator/info | jq

If running with ingress:
* curl -v GET http://bomc.ingress.org/bomc/actuator/info | jq

## 6. Minikube - docker
```bash
# Install with chocolatery, version is optional.
choco install minikube --version 1.19.0

minikube start

minikube start --vm-driver=virtualbox --cpus 3 --memory 10240 --disk-size=25GB

minikube addons list

minikube addons enable ambassador

minikube addons enable metrics-server

# Using 'top' after enabling metrics-server. 
kubectl top pods -n bomc-consumer

minikube addons enable ingress

minikube ssh -- cat /etc/hosts
```

### 6.1 Minikube internal registry
```bash
# Used docker registry HTTP API V2
# https://docs.docker.com/registry/spec/api/
curl http://192.168.99.145:5000/v2/_catalog

curl -X GET http://192.168.99.145:5000/v2/bomc/consumer/tags/list

curl -X GET http://192.168.99.145:5000/v2/containers/json
```

### 6.2 GIT bash
```bash
# Add this line to .bash_profile if you want to use minikube's daemon by default (or if you do not want to set this every time you open a new terminal).
eval $(minikube docker-env)

eval $(docker-machine env -u)
```

### 6.3 Windows cmd
```bash
# List env variables
minikube docker-env

@FOR /f "tokens=*" %i IN ('minikube -p minikube docker-env') DO @%i
```

```bash
minikube ssh
```

```bash
docker ps
```

### 6.4 Delete Minikube (Windows)
```bash
minikube stop & REM stops the VM
```

```bash
minikube delete & REM deleted the VM
```

Then delete the .minikube and .kube directories usually under:

`C:\users\{user}\.minikube`

and

`C:\users\{user}\.kube`

Or if you are using chocolatey:

```bash
C:\ProgramData\chocolatey\bin\minikube stop
C:\ProgramData\chocolatey\bin\minikube delete
choco uninstall minikube
choco uninstall kubectl
```

Then delete the .minikube and .kube directories, see above.

### 6.5 Docker commands
####Removing untagged images
```bash
docker image rm $(docker images | grep "^<none>" | awk "{print $3}")
```

####Remove all stopped containers.
```bash
docker container rm $(docker ps -a -q)
```

## 7. Tools
### 7.1 Gradle
```bash
gradle jibDockerBuild
```

```bash
gradle build
```

###7.2 Switch build to use Gradle 7.2 by updating the wrapper:

```bash
./gradlew wrapper --gradle-version=7.2
```

### 7.2 Dive
A tool for exploring a docker image, layer contents, and discovering ways to shrink the size of your Docker/OCI image.

```bash
# NOTE: On windows run it in cmd box.
dive localhost:5000/bomc/consumer:v.1.0.0-1-g5eb028a
```

### 7.3 Versioning
*Version v.1.0.0-1-g5eb028a means:*

v.1.0.0 -> last tag

1 -> number of commits since the last tag

g5eb028a -> hash of the last commit

### 7.4 Simple deployment to Minikube with kustomize

> From /deployment directory

```bash
# check kubernetes resources with kustomize (namespace, service deployment).
\deployment\kustomize build

# The -k option, which will direct kubectl to process the kustomization file.
kubectl apply -k .
```

### 7.5 Check deployment with kubectl - namespace, service and deployment
```bash
kubectl get pods -n bomc -o wide
kubectl get pods -n bomc -o yaml
kubectl describe pod consumer-66dc5c8d7d-ccs2x -n bomc

kubectl get deployments -n bomc
kubectl describe deployment consumer -n bomc

# Access the Init Container status programmatically by reading the status.initContainerStatuses field on the Pod Spec:
kubectl get pod nginx -n bomc --template '{{.status.initContainerStatuses}}'

# Accessing logs from Init Containers 
# Pass the Init Container name along with the Pod name to access its logs.
kubectl logs <pod-name> -c <init-container-2> -n <namespace>
```

### 7.6 Call application via NodePort
NodePort will use the cluster IP and expose?s the service via a static port.

```bash
# Expose consumer service
# 1. Read deployment name (-> 'Name') from deployment resource:
kubectl describe deployment consumer -n bomc
# 2.Expose port with expose command:
#   ?type=NodePort makes the Service available from outside of the cluster. It will be available at <NodeIP>:<NodePort>
#   The command creates a service object that exposes the deployment 'consumer'
kubectl expose deployment consumer -n bomc --type=NodePort --name=consumer-nodeport

minikube service list

# Shows the address of the service.
minikube service consumer -n bomc --url

# This command will start the default browser, opening <NodeIP>:<NodePort>.
minikube service consumer -n bomc
```

| NAMESPACE | NAME | TARGET PORT | URL |
| --- | --- | --- | --- |
| bomc | consumer | - | http://192.168.99.102:31633 |

* Opening service bomc/consumer in default browser...

```bash
# Invoke application:
curl -X POST "http://192.168.99.102:31633/api/metadata/annotation-validation" -H  "accept: */*" -H  "X-B3-TraceId: 82f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 11e3ac9a4f6e3b90" -H  "Content-Type: application/json" -d "{\"id\":\"42\",\"name\":\"bomc\"}"

# or in Browser OpenAPI:

http://192.168.99.100:30117/webjars/swagger-ui/index.html?configUrl=/api-docs/swagger-config
```

### 7.7 Open shell in running container
```bash
kubectl exec -it consumer-66dc5c8d7d-ccs2x -n bomc -- sh

kubectl exec -it consumer-66dc5c8d7d-ccs2x -n bomc bash
```

> NOTE: GIT bash on windows:
>
> ```bash
> winpty kubectl exec -it consumer-66dc5c8d7d-ccs2x -n bomc -- sh
> ```

### 7.8 Check if service is available and correct configured
Services are abstract interfaces (host + port) to a workload that may consist of several pods.

#### Step 1: Check if the Service exists
```bash
kubectl get svc -n bomc
```

#### Step 2: Test Your Service from inside a pod.
```bash
#works for http services
wget <servicename>:<httpport>

#Confirm there is a DNS entry for the service!
nslookup <servicename>
```

Alternatively, forward port local machine and test locally.

```bash
kubectl port-forward <service_name> 8000:8080 -n bomc
```

Address the service as localhost:8000.

#### Step 3: Check if the Service Is Actually Targeting Relevant Pods
K8s services route inbound traffic to one of the pods, based on the label selector. Traffic is routed to targeted pods by their IP.

```bash
kubectl get pods -l app=consumer -n bomc
```

So, check if the service is bound to those pods.

```bash
kubectl describe service <service-name> | grep Endpoints
```

The IPs of all the pods related to the workload listed. If not, go to step 4.

#### Step 4: Check Pod Labels
Make sure the selector in the K8s service matches the pods? labels!

```bash
kubectl get pods --show-labels -n bomc

kubectl describe svc <service_name> -n bomc
```

#### Step 5: Confirm That Service Ports Match The Pod
Finally, make sure that the code in the pods actually listens to the targetPort that is specified for the service.

### 7.9 Adding Deployment Strategy
```yaml
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

This tell kubernetes how to replace old Pods by new ones. In this case the RollingUpdate (`rollingUpdate`) is used. The `maxSurge` of 1 specifies maximum number of Pods that can be created over the desired number of Pods `1` in this case. The `maxUnavailable` specifies the maximum number of Pods that can be unavailable during the update process `0` in this case.

## 8. Kubectl commands
```bash
# Get pods with a specific label 'app=consumer' 
kubectl get pods -l app=consumer -n bomc
# Get all pods with a specific name space and label 'app=consumer' 
kubectl get pods --all-namespaces -l app=consumer
# Get all services from all namespaces sorted by name
kubectl get services --all-namespaces --sort-by=.metadata.name -o wide
# List all container images in all namespaces
kubectl get pods --all-namespaces -o jsonpath="{..image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c
# List environment variables from pod.
kubectl exec publisher-685c77dfc7-qs2mm -n bomc-publish -it -- env 
```

```bash
# Get pods with a specific label 'app=consumer' 
kubectl get pods -l app=consumer -o go-template='{{range .items}}{{.status.podIP}}{{"\n"}}{{end}}' -n bomc
```

```bash
kubectl get pod publisher-597764857f-vfpn8 -n bomc-publish -o json

kubectl get pod publisher-597764857f-vfpn8 -n bomc-publish -o json | jq '.status.hostIP' -r
kubectl get pod publisher-597764857f-vfpn8 -n bomc-publish -o json | jq '.status.podIP' -r
```

```bash
# Get json with jq
kubectl get service -o json| jq -r .items[0].metadata.annotations
```

```bash
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
```

## 9. Microservice intercommunication inside same namespace via k8s services
The 'publish'-application invokes the 'consumer'-application via REST-request.

 publish - springboot/webclient---------->| REST-Call |---> consumer - springboot/rest-endpoint
   
#### a. Get environment variables inside consumer the pod.
Whenever a pod is created, k8s injects some env variables into the pods env. These variables can be used by containers to interact with other containers. So when a service is created, the address of the service will be injected as an env variable to all the pods that run within the *same namespace*.

The k8s conventions are:

{{SERVICE_NAME}}_SERVICE_HOST    # ClusterIP

{{SERVICE_NAME}}_SERVICE_PORT    # Port
 
```bash 
kubectl exec consumer-5d4969c4f5-dflkj -n bomc -- printenv | grep SERVICE

PUBLISH_SERVICE_SERVICE_HOST=10.109.177.190
PUBLISH_SERVICE_SERVICE_PORT_8181_TCP=8181
PUBLISH_SERVICE_SERVICE_PORT=8181
PUBLISH_SERVICE_PORT_8181_TCP=tcp://10.109.177.190:8181
PUBLISH_SERVICE_PORT_8181_TCP_ADDR=10.109.177.190
CONSUMER_SERVICE_SERVICE_HOST=10.102.64.176
CONSUMER_SERVICE_HOST=10.111.175.48
CONSUMER_SERVICE_SERVICE_PORT_8081_TCP=8081
CONSUMER_SERVICE_PORT_8081_TCP_PORT=8081
PUBLISH_SERVICE_HOST=10.97.213.196
PUBLISH_SERVICE_PORT=tcp://10.109.177.190:8181
KUBERNETES_SERVICE_PORT=443
CONSUMER_SERVICE_SERVICE_PORT=8081
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT_HTTPS=443
PUBLISH_SERVICE_PORT_8181_TCP_PROTO=tcp
PUBLISH_SERVICE_PORT_8181_TCP_PORT=8181
CONSUMER_SERVICE_PORT=tcp://10.102.64.176:8081
CONSUMER_SERVICE_PORT_8081_TCP=tcp://10.102.64.176:8081
CONSUMER_SERVICE_PORT_8081_TCP_PROTO=tcp
CONSUMER_SERVICE_PORT_8081_TCP_ADDR=10.102.64.176
```

#### b. Get environment variables from consumer-service
CONSUMER_SERVICE_SERVICE_HOST=10.102.64.176, CONSUMER_SERVICE_SERVICE_PORT=8081

#### c. Extend application property in publish application

```java

...

# Set the rest client base url in 'publish'-application to invoke the 'consumer'-application. 
bomc.web-client.base-url=http://${CONSUMER_SERVICE_SERVICE_HOST}:${CONSUMER_SERVICE_SERVICE_PORT}

...

```

## 10. Microservice intercommunication accross namespaces
K8s doesn't inject environment variables from other namespaces. Using service names like 'consumer-service' are only valid within the same namespace.

### 10.1 Using fully-qualified DNS names
Kubernetes has cluster-aware DNS service like CoreDNS running, so it is possible using fully qualified DNS names starting from cluster.local. Assume the 'consumer'-Application is running in namespace 'bomc-consumer' and has a service 'consumer-service' defined. To address using an URL shown below:

```
# base-url for communication accross different namespaces.
{{SERVICE_NAME}}.{{NAMESPACE_NAME}}.svc.cluster.local:{{PORT (is optional if port is 80)}}
# in application.properties
bomc.web-client.base-url=http://consumer-service.bomc-consumer.svc.cluster.local:8081
```

## 11. Healthcheck
### 11.1 Adding liveness probe
```yaml
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8081
            initialDelaySeconds: 30
            periodSeconds: 30
            failureThreshold: 3
```

This will check to see an HTTP 200 response from the endpoint `/actuator/health` at the deployment port every 30 seconds (`periodSeconds`) after an initial delay (`initialDelaySeconds`) of 30 seconds for a maximum of 3 times (`failureThreshold`) after which it is going to restart the container for which this liveness probe is added.

### 11.2 Adding readiness probe
```yaml
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8081
            initialDelaySeconds: 15
            periodSeconds: 30
            failureThreshold: 3
```

This will check to see an HTTP 200 response from the endpoint `/actuator/health` at the deployment port every 30 seconds (`periodSeconds`) after an initial delay (`initialDelaySeconds`) of 15 seconds for a maximum of 3 times (`failureThreshold`) after which it is going to Pod will be marked container as `Unready` and no traffic will be sent to it for which this readiness probe is added which is the container running the application.

## 12. Requests and limits


## 13. Ingress router
A Kubernetes resource called Ingress is what manages external access to the applications running inside the cluster. With ingress, there are rules defines that tell Kubernetes how to route external traffic to the application.
The Ingress resource on its own is useless. It's a collection of rules and paths, but it needs something to apply these rules to. That "something" is an ingress controller. The ingress controller acts as a gateway and routes the traffic based on the rules defined in the ingress resource.

Exceute the following command to create the ingress controller:

```bash
minikube addons enable ingress
```

### 13.1 Create a service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: publish-service-nodeport-ingress
  labels:
    app: publish
  namespace: bomc-publish
spec:
  selector:
    app: publish
  ports:
  - protocol: TCP
    name: 8181-tcp
    port: 8181
    targetPort: 8181
  type: NodePort
```

### 13.2 Create Ingress Router

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  labels:
    app: publish
  name: publish-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: OVERRIDE_BY_OVERLAYS
      http:
        paths:
          - path: /bomc(/|$)(.*)
            backend:
              serviceName: publish-service-nodeport-ingress
              servicePort: OVERRIDE_BY_OVERLAYS
#
# This rewrite any characters captured by '(.*)' will be assigned to the placeholder '$2',
# which is then used as a parameter in the 'rewrite-target' annotation.
# This will results in the following rewrites:
#
# - 'bomc.ingress.org/bomc' rewrites to 'bomc.ingress.org/'
# - 'bomc.ingress.org/bomc/' rewrites to 'bomc.ingress.org/'
# - 'bomc.ingress.org/bomc/api/metadata' rewrites to 'bomc.ingress.org/api/metdata'
```

NOTE: the value of `type` is *NodePort*.

### 13.2 Check service address
```bash
minikube service publish-service-nodeport-ingress -n bomc-publish-prod --url

http://192.168.99.104:30194
```

> Note: If Minikube is running locally, use `minikube ip` to get the external IP. The IP address displayed within the ingress list will be the internal IP.

### 13.3 Edit host file
on window: C:\Windows\System32\drivers\etc\hosts
add the following line to the hosts file.

```
192.168.99.104 bomc.ingress.org
```

### 13.4 Check if ingress is configured

$ kubectl get ingress -n bomc-publish-prod
NAME              HOSTS              ADDRESS          PORTS   AGE
publish-ingress   bomc.ingress.org   192.168.99.107   80      50m

This sends requests from `bomc.ingress.org` to Minikube:

```bash
# Verify that the Ingress controller is directing traffic with a simple curl.
curl -v -X GET "http://bomc.ingress.org/bomc/api/metadata/" -H  "accept: application/json" -H  "X-B3-TraceId: 70f198ee56343ba864fe8b2a57d3eff7" -H  "X-B3-ParentSpanId: 15e3ac9a4f6e3b90"
```

## 14. ConfigMap
A ConfigMap is a dictionary of configuration settings. This dictionary consists of key-value pairs of strings. Kubernetes provides these values to your containers.

The given ConfigMap:

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: publisher
  namespace: bomc-publish
data:
  application-k8s.properties: |-
    bomc.consumer=http://consumer-service.bomc-consumer.svc.cluster.local:8081
    bomc.github=https://api.github.com
```

### 14.1 ConfigMap with Environment Variables and `envFrom`
Expose with environment variables:

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: publisher
  namespace: bomc-publish
data:
  application-k8s.properties: |-
    bomc.consumer=http://consumer-service.bomc-consumer.svc.cluster.local:8081
    bomc.github=https://api.github.com
```

reference in Kubernetes Deployment:

```YAML
     spec:
       serviceAccountName: publisher-account
       containers:
       env:
         - name: CONSUMER_HOST_ADDRESS
           valueFrom:
             configMapKeyRef:
               name: publisher
               key: bomc.consumer
         - name: GITHUB_HOST_ADDRESS
           valueFrom:
             configMapKeyRef:
               name: publisher
               key: bomc.github
```

or reference with `envFrom`

```YAML
     spec:
       serviceAccountName: publisher-account
       containers:
       envFrom:
       - configMapRef:
           name: publisher
```

Inject in Spring Boot java code:

```JAVA
@Value("${bomc.consumer}")
private String consumerBaseUrl;

@Value("${bomc.github}")
private String githubBaseUrl;
```

### 14.2 ConfigMap with spring boot cloud fabric8
Load application properties from Kubernetes ConfigMaps and Secrets. Reload application properties when a ConfigMap or Secret changes.

Gradle dependencies

```
dependencies {
	implementation 'org.springframework.cloud:spring-cloud-starter-kubernetes-fabric8-config:2.0.1'
	
  ...
  
dependencyManagement {
	imports {
		mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
	}
}
```

Properties setting in bootstrap.properties

```PROPERTIES
###
#
# Set the app name
spring.application.name=publisher

###
#
# Configuration for config-map handling.
spring.cloud.kubernetes.config.sources[0].name=${spring.application.name}
spring.cloud.kubernetes.config.sources[0].namespace=bomc-publish

spring.cloud.kubernetes.reload.enabled=true
spring.cloud.kubernetes.reload.mode=polling
spring.cloud.kubernetes.reload.period=30000
```

Properties setting in application.properties

```PROPERTIES
management.endpoint.restart.enabled=true
```

Inject in Spring Boot java code:

```JAVA
@Value("${bomc.consumer}")
private String consumerBaseUrl;

@Value("${bomc.github}")
private String githubBaseUrl;
```

## 15 ArgoCD
Application definitions, configurations, and environments should be declarative and version controlled. Application deployment and lifecycle management should be automated, auditable, and easy to understand.

### 15.1 Install ArgoCD
see [https://argoproj.github.io/argo-cd/getting_started/](https://argoproj.github.io/argo-cd/getting_started/)

```BASH
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ... or download install.yaml localy and install it from local directory.
kubectl apply -n argocd -f install-argocd.yaml
```

### 15.2 Download Argo CD CLI (optional)
Download the latest Argo CD version from [https://github.com/argoproj/argo-cd/releases/latest](https://github.com/argoproj/argo-cd/releases/latest). 
More detailed installation instructions can be found via the CLI installation documentation.

### 15.3 Access The Argo CD API Server
#### Ingress
Follow the [ingress documentation](https://argoproj.github.io/argo-cd/operator-manual/ingress/) on how to configure Argo CD with ingress.

```YAML
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  labels:
    app: argocd
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /argocd
        backend:
          serviceName: argocd-server
          servicePort: 80
# kubectl apply -f 010-argocd-ingress.yaml -n argocd
# Open a browser on 'http://192.168.99.107/argocd'
```

#### Port Forwarding
Kubectl port-forwarding can also be used to connect to the API server without exposing the service.

```BASH
# The port-forward command will also now be running in the foreground of the terminal.
# Open another terminal window or tab and cd back into the working directory.
kubectl port-forward svc/argocd-server -n argocd 9001:443

# ArgoCD will be available at 
https://localhost:9001
```

#### Login to UI -> get password
ArgoCD uses the unique name of its server pod as a default password, so every installation will be different.

The following command will list the pods and format the output to provide just the line to need. 

It will have the format `argocd-server-7cc4576d57-6r99p`.

```BASH
# username: admin
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```

#### Change password
By default ArgoCD uses the server pod name as the default password for the admin user, see above. To replace it with a new password use the following command. To generate a new password generate it on this [site](https://www.browserling.com/tools/bcrypt). In the command the new password is `bomc`.

```BASH
# bcrypt(password)=$2a$10$y9GU.bGraMgJ4vXtNqix/.RGV0uh6psoY8aidrtMoAp0TSODlvcPy
# Note: namespace name.
#       Create 'passwordMtime' with command 'echo $(date +%FT%T%Z)'.
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "$2a$10$y9GU.bGraMgJ4vXtNqix/.RGV0uh6psoY8aidrtMoAp0TSODlvcPy","admin.passwordMtime":"2021-04-05T12:05:05"}}'

# This command is not running on windows.
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": "$2a$10$y9GU.bGraMgJ4vXtNqix/.RGV0uh6psoY8aidrtMoAp0TSODlvcPy,"admin.passwordMtime": "$(date +%FT%T%Z)"}}'
````
Now use the credentials `admin` and `bomc` to login

#### The following helping to determine when the server is ready
```BASHH
kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s deployment.apps/argocd-server condition met
````
### 15.4 ArgoCD behind Ingresss
#### Check minikube ip

```BASH
minikube ip
```

should return something like this: `192.168.99.107`

>Note: If you are running Minikube locally, use minikube ip to get the external IP. The IP address displayed within the ingress list will be the internal IP. [Source: Set up Ingress on Minikube with the NGINX Ingress Controller](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)

#### Add the ingress resource:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: argocd-ingress
  labels:
    app: argocd
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
  namespace: argocd
spec:
  rules:
  - http:
      paths:
      - path: /argocd
        backend:
          serviceName: argocd-server
          servicePort: 8080
```

Check the created ingress:

```BASH
kubectl get ingress -n argocd
```

```bash
# Invoke with curl and ip.
curl -Lk $(minikube ip)/argocd
```

| NAME           | HOSTS | ADDRESS        | PORTS | AGE |
|:--------------:|:-----:|:--------------:|:-----:|:---:|
| argocd-ingress |   *   | 192.168.99.107 | 80    | 30m |

If you want to curl the DNS name (see on windows C:\Windows\System32\drivers\etc\hosts file) instead of IP add a host rule to the ingress resource. It should look like this:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: argocd-ingress
  labels:
    app: argocd
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
  namespace: argocd
spec:
  rules:
    - host: bomc.ingress.org
      http:
        paths:
          - path: /argocd
            backend:
              serviceName: argocd-server
              servicePort: 8080
```

```bash
# Check with curl and DNS name.
curl -Lk bomc.ingress.org/argocd
```

### 15.5 ArgoCD behind Ambassador
It is important to now add the --insecure flag on the ArgoCD deployment with:

```BASH
kubectl patch deployment argocd-server --type json -p='[ { "op": "replace","path":"/spec/template/spec/containers/0/command","value": ["argocd-server","--staticassets","/shared/app","--insecure"] }]' -n argocd
```

        # bomc: Add insecure and argocd as rootpath
        - --insecure
        - --rootpath
        - /argocd
        
## 16 Ambassador

### 16.1 Install

Deploy the Ambassador API gateway, start by deploying the custom resource definitions (CRDs) the gateway uses:

Create custom namespace, otherwise it will be deployed to the default namespace.

```BASH
kubectl create namespace ambassador
```

```bash
kubectl apply -f https://www.getambassador.io/yaml/ambassador/ambassador-crds.yaml -n ambassador

# ... or download ambassador-crds.yaml locally and install it from local directory.
kubectl apply -f ambassador-crds.yaml -n ambassador 
```

```bash
kubectl apply -f https://www.getambassador.io/yaml/ambassador/ambassador-rbac.yaml -n ambassador

# ... or download ambassador-rbac.yaml locally and install it from local directory.
kubectl apply -f ambassador-rbac.yaml -n ambassador
```

Change in `ambassador-rbac.yaml` the namespace handling. 

The service account configuration is available in the yaml file. Ambassador uses this service account to connect to the Kubernetes API and watch for changes to service and other objects.

```YAML
# Change in ClusterRoleBinding

73  subjects:
74  - kind: ServiceAccount
75    name: ambassador
76    # bomc
77  # namespace: default
78  namespace: ambassador
```

The default installation creates 3 Ambassador pods and the ambassador-admin service.

```bash
# pods
kubectl -n ambassador get pod -l service=ambassador
# services
kubectl -n ambassador get svc
```

Inspect the ClusterRoleBinding, and more importantly, the ClusterRole as well.

```bash
kubectl get ClusterRole/ambassador -o yaml
```

Inspect the certificate with openssl.

```bash
kubectl get secret nibz-nightly-2019-03-27 -o yaml | grep tls.crt: | cut -d " "
```

### 16.2 Ambassador Diagnostic Overview UI in a browser
Run following command to list services. Look for `ambassador-admin` and use one of the given ip adresses:
 
```BASH
minikube service list
```

|      NAMESPACE       |           NAME            |          TARGET PORT           | URL |
|----------------------|---------------------------|--------------------------------|-----|
|ambassador            |ambassador                 |http://192.168.99.112:30237     |     |

or determine the NodePort with command:

```BASH
kubectl get service ambassador --output='jsonpath="{.spec.ports[0].nodePort}"' -n ambassador
```


```BASH
# Use the link to open Ambassador Diagnostic Overview in a browser.
http://192.168.99.127:31442/ambassador/v0/diag
```

### 16.3 Create a LoadBalancer service to route the traffic 
Create a separately LoadBalancer service that will route traffic to the ambassador pods.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ambassador
  namespace: ambassador
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ports:
    - port: 80
      targetPort: 8080
  selector:
    service: ambassador
```

> Die `externalTrafficPolicy` mit dem Wert `Local` bedeutet, dass Requests nur an lokale Endpoints weitergeleitet werden. Es wird niemals Datenverkehr an andere Knoten weitergeleitet, wobei die urspr?ngliche Client-IP-Adresse beibehalten wird. 

List the services, notice the ambassador service doesn't have an IP address in the EXTERNAL-IP column. 
Note that this is only because the cluster is running locally. If a cloud-managed cluster is used, this would create an actual load balancer instance in the cloud account 
and a public/private IP address will be generated to access the services.

```BASH
kubectl get svc -n ambassador
```

| NAME              | TYPE          | CLUSTER-IP     | EXTERNAL-IP  | PORT(S)                        | AGE |
|-------------------|---------------|----------------|--------------|--------------------------------|-----|
|ambassador         |LoadBalancer   |10.96.119.205   |<pending>     |80:30237/TCP                    |37s  |
|ambassador-admin   |NodePort       |10.105.139.10   |<none>        |8877:30643/TCP,8005:31726/TCP   |21h  |

### 16.4 Minikube tunnel

> Minikube has a `tunnel` command that allows generating a external ip addresses for these services which can be accessed directly on the host machine without using the general minikube ip.
> Run minikube tunnel in a separate terminal as administrator. This runs in the foreground as a daemon. In a different terminal, execute a kubectl apply -f <file_name> command to deploy a desired service. 
> It should generates an ip address that is routed directly to the service and available on port 80 on that address.

__More here on the minikube documentation: https://minikube.sigs.k8s.io/docs/tasks/loadbalancer/__

Start the minikube tunnel in a new terminal as administrator:

```BASH
minikube tunnel

minikube tunnel --alsologtostderr --v=8

# cleanup tunnel
minikube tunnel --cleanup
```

```BASH
Status:
        machine: minikube
        pid: 39380
        route: 10.96.0.0/12 -> 192.168.99.112
        minikube: Running
        services: [ambassador]
    errors:
                minikube: no errors
                router: no errors
                loadbalancer emulator: no errors
```

```BASH
# Lets list the services again.
kubectl get svc -n ambassador
```

| NAME              | TYPE          | CLUSTER-IP     | EXTERNAL-IP  | PORT(S)                        | AGE |
|-------------------|---------------|----------------|--------------|--------------------------------|-----|
|ambassador         |LoadBalancer   |10.96.119.205   |10.96.119.205 |80:30237/TCP                    |2d17h|
|ambassador-admin   |NodePort       |10.105.139.10   |<none>        |8877:30643/TCP,8005:31726/TCP   |3d14h|

This time the ambassador service will get an actual IP address `10.96.119.205` that falls in the CIDR from the tunnel command.

The tunnel command creates a network route on the computer to the service CIDR (Classless Inter-Domain Routing) of the cluster. 
The 10.96.0.0/12 CIDR includes IPs starting from 10.96.0.0 to 10.111.255.255. This network route uses the cluster's IP address (192.168.99.112) as a gateway. 

```BASH
# Invoke the Ambassador UI in a browser.
http://10.96.119.205/ambassador/v0/diag/
```

### 16.5 Route microservice by ambassador
There different ways to route a microservice with ambassador.

#### 16.5.1 Ingress

```BASH
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  labels:
    app: publish
  name: publish-ingress
  namespace: bomc-publish-prod
  annotations:
    kubernetes.io/ingress.class: ambassador
spec:
  rules:
    - http:
        paths:
          - path: /api
            backend:
              serviceName: publish-service-cluster-ip
              servicePort: 8181
```

#### 16.5.2 Extend service by annotation

```BASH
apiVersion: v1
kind: Service
metadata:
  name: publish-service-ambassador
  namespace: default
  labels:
    app: publish
  annotations:
    getambassador.io/config: |
      ---
      apiVersion: ambassador/v1
      kind:  Mapping
      name:  ambassador-publish-mapping-prod
      #
      # see https://www.getambassador.io/docs/edge-stack/latest/topics/using/rewrites/
      # http://10.111.121.174/bomc/api/metadata/annotation-validation
      # would effectively be written to
      # http://10.111.121.174/api/metadata/annotation-validation
      #
      prefix: /bomc/
      rewrite: /
      service: publish-service-ambassador:8181
spec:
  selector:
    app: publish
  ports:
  - protocol: TCP
    name: 8181-TCP
    port: 8181
    targetPort: 8181
  type: ClusterIP
```

Check it with a curl against the publish-app

```BASH
curl -v -X POST "http://10.111.75.249/bomc/api/metadata/annotation-validation" -H "accept: application/json" -H "X-B3-TraceId: 82f198ee56343ba864fe8b2a57d3eff7" -H "X-B3-ParentSpanId: 11e3ac9a4f6e3b90" -H "Content-Type: application/json" -d "{\"id\":\"42\",\"name\":\"bomc\"}"
```

### 16.6 Enable Ambassador as Minikube addon
It is also possible to deploy Ambassador (Community) as Minikube addon.
Checked with Minikube v1.19.0

```bash
minikube addons enable ambassador
```

## 17 Tekton
Tekton provides a set of open source Kubernetes resources to build and run CI/CD pipelines, such as parameterized tasks, inputs and outputs, as well as runtime definitions.

### 17.1 Registry
One of the things that will be needed to run Tekton locally is how it will be interacting with a locally running docker registry. With minikube, enable the local registry capabilities by running the minikube registry addon. 
Run the following:

```bash
minikube start --vm-driver=virtualbox --cpus 3 --memory 10240 --disk-size=30GB --insecure-registry=registry.kube-system.svc.cluster.local:80

minikube addons enable registry
```

> This command starts minikube to allow insecure registry for the internally running registry that is enabled.

If this successfully works, a registry is deployed into the kube-system namespace and a service will be defined.

```bash
kubectl get svc registry -n kube-system -o yaml
```

This will make an insecure registry available within the cluster at `registry.kube-system.svc.cluster.local` on port 80. This can then reference this domain from Tekton pipelines.

### 17.2 Install
```bash
# Show for current releases.
https://github.com/tektoncd/pipeline/releases

# Install
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml  # Deploy pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml  # Deploy triggers

# Check installation
kubectl get svc,deploy --namespace tekton-pipelines --selector=app.kubernetes.io/part-of=tekton-pipelines

# This command will create a tekton-pipelines namespace, as well as other resources to finalize the Tekton installation. 
# With that namespace in mind, easily track the progress of the installation using the command below:

kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml  # Deploy dashboard

# Check installation
kubectl get svc,deploy -n tekton-pipelines --selector=app=tekton-dashboard
```

```bash
kubectl get pods --namespace tekton-pipelines --watch
```

### 17.3 Tekton CLI
```bash
# Get tekton cli.
https://github.com/tektoncd/cli/releases

# or with chocolatery 
choco install tektoncd-cli --confirm

# Using the TKN CLI
# Start a task with name hello. 'name' = kind/Task/metadata/name: hello
tkn task start --showlog hello

# Start a task with parameter 'namespace=Bomc hello' setting 
# and the rest with default values.
tkn task start <taskname> --showlog -p namespace=Bomc hello

# Start a pipeline with name myPipeline
tkn pipeline start myPipeline --showlog

# Get the tasks
tkn tasks list
# or
tkn t ls 

# Delete tasks
tkn tasks delete <taskname>
tkn t delete <taskname> 

# Describe tasks
tkn tasks describe <taskname>
tkn t describe <taskname> 

# Tasks logs
tkn task logs -f <task name>
tkn taskrun logs -L -f
# or
tkn t logs -f <task name>

# Get the Taskrun and check the status
tkn taskrun list
# or
tkn tr ls

# Delete taskrun
tkn taskrun delete <taskrun name>
# or
tkn tr delete <taskrun name>

# Get the Pipeline
tkn pipeline list
# or
tkn p ls

# Delete Pipeline
tkn pipeline delete <Pipeline name>
# or
tkn p delete <Pipeline name>  

# Pipeline Logs
tkn pipeline logs -f <pipline name>
# or
tkn p logs -f <pipline name>

# Describe pipline
tkn pipline describe <pipline>
tkn p describe <pipline> 

# Start the build task
tkn task start <taskname>
```

### 17.4 Tekton dashboard / Port Forwarding
```bash
# Port forwarding
kubectl --namespace tekton-pipelines port-forward svc/tekton-dashboard 9097:9097

# The Dashboard is available in the browser at 
http://localhost:9097
```

Browse http://localhost:9097 to access your Dashboard.

#### 17.4.1 Using an Ingress rule
see: `https://github.com/tektoncd/dashboard/blob/main/docs/install.md`

A more advanced solution is to expose the Dashboard through an Ingress rule.

This way the Dashboard can be accessed as a regular website without requiring kubectl.

Assuming you have an ingress controller up and running in your cluster, and that tekton-pipelines is the install namespace for the Dashboard, run the following command to create the Ingress resource:

# replace DASHBOARD_URL with the hostname you want for your dashboard
# the hostname should be setup to point to your ingress controller
DASHBOARD_URL=dashboard.domain.tld
kubectl apply -n tekton-pipelines -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: tekton-dashboard
  namespace: tekton-pipelines
spec:
  rules:
  - host: $DASHBOARD_URL
    http:
      paths:
      - backend:
          serviceName: tekton-dashboard
          servicePort: 9097
EOF

You can now access the Dashboard UI at http(s)://dashboard.domain.tld in your browser (assuming the host configured in the ingress is dashboard.domain.tld)







  labels:
    app.kubernetes.io/name: dogpic-web
    
    
    
https://github.com/argoproj/argo-cd/blob/a54ceb87bb73532473a857ba0c7408a7fdf34d8c/docs/ingress.md#ui-base-path

 
 

https://github.com/govindKAG/examples/commit/dd91ddc43d3e7dfe4eda0f7354cf926438abd60f

https://github.com/govindKAG/examples/blob/dd91ddc43d3e7dfe4eda0f7354cf926438abd60f/code_search/demo/cs-demo-1103/k8s_specs/argo_cd.yaml

https://github.com/govindKAG/examples/blob/dd91ddc43d3e7dfe4eda0f7354cf926438abd60f/code_search/demo/cs-demo-1103/k8s_specs/argo_cd_ui_mapping.yaml



https://medium.com/@datawire/building-ambassador-an-open-source-api-gateway-on-kubernetes-and-envoy-33637a9fa6f8



kubectl wait --for=condition=available deployment -l "app.kubernetes.io/name=argocd-server" -n argocd --timeout=300s deployment.apps/argocd-server condition met


