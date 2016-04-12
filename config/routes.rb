ChargebeeRails::EventEngine.routes.draw do
  root to: 'webhooks#handle_event', via: :post
end
