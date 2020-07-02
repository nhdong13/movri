import { onlineStoreConstants } from '../constants/OnlineStoreConstants'

const addSectionItem = (section) => {
  return {
    type: onlineStoreConstants.ADD_SECTION,
    payload: section
  }
}

export const onlineStoreActions = {
  addSectionItem
}