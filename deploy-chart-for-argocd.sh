#! /bin/bash
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: revive
  namespace: argocd
spec:
  destination:
    namespace: revive
    server: https://kubernetes.default.svc
  project: revive
  source:
    path: revive-project/
    repoURL: 'git@github.com:DEL-ORG/s6-revive-chart-repo.git'
    targetRevision: phase-12-deploy-charts
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    automated:
      prune: true
      selfHeal: true
EOF
