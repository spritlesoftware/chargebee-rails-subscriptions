module ChargebeeRails
  class WebhooksController < ActionController::Base
    include WebhookHandler
    before_action :authenticate, if: "ChargebeeRails.configuration.secure_webhook_api"

    # Handle ChargeBee webhook events
    # From the post request received from chargebee, the event for which the
    # webhook is triggered is found from the id parameter sent.
    # The event is then handled by the WebhookHandler module.
    # * *Raises* :
    #   - +ChargebeeRails::Error+ -> If event is not valid or if event unprocessable
    def handle_event
      event = ChargeBee::Event.retrieve(params[:id]).event
      handle(event)
      head :ok
      rescue ChargebeeRails::Error => e
        log_errors(e)
        head :internal_server_error
    end

    private

    def log_errors(e)
      logger.error e.message
      e.backtrace.each { |line| logger.error " #{line}" }
    end

    # Basic http authentication for ChargeBee webhook apis
    # The username and password used to secure the webhook at chargebee
    # is compared with the configured webhook_authentication user and
    # secret in the application.
    def authenticate
      authenticate_or_request_with_http_basic do |user, password|
        user == ChargebeeRails.configuration.webhook_authentication[:user] &&
        password == ChargebeeRails.configuration.webhook_authentication[:secret]
      end
    end

  end
end
