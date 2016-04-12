module ChargebeeRails
  class WebhooksController < ActionController::Base
    before_filter :authenticate, if: "ChargebeeRails.configuration.secure_webhook_api"

    def handle_event
      event = ChargeBee::Event.retrieve(params[:id]).event
      EventHandler.new(event).handle_event
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

    def authenticate
      authenticate_or_request_with_http_basic do |user, password|
        user == ChargebeeRails.configuration.webhook_authentication[:user] &&
        password == ChargebeeRails.configuration.webhook_authentication[:secret]
      end
    end

  end
end
