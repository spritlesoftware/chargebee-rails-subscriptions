module ChargebeeRails
  class WebhooksController < ActionController::Base
    include WebhookHandler
    before_filter :authenticate, if: "ChargebeeRails.configuration.secure_webhook_api"

    # Handle ChargeBee webhook  events
    def handle_event
      event = ChargeBee::Event.retrieve(params[:id]).event
      handle(event)
      head :ok
      rescue ChargebeeRails::UnauthorizedError => e
        log_errors(e)
        head :unauthorized
    end

    private

    def log_errors(e)
      logger.error e.message
      e.backtrace.each { |line| logger.error " #{line}" }
    end

    # basic http authentication for ChargeBee webhook apis
    def authenticate
      authenticate_or_request_with_http_basic do |user, password|
        user == ChargebeeRails.configuration.webhook_authentication[:user] &&
        password == ChargebeeRails.configuration.webhook_authentication[:secret]
      end
    end

  end
end
