export const randomString = () => {
  return Math.random().toString(36).substring(7)
}

export const previewUploadImageSrc = (file, callback) => {
  if(!file.length) return false;
  let src = undefined
  let reader = new FileReader()
  reader.onload = (e) => {
    callback(e.target.result)
  }
  reader.readAsDataURL(file[0])
  return src
}