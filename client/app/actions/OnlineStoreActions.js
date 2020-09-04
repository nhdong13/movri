import { onlineStoreConstants } from '../constants/OnlineStoreConstants'

const addSectionItem = (section) => {
  return {
    type: onlineStoreConstants.ADD_SECTION,
    payload: section
  }
}

const updateSectionItem = (section) => {
  return {
    type: onlineStoreConstants.UPDATE_SECTION,
    payload: section
  }
}

const removeSectionItem = (sectionId) => {
  return {
    type: onlineStoreConstants.REMOVE_SECTION,
    payload: sectionId
  }
}

const updateSectionsList = (sections) => {
  return {
    type: onlineStoreConstants.UPDATE_SECTIONS_LIST,
    payload: sections
  }
}

export const onlineStoreActions = {
  addSectionItem,
  updateSectionItem,
  removeSectionItem,
  updateSectionsList
}