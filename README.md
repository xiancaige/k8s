# k8s

环境 centos7.X ，可以用于外网环境的k8s集群，例如各种云组成的集群，脚本内部使用的是kubeadm 进行集群初始操作

kubelet-1.20.5  kubeadm-1.20.5

## k8s

1. k8s-master.sh 启动集群master 

   - 使用：k8s-master.sh 公网IP 私网IP
   - 脚本执行结束 注意复制 加入kubectl join信息

2. k8s-node.sh 初始node节点

   -  使用：k8s-node.sh 公网IP

   - 使用第一步得到的kubectl join加入集群

     

## jenkins

1.jenkins初始化

- sh jenkins-init.sh 初始化maven仓库用于后续使用，创建了ci命名空间，给ci：default赋予了集群管理员权限，用于后续更新应用

2.jenkins启动

- 初始化完成后启动jenkins：kubectl apply -f jenkins-pod
- 然后就可以使用集群任何一个ip+30080访问Jenkins

## Helm

1.Helm初始化

- sh helm-init.sh   初始helm 并安装push插件

