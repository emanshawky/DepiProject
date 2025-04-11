[example]
%{ for ip in instances ~}
${ip} ansible_ssh_user=ec2-user
%{ endfor ~}