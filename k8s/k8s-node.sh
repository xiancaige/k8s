cat >> /etc/profile <<EOF
export PUBLIC_IP=$1
EOF

source /etc/profile

echo "公网ip"$PUBLIC_IP


echo "------------init env--------"
# 设置dns
#rm -rf /etc/resolv.conf
#cat > /etc/resolv.conf <<EOF
#nameserver 8.8.8.8
#nameserver 114.114.114.114
#EOF
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 114.114.114.114" >> /etc/resolv.conf

# 关闭selinux
setenforce 0

# 关闭swap分区
swapoff -a

cat > /etc/sysctl.conf <<EOF
net.ipv4.tcp_mtu_probing=1
EOF

cat > /etc/sysctl.d/k8s.conf <<EOF
#开启网桥模式
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
#开启转发
net.ipv4.ip_forward = 1
##关闭ipv6
net.ipv6.conf.all.disable_ipv6=1
EOF

sysctl -p /etc/sysctl.d/k8s.conf

# 设置系统时区为 中国/上海
timedatectl set-timezone Asia/Shanghai
# 将当前的UTC时间写入硬件时钟
timedatectl set-local-rtc 0
# 重启依赖于系统时间的服务
systemctl restart rsyslog
systemctl restart crond

#关闭邮件服务
systemctl stop postfix && systemctl disable postfix

mkdir /var/log/journal # 持久化保存日志的目录
mkdir /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/99-prophet.conf <<EOF
[Journal]
# 持久化
Storage=persistent

# 压缩历史日志
Compress=yes

SysnIntervalSec=5m
RateLimitInterval=30s
RateLimitBurst=1000

# 最大占用空间 10G
SystemMaxUse=10G

# 单日志文件最大 200M
SystemMaxFileSize=200M

# 日志保存时间 2 周
MaxRetentionSec=2week

# 不将日志转发到 syslog
ForwardToSyslog=no

EOF

echo "------------yum docker--------"

systemctl restart systemd-journald

# step1
modprobe br_netfilter

# step2
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

# step3
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

# step 1: 安装必要的一些系统工具
yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装Docker-CE
yum makecache fast
yum -y install docker-ce
# Step 4: 开启Docker服务
systemctl start docker

# 创建 `/etc/docker`目录
mkdir -p /etc/docker

# 配置 `daemon`
cat > /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  }
}
EOF

# 启动docker
systemctl daemon-reload && systemctl restart docker && systemctl enable docker

# 刷新iptabels
iptables -F

echo "------------yum k8s--------"

# 添加源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF



# 安装kubelet、kubeadm、kubectl
yum install -y kubelet-1.20.5 kubeadm-1.20.5 kubectl-1.20.5

# 设置为开机自启
systemctl enable kubelet 

echo "------------change network--------"

cat > /etc/sysconfig/network-scripts/ifcfg-eth0:1 <<EOF
BOOTPROTO=static
DEVICE=eth0:1
IPADDR=$PUBLIC_IP
PREFIX=32
TYPE=Ethernet
USERCTL=no
ONBOOT=yes
EOF
# step2 如果是centos8，需要重启
systemctl restart network

echo "------------change kubeadm.conf--------"

cat > /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf <<EOF 
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_CONFIG_ARGS \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS --node-ip=$PUBLIC_IP
EOF
echo "------------init helm--------"

yum install -y socat

echo "------------init over------------"
