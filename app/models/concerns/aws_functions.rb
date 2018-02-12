module AwsFunctions
    CLUSTER_NAME = "default"

    def create_join_db()
        # Something about the default Ruby SSL certificate
        Aws.use_bundled_cert!

        ecs_client = Aws::ECS::Client.new()
        ec2_client = Aws::EC2::Client.new()

        arn = run_new_join_db_task(
            ecs_client: ecs_client,
            ec2_client: ec2_client
        )

        # Wait a little bit so it's created
        # TODO: Make this a callback
        
        sleep(7)
        dns_name = get_join_db_public_dns_name(
            ecs_task_arn: arn,
            ecs_client: ecs_client,
            ec2_client: ec2_client
        )

        return {
            task_arn: arn,
            dns_name: dns_name,
            port: 5432 # Change if we stop putting everything on 5432 
        }
    end

    def run_new_join_db_task(ecs_client:, ec2_client:)
        available_subnets = ec2_client.describe_subnets.subnets.map(&:subnet_id)

        resp = ecs_client.run_task({
            cluster: CLUSTER_NAME,
            task_definition: "joiner-service:1",
            launch_type: "FARGATE",
            network_configuration: {
                awsvpc_configuration: {
                    subnets: available_subnets,
                    security_groups: ["sg-da2fd4ad"],
                    assign_public_ip: "ENABLED"
                }
            }
        })

        ecs_task_arn = resp.tasks[0].task_arn
        return ecs_task_arn
    end

    def get_network_interface_id(ecs_task_arn, ecs_client)
        task_desc = ecs_client.describe_tasks({
            tasks: [ecs_task_arn]
        })

        network_interface_id = task_desc.tasks[0].attachments[0].details.
            select{|detail| detail.name == "networkInterfaceId"}[0].value
        
        return network_interface_id
    end

    def get_network_interface_public_dns_name(network_interface_id, ec2_client)
        dns_name = ec2_client.describe_network_interfaces({
            network_interface_ids: [network_interface_id]
        }).network_interfaces[0].association.public_dns_name

        return dns_name
    end

    def get_join_db_public_dns_name(ecs_task_arn:, ecs_client:, ec2_client:)
        network_interface_id = get_network_interface_id(ecs_task_arn, ecs_client)
        dns_name = get_network_interface_public_dns_name(network_interface_id, ec2_client)

        return dns_name
    end

    def stop_join_db(task_arn)
        # Something about the default Ruby SSL certificate
        Aws.use_bundled_cert!

        ecs_client = Aws::ECS::Client.new()
        ecs_client.stop_task({
            cluster: CLUSTER_NAME,
            task: task_arn
        })
    end
end
