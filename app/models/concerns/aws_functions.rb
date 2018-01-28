ecs_client = Aws::ECS::Client.new()
ec2_client = Aws::EC2::Client.new()

def create_join_db()
    available_subnets = ec2_client.describe_subnets.subnets.map(&:subnet_id)

    resp = ecs_client.run_task({
        cluster: "default",
        task_definition: "joiner-service:1",
        launch_type: "FARGATE",
        network_configuration: {
            awsvpc_configuration: {
                subnets: available_subnets,
                security_groups: ["sg-da2fd4ad"]
            }
        }
    })

    ecs_task_arn = resp.tasks[0].task_arn
    return ecs_task_arn
end

def get_network_interface_id(ecs_task_arn)
    task_desc = ecs_client.describe_tasks({
        tasks: [ecs_task_arn]
    })

    network_interface_id = task_desc.tasks[0].attachments[0].details.
        select{|detail| details.name == "networkInterfaceId"}[0].value
    
    return network_interface_id
end

def get_network_interface_public_dns_name(network_interface_id)
    dns_name = ec2_client.describe_network_interfaces({
        network_interface_ids: [network_interface_id]
    }).network_interfaces[0].association.public_dns_name

    return dns_name
end

def get_join_db_public_dns_name(ecs_task_arn)
    network_interface_id = get_network_interface_id(ecs_task_arn)
    dns_name = get_network_interface_public_dns_name(network_interface_id)

    return dns_name
end