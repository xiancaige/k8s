echo "-----------rmfile------------"
rm -rf  $HOME/.config
rm -rf /root/.kube
rm -rf  /etc/kubernetes/*
rm -rf /etc/cni/net.d

echo "-----------reset------------"
kubeadm reset -f

echo "-----------reset-net------------"
ifconfig cni0 down
ip link delete cni0


iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT


iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT

iptables -t mangle -P PREROUTING ACCEPT
iptables -t mangle -P OUTPUT ACCEPT

iptables -F
iptables -t nat -F
iptables -t mangle -F

iptables -X
iptables -t nat -X
iptables -t mangle -X

echo "-----------end------------"
