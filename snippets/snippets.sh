# Follow bashible journal logs
sudo journalctl -fu bashible

# List install targets from Makefile
RUN grep '^install-' Makefile

# Format Go test file with gofumpt
gofumpt -w -extra pkg/controller/vm/internal/block_devices_test.go

# Get VM domain XML from virt-launcher pod
kubectl exec -it virt-launcher-vm-alpine-8vd2s -- vlctl domain -oxml

# Watch VirtualDisk attachedToVirtualMachines status
k get vd  -ojsonpath='{.status.attachedToVirtualMachines}{"\n"}' -w

# Remove finalizers from all VMOPs
kubectl get vmop -oname | xargs -I {} kubectl patch {} --type merge -p '{"metadata": {"finalizers": []}}'

# Patch all VirtualDisks with storageClassName
kubectl get vd -oname | xargs kubectl patch --type merge -p '{"spec" : {"persistentVolumeClaim" : {"storageClassName": "i-linstor-thin-r2"}}}'

# Enter compute container network namespace and show IPs
CTR=$(crictl ps | grep compute | head -n 1 | awk '{print $1}') ; PID=$(crictl inspect --output go-template --template '{{.info.pid}}' $CTR) ; nsenter -t $PID -n ip a

# Full Docker cleanup: stop, remove containers, images, volumes, networks
docker stop $(docker ps -qa) && docker rm $(docker ps -qa) && docker rmi -f $(docker images -qa) && docker volume rm $(docker volume ls -q) && docker network rm $(docker network ls -q)

# Restart all VMs via d8
k get vm -oname | awk -F'/' '{print $2}' | xargs -I {} d8 v restart {}

# Select node via fzf and tail virt-handler logs
k get node -oname | awk -F/ '{print $2}' | fzf | read node ; k get pod -n d8-virtualization -owide | grep $node | grep virt-handler | awk '{print $1}' | read pod ; k logs -n d8-virtualization $pod

# SSH tunnel to virtlab cluster
ssh -o ServerAliveInterval=60 -N team-d8-virtualization-infra.virtlab-dl-1 -L 127.0.0.1:6445:172.20.3.101:6443

# Show deckhouse queue
kubectl -n d8-system exec -it deploy/deckhouse -c deckhouse -- deckhouse-controller queue list

# Get all virtualization resources
kubectl get virtualization,intvirt -A

# Get virtualization pods
kubectl get po -n d8-virtualization

# Tail virtualization-controller logs
kubectl logs -n d8-virtualization deployments/virtualization-controller virtualization-controller
