module AwsFunctions
    LAUNCH_TEMPLATE_ID = "lt-0912ea6ef3e419531"

    def create_join_db(user_id, join_db_id)
        # Something about the default Ruby SSL certificate
        Aws.use_bundled_cert!
        ec2_client = Aws::EC2::Client.new()

        instance_id = run_new_join_db_task(ec2_client)

        # Wait a little bit so it's created
        # TODO: Make this a callback
        
        sleep(10)
        dns_name = get_join_db_public_dns_name(
            instance_id: instance_id,
            ec2_client: ec2_client
        )

        return {
            task_arn: instance_id,
            dns_name: dns_name,
            port: 5432 # Change if we stop putting everything on 5432 
        }
    end

    def run_new_join_db_task(ec2_client)
        available_subnets = ec2_client.describe_subnets.subnets.map(&:subnet_id)

        resp = ec2_client.run_instances({
            launch_template: {
                launch_template_id: ENV['LAUNCH_TEMPLATE_ID'] || LAUNCH_TEMPLATE_ID
            },
            max_count: 1,
            min_count: 1,
        })

        instance_id = resp.instances[0].instance_id
        return instance_id
    end

    def get_join_db_public_dns_name(instance_id:, ec2_client:)
        ip_address = ec2_client.describe_instances({
            instance_ids: [instance_id]
        }).reservations[0].instances[0].public_ip_address

        return ip_address
    end

    def stop_join_db(task_arn)
        # Something about the default Ruby SSL certificate
        Aws.use_bundled_cert!
        ec2_client = Aws::EC2::Client.new()

        resp = ec2_client.terminate_instances({
            instance_ids: [task_arn], # required
            dry_run: false,
        })
    end
end
