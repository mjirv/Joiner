class WebhooksController < ApplicationController
    def subscription_events
        if request.headers['Content-Type'] == 'application/json'
            data = JSON.parse(request.body.read)
        else
            # application/x-www-form-urlencoded
            data = params.as_json
        end
        
        console.log(data)
        render json: "success!"
    end
end