# Politicas padrao: DROP ALL
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

#
# Flush (-F) all specific rules
#
iptables -F INPUT 
iptables -F FORWARD 
iptables -F OUTPUT 
iptables -F -t nat



# libera acesso da maquina para internet
iptables -A OUTPUT -j ACCEPT -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 80 --sport 1024:65535
iptables -A OUTPUT -j ACCEPT -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 443 --sport 1024:65535

# libera acesso da maquina para o scidb
iptables -A OUTPUT -j ACCEPT -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 1239

#libera o recebimento das conexoes estabelecidas
iptables -A INPUT -j ACCEPT -m state --state ESTABLISHED,RELATED -p tcp

# liberar SSH (mudar porta) e incluir destino
#iptables -A INPUT -j ACCEPT -p tcp --dport 7722 -s 0/0 -d 0/0

#liberar saida ssh
#iptables -A INPUT   -j ACCEPT -p tcp -s 192.168.0.0/24 
#iptables -A OUTPUT  -j ACCEPT -p tcp -d 192.168.0.0/24 --dport 7722


#Permite consultas para DNS (incluir ip do DNS confiavel)
iptables -A INPUT -p udp -s 0/0 --source-port 53 -d 0/0 -j ACCEPT


#dropa tudo de input

iptables -A INPUT -j DROP -p all -s 0/0 -d 0/0


