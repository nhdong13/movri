import Immutable from 'immutable';

const initialState = {
  header: {},
  slideshow: {}
};

const onlineStoreReducer = (state = initialState, action) => {
  const { type, payload } = action;
  switch (type) {
    default:
      return state;
  }
};

export default onlineStoreReducer;
