class CheckoutController < ApplicationController
  def create
    # getting the stipe secret from the credentials file
    stripe_secret_key = Rails.application.credentials.dig(:stripe_secret_Key)
    # setting the stripe_secret_key to the stripe client object
    # Stripe is coming from the gem
    Stripe.api_key = stripe_secret_key
    # grab the data sent from the frontend via params
    # json formt
    cart = params[:cart]

    #  Iterates over cart items, transforming them into Stripe's line item format.
    #  basically the user are paying or calcultating line by line
    line_items = cart.map do |item|
      # find the product in the database/models
      product = Product.find(item["id"])
      # make the size is available
      product_stock = product.stocks.find{|ps| ps.size == item["size"] }

      # making sure the its in stock if not returns error
      if product_stock.amount < item["quantity"].to_i
        render json: { error: "Not enough stock for #{product.name} in size #{item["size"]}. Only #{product_stock.amount} left." }, status: 400
        return
      end
      ### Stripe Line Data Sturcture
      # creating a line item for stripe
      # this is probably how stripe likes its data to be formatted/structured
      {
        quantity: item["quantity"].to_i,
        price_data: {
          product_data: {
            name: item["name"],
            metadata: { product_id: product.id, size: item["size"], product_stock_id: product_stock.id }
          },
          currency: "usd",
          unit_amount: item["price"].to_i
        }
      }
      # end of loop
    end


    #consoles logs
    puts "line_items: #{line_items}"

    # creates a stripe session
    session = Stripe::Checkout::Session.create(
      mode: "payment",
      line_items: line_items, #the data
      success_url: "http://localhost:3000/success",
      cancel_url: "http://localhost:3000/cancel",
      shipping_address_collection: {
        allowed_countries: ['US', 'CA']
      }
    )
    # returns a JSON response containing the Stripe Checkout Session redirect URL.
    render json: { url: session.url }
  end

  # render basic success/cancellation views.
  def success
    render :success
  end

  def cancel
    render :cancel
  end
end
