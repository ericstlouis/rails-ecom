import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="cart"
export default class extends Controller {
  initialize() {
    console.log('cart controller initialized');
    //get the cart json from local storage
    const cart = JSON.parse(localStorage.getItem('cart'));
    //if no cart return 
    if (!cart) {
      return;
    }

    //loop though the cart and get the total price of each items by muliply the quanity with the price
    let total = 0;
    for (let i = 0; i < cart.length; i++) {
      const item = cart[i];
      total += item.price * item.quantity;
      //change the html and show the items in the cart using css and html
      const div = document.createElement('div');
      div.classList.add('mt-2');
      div.innerText = `Item: ${item.name} - $${item.price / 100.0} - Size: ${
        item.size
        } - Quantity: ${item.quantity}`;
      //create delete button to delete item from cart
      const deleteButton = document.createElement('button');
      deleteButton.innerText = 'Remove';
      console.log('item.id: ', item.id);
      deleteButton.value = JSON.stringify({ id: item.id, size: item.size });
      deleteButton.classList.add(
        'bg-gray-500',
        'rounded',
        'text-white',
        'px-2',
        'py-1',
        'ml-2'
      );
      deleteButton.addEventListener('click', this.removeFromCart);
      div.appendChild(deleteButton);
      this.element.prepend(div);
    }

    //shows the total price for the entire cart
    const totalEl = document.createElement('div');
    totalEl.innerText = `Total: $${total / 100.0}`;
    let totalContainer = document.getElementById('total');
    totalContainer.appendChild(totalEl);
  }


//clear the entire cart
  clear() {
    localStorage.removeItem('cart');
    window.location.reload();
  }

  //remove item from cart by id and size 
  //this is what the delete buttton calls
  removeFromCart(event) {
    const cart = JSON.parse(localStorage.getItem('cart'));
    const values = JSON.parse(event.target.value);
    const { id, size } = values;
    const index = cart.findIndex(
      (item) => item.id === id && item.size === size
    );
    if (index >= 0) {
      cart.splice(index, 1);
    }
    localStorage.setItem('cart', JSON.stringify(cart));
    window.location.reload();
  }

  //checkout send a network request to stripe g
  checkout() {
    const cart = JSON.parse(localStorage.getItem('cart'));
    const payload = {
      authenticity_token: '',
      cart: cart,
    };

    const csrfToken = document.querySelector("[name='csrf-token']").content;

    fetch('/checkout', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify(payload),
    }).then((response) => {
      if (response.ok) {
        response.json().then((body) => {
          window.location.href = body.url;
        });
      } else {
        // if the request fails
        response.json().then((body) => {
          const errorEl = document.createElement('div');
          errorEl.innerText = `There was an error processing your order. ${body.error}`;
          let errorContainer = document.getElementById('errorContainer');
          errorContainer.appendChild(errorEl);
        });
      }
    });
  }
}

