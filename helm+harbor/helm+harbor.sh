mv helm /usr/bin/
chmod 777 /usr/bin/helm

helm repo add  elastic    https://helm.elastic.co
helm repo add  bitnami    https://charts.bitnami.com/bitnami
helm repo add stable https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
helm repo add goharbor https://helm.goharbor.io
helm repo update
#kubectl apply -f harbor-data.yml
helm -n ci install harbor goharbor/harbor -f harbor-values.yaml
#helm repo add xcg http://120.79.91.83:30002/chartrepo/xiancaige