#!/bin/bash
# إعداد Jenkins للمستخدمين والأدوار

echo "🔹 إضافة مستخدمين إلى Jenkins..."

# الدخول إلى Jenkins CLI
JENKINS_URL="http://192.168.204.131:8080"
JENKINS_CLI="/var/lib/jenkins/jenkins-cli.jar"
ADMIN_USER="admin"
ADMIN_TOKEN="your_admin_token"

# تحميل Jenkins CLI (إذا لم يكن موجودًا)
if [ ! -f "$JENKINS_CLI" ]; then
  wget $JENKINS_URL/jnlpJars/jenkins-cli.jar -O $JENKINS_CLI
fi

# إنشاء المستخدم الأول (admin)
java -jar $JENKINS_CLI -s $JENKINS_URL -auth $ADMIN_USER:$ADMIN_TOKEN create-user user1 user1 password1 "User One" user1@example.com

# إنشاء المستخدم الثاني (read-only)
java -jar $JENKINS_CLI -s $JENKINS_URL -auth $ADMIN_USER:$ADMIN_TOKEN create-user user2 user2 password2 "User Two" user2@example.com

echo "✅ تم إنشاء المستخدمين user1 و user2"

# إنشاء الأدوار
java -jar $JENKINS_CLI -s $JENKINS_URL -auth $ADMIN_USER:$ADMIN_TOKEN groovy = <<EOF
import jenkins.model.*
import com.michelin.cio.hudson.plugins.rolestrategy.*

def instance = Jenkins.getInstance()
def rbac = instance.getAuthorizationStrategy()

// إنشاء دور Admin
rbac.addRole(RoleBasedAuthorizationStrategy.GLOBAL, new Role("admin", ".*", [Permission.fromId("hudson.model.Hudson.Administer")] as Set))

// إنشاء دور ReadOnly
rbac.addRole(RoleBasedAuthorizationStrategy.GLOBAL, new Role("read-only", ".*", [Permission.fromId("hudson.model.Hudson.Read")] as Set))

// ربط الأدوار بالمستخدمين
rbac.assignRole(RoleBasedAuthorizationStrategy.GLOBAL, "admin", "user1")
rbac.assignRole(RoleBasedAuthorizationStrategy.GLOBAL, "read-only", "user2")

instance.save()
EOF

echo "🎯 تم إنشاء الأدوار وتعيينها بنجاح."
