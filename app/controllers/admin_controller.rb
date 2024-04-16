class AdminController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    # Fetch recent, unfulfilled orders
    @orders = Order.where(fulfilled: false).order(created_at: :desc).take(5)

    # Quick stats for today
    @quick_stats = {
      sales: Order.where(created_at: Time.now.midnight..Time.now).count, # Order count
      revenue: Order.where(created_at: Time.now.midnight..Time.now).sum(:total)&.round(), # Total revenue
      avg_sale: Order.where(created_at: Time.now.midnight..Time.now).average(:total)&.round(), # Average order value
      # joins the orderPorduct tables and the orders tables and calculates the average number of items sold per order
      per_sale: OrderProduct.joins(:order).where(orders: { created_at: Time.now.midnight..Time.now })&.average(:quantity) # Average items per sale
    }

    # Orders for the past 7 days
    @orders_by_day = Order.where('created_at > ?', Time.now - 7.days).order(:created_at)
    @orders_by_day = @orders_by_day.group_by { |order| order.created_at.to_date }

    # Revenue by day (array of [day, revenue] arrays)
    @revenue_by_day = @orders_by_day.map { |day, orders| [day.strftime("%A"), orders.sum(&:total)] }

    # Logic to fill missing days with zero revenue
    if @revenue_by_day.count < 7
      days_of_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      data_hash = @revenue_by_day.to_h # Convert to hash for easier lookup
      current_day = Date.today.strftime("%A")
      current_day_index = days_of_week.index(current_day)
      next_day_index = (current_day_index + 1) % days_of_week.length
      ordered_days_with_current_last = days_of_week[next_day_index..-1] + days_of_week[0...next_day_index]
      complete_ordered_array_with_current_last = ordered_days_with_current_last.map{ |day| [day, data_hash.fetch(day, 0)] }
      @revenue_by_day = complete_ordered_array_with_current_last
    end
  end
end
