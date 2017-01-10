# ocp-splunk

POC integrating Splunk & OCP using universal forwarder as a sidecar container. Configure FluentD to write log events to the local filesystem. Configure the Splunk Universal Forwarder to pick up the events in these logs and forward them onto the main Splunk instance.


## Assumptions
1. Splunk is installed and you have admin rights to administer it
2. Splunk is configured to receive data from the Splunk Universal Forwarder (see http://docs.splunk.com/Documentation/SplunkLight/6.5.1/GettingStarted/GettingdataintoSplunkLightusingLinux)
3. OCP federated logging is installed and operational on OCP
4. The user has admin rights to the project where the EFK stack is installed
5. There is network connectivity between the OCP nodes and the Splunk server


## Configuration
### FluentD
Edit the fluentd configuration to dump events to the local pod filesystem

```
>oc edit configmap logging-fluentd
```
Add the following content:

```
output-extra-splunk.conf: |
  <store>
   @type file
   format json
   path /var/log/splunk/ocp-pickup
   time_slice_format %Y%m%d
   time_slice_wait 10m
   time_format %Y%m%dT%H%M%S%z
  </store>
```

**Note** The path location has to match the mount points listed below.

### Build the Universal Forwarder sidecar image
```
oc new-build https://github.com/noelo/ocp-splunk.git
```

### Add the sidecar image to the POD definition in the daemonset
```
oc get daemonsets logging-fluentd -o json|jq '.spec.template.spec.containers |= .+ [{"name": "ocp-splunk-sidecar","image": "172.30.93.103:5000/logging/ocp-splunk:latest","env": [{"name": "SPLUNK_MONITOR_LOCN","value": "/var/log/splunk/"},{"name": "SPLUNK_SERVER","value": "192.168.1.27:9997"}],"resources": {},"volumeMounts": [],"terminationMessagePath": "/dev/termination-log","imagePullPolicy": "Always"}]' | oc replace -f -
```

* *SPLUNK_MONITOR_LOCN* is the mountpoint of the shared volume which contains the logs
* *SPLUNK_SERVER* is the address of the main Splunk server in *host:port* port format

**Note** Ensure that you use the correct registry address in the image

### Create the shared volume
```
oc volume daemonsets logging-fluentd --add --mount-path=/var/log/splunk --type=emptyDir
```

Changing the daemonset doesn't redeploy the pods so kill each pod.

## TODO
1. Change Fluentd to remove forwarding to Elasticsearch
2. Modify the sidecar pod to not run as root
3. Somehow get a relevant hostname in the logs instead of a pod hostname
4. Use the Splunk supplied dockerfile


**Note** “Splunk” and other Splunk logos, trademarks, service marks, and product and service names are the intellectual property of Splunk.
