class WebhooksController < ApplicationController
    http_basic_authenticate_with name: "chargebee-joiner", password: ENV['CHARGEBEE_AUTH_PASSWORD']

    PLAN_TIERS = {
        "joiner---mini" => "individual",
        "joiner--team" => "team",
        "joiner--individual-annual" => "individual",
        "joiner--team-annual" => "team",
        "cbdemo_free" => "trial"
    }
    
    def subscription_events
        if request.headers['Content-Type'] == 'application/json'
            data = JSON.parse(request.body.read)
        else
            # application/x-www-form-urlencoded
            data = params.as_json
        end

        if data["event_type"] == "subscription_created" and
            data["content"]["customer"]["card_status"] == "valid"
            # Create the account
            email = data["content"]["customer"]["email"]
            name = data["content"]["customer"]["billing_address"]["first_name"] + " " + data["content"]["customer"]["billing_address"]["last_name"]
            plan = data["content"]["invoice"]["line_items"][0]["entity_id"]
            password = SecureRandom.urlsafe_base64.to_s

            puts "Plan: #{plan}"
            puts "Tiers: #{PLAN_TIERS}"
            puts "So... #{PLAN_TIERS[plan]}"

            user = User.create!({
                email: email,
                name: name,
                tier: PLAN_TIERS[plan],
                password: password
            })  
            
            # Mail the confirm link
            Concurrent::Future.execute{ 
                ApplicationMailer.registration_confirmation(user).deliver
            }

            render json: {body: "success!"}
        else
            render json: {body: "An error occurred", status: 500}
        end
    end
end