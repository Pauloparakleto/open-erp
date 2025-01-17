# frozen_string_literal: true

# CanceledBlingOrderItemsJob perform against created orders set previously
# with another status.
# For this reason, we should call this job as an updater job.
# We keep the create block as it is since we can not prove bling
# erp first create a e.g. checked status then
# update its own data to the canceled one.
class CanceledBlingOrderItemsJob < BlingOrderItemCreatorBaseJob
  queue_as :default
  STATUS = BlingOrderItem::Status::CANCELED.freeze

  attr_accessor :account_id

  def perform(account_id)
    @status = STATUS
    @account_id = account_id
    begin
      orders = Services::Bling::Order.call(order_command: 'find_orders', tenant: account_id,
                                           situation: STATUS)
      orders = orders['data']

      create_orders(orders)
    rescue StandardError => e
      Rails.logger.error(e.message)
    end
  end
end
