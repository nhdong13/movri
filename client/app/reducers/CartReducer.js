import Immutable from 'immutable';

const initialState = {
  listing: {
    title: 'abc',
    price: 1000,
    quantity: 1,
  }
};

const changeQuantityReducer = (state = initialState, action) => {
  const { type, payload } = action;
  switch (type) {
    case 'CHANGEQUANTITY':
      item = action.payload.cart.item
      item['quantity'] = action.payload.quantity
      item['price'] = item["price"] * action.payload.quantity
      action.payload.cart.item = item
      return action.payload.cart;
    default:
      return state;
  }
};

export default changeQuantityReducer;
