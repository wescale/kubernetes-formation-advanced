dns:
    zone_id: ${zone_id}
network:
    cidr: ${vpc_cidr}
    vpc_id: ${vpc_id}
    private_a:
        cidr: ${priv_a_cidr}
        id: ${priv_a_id}
        nat_id: ${priv_a_nat}
    private_b:
        cidr: ${priv_b_cidr}
        id: ${priv_b_id}
        nat_id: ${priv_b_nat}
    private_c:
        cidr: ${priv_c_cidr}
        id: ${priv_c_id}
        nat_id: ${priv_c_nat}
    public_a:
        cidr: ${pub_a_cidr}
        id: ${pub_a_id}
    public_b:
        cidr: ${pub_b_cidr}
        id: ${pub_b_id}
    public_c:
        cidr: ${pub_c_cidr}
        id: ${pub_c_id}
