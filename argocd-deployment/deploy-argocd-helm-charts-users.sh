#!/bin/bash

# Check if the repo argo exists, if not, add it
if ! helm repo list | grep -q "argo"; then
    helm repo add argo https://argoproj.github.io/argo-helm
fi

# # Check if the folder argo-cd exists
# if [ ! -d "argo-cd" ]; then
#     # If it doesn't exist, pull and untar the helm chart
#     helm pull --untar argo/argo-cd
# fi

# Create namespace argocd
kubectl create namespace argocd
kubectl create namespace revive

# Helm upgrade argocd
helm upgrade -i argocd --namespace argocd \
    --set redis.exporter.enabled=true \
    --set redis.metrics.enabled=true \
    --set server.metrics.enabled=true \
    --set controller.metrics.enabled=true argo/argo-cd

# Wait for 45 seconds
sleep 0



#Patch argocd service
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'



# Get services in argocd namespace
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
kubectl get po -n argocd 
kubectl get svc -n argocd
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"



# Get initial admin password
init_admin_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
#get the dynamic port
port=$(kubectl get svc -n argocd -o wide | awk '/argocd-server/ && !/8083/ {gsub(/.*:/, "", $5); gsub(/\/.*/, "", $5); print $5}')

# Check if argocd CLI is installed
if command -v argocd &>/dev/null; then
    # ArgoCD CLI is installed, display version
    echo "argocd CLI is installed"
else
    # ArgoCD CLI is not installed, proceed with installation
    VERSION="v2.2.3" # replace with the desired version
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
    sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64

fi


#List of user names

echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%%%%%%%%            CREATING USERS POLICIES AND ROLES ....                                        %%%%%%%%%%%%%"                                                                              
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"



cat << EOF > user-names.txt
devopseasylearning
s6student
peter
raoul
confidence
prince
bridget
christopher
perscoba
anang
phase12
EOF


#"CREATING USERs PLOCIES AND ROLES ...."  
cat <<EOF | kubectl apply -f -

#use the data to add or remove  user

apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
  admin.enabled: "true"
  accounts.peter: apiKey, login
  accounts.peter.enabled: "true"
  accounts.bridget: login
  accounts.christopher: login
  accounts.confidence: login
  accounts.mannars: login
  accounts.prince: login
  accounts.raoul: apiKey,login
  accounts.s6student: apiKey,login
  accounts.perscoba: login
  accounts.anang: login 
  accounts.devopseasylearning: apiKey, login   
  accounts.phase12: login     
  accounts.phase12.enabled: "true"            
  
  


---
#create a policy and role for each user

apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-rbac-cm
    app.kubernetes.io/part-of: argocd
data:
  policy.csv: |
    p, role:devops, applications, *, *, allow
    p, role:devops, clusters, *, *, allow
    p, role:devops, gpgkeys, get, *, allow
    p, role:devops, repositories, create, *, allow
    p, role:devops, repositories, update, *, allow
    p, role:devops, repositories, delete, *, allow
    p, role:devops, repositories, patch, *, allow

    p, role:developers, repositories, get, *, allow
    p, role:developers, applications, get, *, allow

    p, role:qa, repositories, list, *, allow
     p, role:qa, repositories, get, *, allow
    p, role:qa, applications, list, *, allow
    
    
    p, role:admin, *, *, *, allow
    p, role:admin, users, create, *, allow
    p, role:admin, users, update, *, allow
    p, role:admin, account, updatePassword, *, allow
    g, devopseasylearning, role:admin

    g, prince, role:devops
    g, confidence, role:devops
    g, prince, role:devops
    

    g, mannars, role:developers
    g, raoul, role:developers
    
    g, christopher, role:qa
    g, bridget, role:qa
   
    g, phase12, role:devops
   

EOF


echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%%%%%%%%            YOU HAVE CREATED USERS POLICIES AND ROLES                               %%%%%%%%%%%%%"                                                                              
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"



# View argocd UI
#kubectl port-forward service/argocd-server -n argocd 8008:443
serverip=$(minikube ip)


echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%%%%%%%%            CHANGE ME IN THE SCRIPT:  serverip=[Your server IP here]               %%%%%%%%%%%%%"                                                                              
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"



echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%%%%%%%%                             VIEW ARDOCD UI                                      %%%%%%%%%%%%%%%"
echo "%%%%%%%%%           "ArgoCD UI: [Your IP address here]:$port"                             %%%%%%%%%%%%%%%"                                  
echo "%%%%%%%%%           "Admin Password: $init_admin_password"                         %%%%%%%%%%%%%%%"
echo "%%%%%%%%%           "Admin user: admin"                                      %%%%%%%%%%%%%%"  
echo "%%%%%%%%%            Example:  "$serverip:$port"                                          %%%%%%%%%%%%%%"         
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"








echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%%%%%%%%           "CREATING/UPDATING USER PASSWORD ...."                                  %%%%%%%%%%%%%"                               
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
#This portion of the script update/create user password 
#You can have to copy and run it separately if you port forwarding 




echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%%%%%%%%%           "kubectl port-forward service/argocd-server -n argocd 8008:443"            %%%%%%%%%%"  
echo "%%%%%%%%%           WHEN ENABLED, ALL THE CODE BELOW IT MUST BE RUN IN A SEPARATE .sh FILE     %%%%%%%%%%"                     
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"


####port forwarding
#kubectl port-forward service/argocd-server -n argocd 8008:443




#ARGOCD_SERVER=your-ip-address-here:8008
ARGOCD_SERVER=$serverip:$port
echo "$ARGOCD_SERVER"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="$init_admin_password"

# Login as admin
argocd login $ARGOCD_SERVER --username $ADMIN_USERNAME --password $ADMIN_PASSWORD --insecure

# Read usernames from the file
usernames_file="user-names.txt"
users=($(cat "$usernames_file"))

# Set password for users
for user in "${users[@]}"
do
    # Add a condition to skip updating users based on a certain criteria
    if [[ "$user" == "user_to_skip" ]]; then
        echo "Skipping password update for user: $user"
        continue
    fi

    # Construct the new password for each user
    NEW_PASSWORD="student@${user}"

    # Update the password for the user
    argocd account update-password \
        --account "$user" \
        --current-password "$ADMIN_PASSWORD" \
        --new-password "$NEW_PASSWORD"

    # Check the exit status of the last command
    if [ $? -eq 0 ]; then
        echo "Password updated for user: $user"
    else
        echo "Failed to update password for user: $user"
    fi
done

echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "Password update for users completed.***e.g [student@name] ***"





