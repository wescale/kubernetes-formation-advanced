apiVersion: kops/v1alpha2
kind: Cluster
metadata:
  name: {{ environ('NAME') }}
spec:
  kubernetesVersion: 1.10.6
  additionalPolicies:
    node: |
      [
        {
          "Effect": "Allow",
          "Action": ["sts:AssumeRole"],
          "Resource": ["*"]
        }
      ]
    master: |
      [
        {
          "Effect": "Allow",
          "Action": ["sts:AssumeRole"],
          "Resource": ["*"]
        }
      ]
  kubeDNS:
    provider: CoreDNS
  api:
    loadBalancer:
      type: Internal
  authorization:
    rbac: {}
  channel: stable
  cloudProvider: aws
  configBase: s3://wescale-slavayssiere-kops/{{ environ('NAME') }}
  dnsZone: {{ dns.zone_id }}
  etcdClusters:
  - etcdMembers:
    - instanceGroup: master-eu-west-1a
      name: a
    - instanceGroup: master-eu-west-1b
      name: b
    - instanceGroup: master-eu-west-1c
      name: c
    name: main
  - etcdMembers:
    - instanceGroup: master-eu-west-1a
      name: a
    - instanceGroup: master-eu-west-1b
      name: b
    - instanceGroup: master-eu-west-1c
      name: c
    name: events
  iam:
    allowContainerRegistry: true
    legacy: false
  masterPublicName: api.{{ environ('NAME') }}
  networking:
    calico: 
      crossSubnet: true
      prometheusMetricsEnabled: true 
      prometheusMetricsPort: 9091 # https://github.com/kubernetes/kops/blob/master/pkg/apis/kops/v1alpha2/networking.go
  kubeAPIServer:
    runtimeConfig:
      admissionregistration.k8s.io/v1alpha1: "true"
  nonMasqueradeCIDR: 100.64.0.0/10
  kubernetesApiAccess:
  - {{ network.cidr }}
  sshAccess:
  - {{ network.cidr }}
  networkCIDR: {{ network.cidr }}
  networkID: {{ network.vpc_id }}
  subnets:
  - cidr: {{ network.private_a.cidr }}
    id: {{ network.private_a.id }}
    egress: {{ network.private_a.nat_id }}
    name: eu-west-1a
    type: Private
    zone: eu-west-1a
  - cidr: {{ network.private_b.cidr }}
    id: {{ network.private_b.id }}
    egress: {{ network.private_b.nat_id }}
    name: eu-west-1b
    type: Private
    zone: eu-west-1b
  - cidr: {{ network.private_c.cidr }}
    id: {{ network.private_c.id }}
    egress: {{ network.private_c.nat_id }}
    name: eu-west-1c
    type: Private
    zone: eu-west-1c
  - cidr: {{ network.public_a.cidr }}
    id: {{ network.public_a.id }}
    name: utility-eu-west-1a
    type: Utility
    zone: eu-west-1a
  - cidr: {{ network.public_b.cidr }}
    id: {{ network.public_b.id }}
    name: utility-eu-west-1b
    type: Utility
    zone: eu-west-1b
  - cidr: {{ network.public_c.cidr }}
    id: {{ network.public_c.id }}
    name: utility-eu-west-1c
    type: Utility
    zone: eu-west-1c
  topology:
    dns:
      type: Private
    masters: private
    nodes: private

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{ environ('NAME') }}
  name: master-eu-west-1a
spec:
  associatePublicIp: false
  machineType: m3.medium
  maxSize: 1
  minSize: 1
  rootVolumeSize: 64
  rootVolumeType: gp2
  nodeLabels:
    kops.k8s.io/instancegroup: master-eu-west-1a
  role: Master
  subnets:
  - eu-west-1a

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{ environ('NAME') }}
  name: master-eu-west-1b
spec:
  associatePublicIp: false
  machineType: m3.medium
  maxSize: 1
  minSize: 1
  rootVolumeSize: 64
  rootVolumeType: gp2
  nodeLabels:
    kops.k8s.io/instancegroup: master-eu-west-1b
  role: Master
  subnets:
  - eu-west-1b

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{ environ('NAME') }}
  name: master-eu-west-1c
spec:
  associatePublicIp: false
  machineType: m3.medium
  maxSize: 1
  minSize: 1
  rootVolumeSize: 64
  rootVolumeType: gp2
  nodeLabels:
    kops.k8s.io/instancegroup: master-eu-west-1c
  role: Master
  subnets:
  - eu-west-1c

---

apiVersion: kops/v1alpha2
kind: InstanceGroup
metadata:
  labels:
    kops.k8s.io/cluster: {{ environ('NAME') }}
  name: nodes
spec:
  associatePublicIp: false
  machineType: m3.medium
  maxSize: 10
  minSize: 1
  rootVolumeSize: 64
  rootVolumeType: gp2
  cloudLabels:
    plateform: {{ environ('NAME') }}
    node-ig: simple-node
  nodeLabels:
    kops.k8s.io/instancegroup: nodes
  role: Node
  subnets:
  - eu-west-1a
  - eu-west-1b
  - eu-west-1c
