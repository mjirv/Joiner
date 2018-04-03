module AwsFunctions
    IND_LAUNCH_TEMPLATE = "lt-0912ea6ef3e419531"
    TEAM_LAUNCH_TEMPLATE = "lt-0882627cf556d5a45"

    def create_join_db(user_id, join_db_id)
        # Something about the default Ruby SSL certificate
        Aws.use_bundled_cert!
        ec2_client = Aws::EC2::Client.new()

        is_team = ["team", "enterprise"].include? User.find(user_id).tier
        instance_id = run_new_join_db_task(ec2_client, is_team)

        # Wait until it's created to get the DNS name
        ec2_client.wait_until(:instance_running, instance_ids: [instance_id])
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

    def run_new_join_db_task(ec2_client, is_team)
        available_subnets = ec2_client.describe_subnets.subnets.map(&:subnet_id)
        if is_team
            launch_template = ENV['TEAM_LAUNCH_TEMPLATE'] || TEAM_LAUNCH_TEMPLATE
        else
            launch_template = ENV['IND_LAUNCH_TEMPLATE'] || IND_LAUNCH_TEMPLATE
        end

        resp = ec2_client.run_instances({
            launch_template: {
                launch_template_id: launch_template
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
