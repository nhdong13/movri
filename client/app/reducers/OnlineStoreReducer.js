import { onlineStoreConstants } from '../constants/OnlineStoreConstants'


const initialState = {
  sections: {}
};

const onlineStoreReducer = (state = initialState, action) => {
  const { type, payload } = action;
  switch (type) {
    case onlineStoreConstants.ADD_SECTION:
      return {...state, sections: [...state.sections, payload]}
    default:
      return state;
  }
};

export default onlineStoreReducer;
