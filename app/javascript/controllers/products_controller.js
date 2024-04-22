import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="products"
export default class extends Controller {
  static values = { size: String, product: Object };

  addToCart() {
    console.log('product', this.productValue);
    //get cart in local storage
    const cart = localStorage.getItem('cart');
    //check if cart exists in local storage
    if (cart) {
      //parse cart from local storage
      const cartItems = JSON.parse(cart);
      //get the cart item index by comparing the id and the size
      const foundIndex = cartItems.findIndex(
        (item) =>
          item.id === this.productValue.id && item.size === this.sizeValue
      );
      //if we find the index increment the quantity
      if (foundIndex >= 0) {
        cartItems[foundIndex].quantity = parseInt(
          cartItems[foundIndex].quantity + 1
        );
      } else {
        //if we don't find the index add the item to the cart array
        cartItems.push({
          id: this.productValue.id,
          name: this.productValue.name,
          price: this.productValue.price,
          quantity: 1,
          size: this.sizeValue,
        });
      }
      //update the local storage with the new cart array
      localStorage.setItem('cart', JSON.stringify(cartItems));
      //if they is no cart create an ampty and push the item into it
    } else {
      const cartArray = [];
      cartArray.push({
        id: this.productValue.id,
        name: this.productValue.name,
        price: this.productValue.price,
        quantity: 1,
        size: this.sizeValue,
      });
      //set item to local storage
      localStorage.setItem('cart', JSON.stringify(cartArray));
    }
  }

  //select the size of the item
  selectSize(e) {
    //assign the value to this.sizeValue
    this.sizeValue = e.target.value;
    console.log('size 2', this.sizeValue);
    //change the html
    const selectedSize = document.getElementById('selected-size');
    selectedSize.innerText = `Selected size: ${this.sizeValue}`;
  }

  connect() {
    console.log('ProductsController  connected! from stimmy');
  }
}


