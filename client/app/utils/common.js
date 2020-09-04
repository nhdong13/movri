export const randomString = () => {
  return Math.random().toString(36).substring(7)
}

export const previewUploadImageSrc = (file, callback, id=null) => {
  if(!file.length) return false;
  let src = undefined
  let reader = new FileReader()
  reader.onload = (e) => {
    if (id) {
      callback(id, e.target.result)
    } else {
      callback(e.target.result)
    }
  }
  reader.readAsDataURL(file[0])
  return src
}

export const PickColorstyles = {
  cover: {
    position: 'fixed',
    top: '0px',
    right: '0px',
    bottom: '0px',
    left: '0px',
  }
}

export const editorCustomConfig = {
  toolbarGroups: [
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
    { name: 'links' },
    { name: 'styles' },
    { name: 'colors' },
    { name: 'insert' },
  ]
}

export const sortByOrderNumber = (array) => {
  return array.sort((a,b) => (a.order_number > b.order_number) ? 1 : ((b.order_number > a.order_number) ? -1 : 0));
}