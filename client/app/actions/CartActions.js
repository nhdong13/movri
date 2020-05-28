export const changeQuantityCartItem = (quantity, listing) => {
  debugger
  return {
    type: 'CHANGEQUANTITY',
    payload: {
      quantity: quantity,
      listing: listing
    }
  };
};