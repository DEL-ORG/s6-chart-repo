

#create private repo in argocd 
argocd repo add git@github.com:DEL-ORG/s6-revive-chart-repo.git --ssh-private-key-path ~/.ssh/id_rsa




#create argocd project and restrict to repo git@github.com:DEL-ORG/s6-revive-chart-repo.git
cat <<EOF | kubectl apply -f -

apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: revive
  namespace: argocd
  # Finalizer that ensures that project is not deleted until it is not referenced by any application
#   finalizers:
#     - resources-finalizer.argocd.argoproj.io
spec:
  # Project description
  description: Revive  Project

  # Allow manifests to deploy from olny Git repos git@github.com:DEL-ORG/s6-revive-chart-repo.git
  sourceRepos:
  - git@github.com:DEL-ORG/s6-revive-chart-repo.git

  # Only permit applications to deploy to the revive namespace in the same cluster
  # Destination clusters can be identified by 'server', 'name', or both.
  destinations:
  - namespace: revive
    server: https://kubernetes.default.svc
    name: in-cluster
   
  # Sync windows restrict when Applications may be synced. https://argo-cd.readthedocs.io/en/stable/user-guide/sync_windows/
  syncWindows:
  - kind: allow
    schedule: '* * * * *'
    clusters:
      - in-cluster
      


EOF

sleep 3


#use kustomized to deploy heml charts 
kubectl apply -k /home/peterg/Desktop/Projects/revive/phase12/phase-12-group/s6-revive-chart-repo/revive-project













