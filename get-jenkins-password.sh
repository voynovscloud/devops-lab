#!/bin/bash

echo "🔐 Jenkins Access Information"
echo "=============================="
echo ""

# Get pod name
POD=$(kubectl get pod -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
    echo "❌ Jenkins pod not found"
    exit 1
fi

echo "✓ Jenkins pod: $POD"
echo ""

# Try to get initial password
if kubectl exec -n jenkins $POD -- test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    echo "📋 Initial Admin Password:"
    kubectl exec -n jenkins $POD -- cat /var/jenkins_home/secrets/initialAdminPassword
    echo ""
else
    echo "⚠️  Jenkins is already configured (initial password file not found)"
    echo ""
    echo "To reset admin password, run:"
    echo "  kubectl exec -n jenkins $POD -- bash -c 'echo \"jenkins.model.Jenkins.instance.securityRealm.createAccount(\\\"admin\\\", \\\"admin123\\\")\" | java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin groovy ='"
    echo ""
    echo "Or delete and recreate Jenkins pod to get fresh password:"
    echo "  kubectl delete pod -n jenkins $POD"
    echo "  (wait for new pod to start)"
    echo "  ./get-jenkins-password.sh"
    echo ""
fi

echo "🌐 Access Jenkins at:"
echo "  http://jenkins.local"
echo ""
echo "💡 If you need to reset Jenkins completely:"
echo "  kubectl delete pvc -n jenkins jenkins-home"
echo "  kubectl delete pod -n jenkins $POD"
echo "  (This will delete all Jenkins data and start fresh)"
echo ""
