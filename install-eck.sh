#!/bin/bash

kubectl create -f https://download.elastic.co/downloads/eck/2.11.1/crds.yaml

kubectl apply -f https://download.elastic.co/downloads/eck/2.11.1/operator.yaml

kubectl -n elastic-system logs -f statefulset.apps/elastic-operator

cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 8.12.0
  nodeSets:
  - name: default
    count: 4
    config:
      node.store.allow_mmap: false
EOF


kubectl get elasticsearch

kubectl get pods --selector='elasticsearch.k8s.elastic.co/cluster-name=quickstart'

kubectl logs -f quickstart-es-default-0

kubectl get service quickstart-es-http


cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: quickstart
spec:
  version: 8.12.0
  count: 1
  elasticsearchRef:
    name: quickstart
EOF


kubectl get kibana

kubectl get pod --selector='kibana.k8s.elastic.co/name=quickstart'

kubectl get service quickstart-kb-http

kubectl port-forward service/quickstart-kb-http 5601

kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo


