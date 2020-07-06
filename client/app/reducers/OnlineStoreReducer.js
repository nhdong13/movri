import { onlineStoreConstants } from '../constants/OnlineStoreConstants'


const initialState = {
  sections: {}
};

const onlineStoreReducer = (state = initialState, action) => {
  const { type, payload } = action;
  switch (type) {
    case onlineStoreConstants.ADD_SECTION:
      return {...state, sections: [...state.sections, payload]}
    case onlineStoreConstants.UPDATE_SECTION:
      const index = state.sections.findIndex(item => item.id === payload.id)
      return {
        ...state,
        ...state.sections.splice(index, 1, payload)
      }
    case onlineStoreConstants.REMOVE_SECTION:
      let newSections = state.sections.filter(elm => {
        return elm.id != payload
      })
      return {
        ...state,
        sections: newSections
      }
    default:
      return state;
  }
};

export default onlineStoreReducer;
