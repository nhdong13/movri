import React, { Component } from 'react';
import ImageUploader from 'react-images-upload';
import { previewUploadImageSrc } from '../../../utils/common'

class Favicon extends Component {
  constructor(props) {
    super(props)
    this.state = {
    }
    this.onDrop = this.onDrop.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
  }

  onDrop(image) {
    previewUploadImageSrc(image, this.onloadCallback)
    this.props.handleChangePreferences({...this.props.preferences, favicon_icon: image}) 
  }

  onloadCallback(src) {
    this.props.handleChangePreferences({...this.props.preferences, favicon_icon_url: src}) 
  }

  render() {
    let preferences = this.props.preferences || {}
    return (
      <div className="section row">
        <label className="m-1">Favicon</label>
        <div className="section-wrapper col-8 m-1 row">
          <div className="col-5">
            <label className="font-weight-regular mt-1">Favicon image</label>
            <div className="font-size-14 text-gray">32 x 32px .png required</div>
            { preferences.favicon_icon_url && <img className="preview-image" src={preferences.favicon_icon_url} alt='favicon-image'/>}
            <ImageUploader
              className='favicon-uploader'
              withLabel={false}
              withIcon={false}
              buttonText='Choose image'
              buttonClassName='m-0 p-1 font-weight-regular'
              onChange={this.onDrop}
              imgExtension={['.jpg', '.gif', '.png', '.gif']}
              maxFileSize={5242880}
              name='image'
              singleImage={true}
            />
          </div>
        </div>
      </div>
   );
 }
}

export default Favicon;