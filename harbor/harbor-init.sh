
#kubectl apply -f harbor-data.yml
helm -n ci install harbor goharbor/harbor -f harbor-values.yaml
#helm repo add xcg http://120.79.91.83:30002/chartrepo/xiancaige