#Resource Group creation
az group create --name SolarImpulseRG --location eastus

#Provide the solar-impulse-test vnet
az network vnet create \
  --name solar-impulse-test \
  --resource-group SolarImpulseRG \
  --address-prefix 10.0.0.0/16 \
  --subnet-name solarImpulseTestsubnet \
  --subnet-prefix 10.0.0.0/24
az container create --resource-group mySolarImpulseRG --name mydnsmasqcontainer --image https://hub.docker.com/r/strm/dnsmasq

#Provide the solar-impulse-acc vnet
az network vnet create \
  --name solar-impulse-acc \
  --resource-group SolarImpulseRG \
  --address-prefix 10.1.0.0/16 \
  --subnet-name solarImpulseAccsubnet \
  --subnet-prefix 10.1.0.0/24
#Provide the nic to define public IP
az network nic create \
--resource-group SolarImpulseRG \
--name mySolarImpulseNIC \
--location eastus \
--subnet solarImpulseAccsubnet \
--private-ip-address 195.169.110.175 \
--vnet-name solar-impulse-acc

#Provide the name of the Managed Disk
managedDiskName=myManagedsolarImpulseAccDisk
#Provide the OS type
osType=linux
#Get the resource Id of the managed disk
managedDiskId=$(az disk show --name $managedDiskName --resource-group SolarImpulseRG --query [id] -o tsv)
az vm create \
--resource-group SolarImpulseRG \
--name solarImpulseAcctVM01 \
--location eastus \
--attach-os-disk $managedDiskId \
--os-type $osType \
--admin-username adminuser \
--generate-ssh-keys \
--subnet solarImpulseAccsubnet \
--nics mySolarImpulseNIC

#Provide the nsg on subnet level protection
az network nsg rule create -g mySolarImpulseRG --nsg-name MySolarImpulseNsg -n MySolarImpulseNsgRule --priority 100

#Provide the vnet peering to connect between the two
az network vnet peering create -g SolarImpulseRG -n SolarImpulseTestToAcc --vnet-name solar-impulse-test \
    --remote-vnet solar-impulse-acc --allow-vnet-access