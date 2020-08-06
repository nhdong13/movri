import React, { Component } from 'react';
import ImageUploader from 'react-images-upload';
import { previewUploadImageSrc } from '../../../utils/common'

class SocialMedia extends Component {
  constructor(props) {
    super(props)
    this.onDrop = this.onDrop.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
    this.handleOnChangeAccount = this.handleOnChangeAccount.bind(this)
  }

  onDrop(image) {
    previewUploadImageSrc(image, this.onloadCallback)
    this.props.handleChangePreferences({...this.props.preferences, social_media_image: image}) 
  }

  onloadCallback(src) {
    this.props.handleChangePreferences({...this.props.preferences, social_media_image_url: src}) 
  }

  handleOnChangeAccount(e) {
    let social_media_accounts = this.props.preferences.social_media_accounts || {}
    social_media_accounts[e.target.name] = e.target.value
    this.props.handleChangePreferences({...this.props.preferences, social_media_accounts: social_media_accounts})
  }

  render() {
    let preferences = this.props.preferences || {}
    let social_media_accounts = preferences.social_media_accounts || {}
    return (
      <div className="section row">
        <label className="m-1">Social Media</label>
        <div className="section-wrapper col-8 m-1 row">
          <div className="col-5">
            { preferences.social_media_image_url && <img className="preview-image" src={preferences.social_media_image_url} alt='social-media-image'/>}
            <ImageUploader
              className='social-media-uploader'
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
            <label>ACCOUNTS</label>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Facebook</label>
              <input type='text' value={social_media_accounts['facebook'] || ""} name="facebook" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://facebook.com/movri</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Twitter</label>
              <input type='text' value={social_media_accounts['twitter'] || ""} name="twitter" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://twitter.com/movri</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">LinkedIn</label>
              <input type='text' value={social_media_accounts['linkedin'] || ""} name="linkedin" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://linkedin.com/company/movri</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Email address</label>
              <input type='text' value={social_media_accounts['email'] || ""} name="email" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">info@example.com</div>
            </div>
          </div>
          <div className="col-5">
            <div className="form-control">
              <label className="font-weight-regular mt-1">Google+</label>
              <input type='text' value={social_media_accounts['google_plus'] || ""} name="google_plus" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://plus.google.com/+shopify</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Pinterest</label>
              <input type='text' value={social_media_accounts['pinterest'] || ""} name="pinterest" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://pinterest.com/movri</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Instagram</label>
              <input type='text' value={social_media_accounts['instagram'] || ""} name="instagram" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://instagram.com/movri</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Tumblr</label>
              <input type='text' value={social_media_accounts['tumblr'] || ""} name="tumblr" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://shopify.tumblr.com</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Vimeo</label>
              <input type='text' value={social_media_accounts['vimeo'] || ""} name="vimeo" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://vimeo.com/shopify</div>
            </div>
            <div className="form-control">
              <label className="font-weight-regular mt-1">Youtube</label>
              <input type='text' value={social_media_accounts['youtube'] || ""} name="youtube" onChange={this.handleOnChangeAccount}/>
              <div className="font-size-14 text-gray">https://youtube.com/shopify</div>
            </div>
          </div>
        </div>
      </div>
   );
 }
}

export default SocialMedia;