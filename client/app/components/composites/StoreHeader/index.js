import React, { Component } from 'react'
import { SketchPicker } from 'react-color';
import axios from 'axios'
import ImageUploader from 'react-images-upload';
import './style.css'
import { previewUploadImageSrc } from '../../../utils/common';
import TagLine from './TagLine'
import Phone from './Phone'
import ContactUs from './ContactUs'
import Faq from './Faq'
import AnnouncementBar from './AnnouncementBar'

class StoreHeader extends Component {
  constructor(props) {
    super(props)
    this.handleFormOnChange = this.handleFormOnChange.bind(this)
    this.handleSubmitForm = this.handleSubmitForm.bind(this)
    this.colorPickToggle  = this.colorPickToggle.bind(this)
    this.bgPickToggle     = this.bgPickToggle.bind(this)
    this.handleTextColorChangeComplete = this.handleTextColorChangeComplete.bind(this)
    this.handleBgColorChangeComplete  = this.handleBgColorChangeComplete.bind(this)
    this.handleClose = this.handleClose.bind(this)
    this.onloadCallback = this.onloadCallback.bind(this)
    this.onDrop = this.onDrop.bind(this)
    this.handleChangeTagLineSetting = this.handleChangeTagLineSetting.bind(this)
    this.handleChangePhoneSetting = this.handleChangePhoneSetting.bind(this)
    this.handleChangeContactUsSetting = this.handleChangeContactUsSetting.bind(this)
    this.handleChangeFaqSetting = this.handleChangeFaqSetting.bind(this)
    this.handleChangeAnnouncementBarSetting = this.handleChangeAnnouncementBarSetting.bind(this)

    this.axiosDefaultParams = {
      authenticity_token: $('input[name ="authenticity_token"]').val()
    }

    this.state = {
      textColorEnabled: false,
      bgColorEnabled: false,
      object: props.object,
      imageUploading: false
    }
  }

  componentDidMount() {
    axios.defaults.headers = {
      'Content-Type': 'application/json'
    }
  }

  handleFormOnChange(e) {
    let value = e.target.value
    if (e.target.type === 'checkbox') {
      value = e.target.checked
    }
    this.setState({
      object: {...this.state.object, [e.target.name]: value}
    })
  }

  handleSubmitForm(e) {
    e.preventDefault()
    const store_header = {
      sticky_enabled: this.state.object.sticky_enabled,
      tag_line_setting: JSON.stringify(this.state.object.tag_line_setting),
      phone_number_setting: JSON.stringify(this.state.object.phone_number_setting),
      contact_us_setting: JSON.stringify(this.state.object.contact_us_setting),
      faq_setting: JSON.stringify(this.state.object.faq_setting),
      announcement_bar_setting: JSON.stringify(this.state.object.announcement_bar_setting),
    }

    const params = {...this.axiosDefaultParams, store_header}
    this.setState({loading: true})
    axios.put(`/admin/store_headers/${this.state.object.id}`, params).then(res => {
      this.setState({loading: false})
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  handleClose() {
    this.setState({
      textColorEnabled: false,
      bgColorEnabled: false
    })
  }

  onloadCallback(src){
    this.setState({
      object: {
        ...this.state.item,
        logo_url: src
      }
    })
  }

  onDrop(image) {
    previewUploadImageSrc(image, this.onloadCallback)
    const formData = new FormData()
    formData.append('authenticity_token', $('input[name ="authenticity_token"]').val())
    formData.append('logo', image[0])

    axios.post(`/admin/store_headers/${this.state.object.id}/upload_logo`, formData).then(res => {
      this.setState({
        object: {
          ...this.state.object,
          logo_url: res.data.logo_url
        }
      })
      $("#homepage-preview-iframe").attr("src", function(index, attr){ 
        return attr;
      });
    })
  }

  colorPickToggle() {
    this.setState({textColorEnabled: !this.state.textColorEnabled})
  }

  bgPickToggle() {
    this.setState({bgColorEnabled: !this.state.bgColorEnabled})
  }

  handleTextColorChangeComplete(color) {
    this.setState({
      object: {...this.state.object, text_color: color.hex}
    })
  }

  handleBgColorChangeComplete(color) {
    this.setState({
      object: {...this.state.object, background_color: color.hex}
    })
  }

  handleChangeTagLineSetting(tagLineSetting) {
    this.setState({
      object: {...this.state.object, tag_line_setting: tagLineSetting}
    })
  }

  handleChangePhoneSetting(phoneSetting) {
    this.setState({
      object: {...this.state.object, phone_number_setting: phoneSetting}
    })
  }

  handleChangeContactUsSetting(contactUsSetting) {
    this.setState({
      object: {...this.state.object, contact_us_setting: contactUsSetting}
    })
  }

  handleChangeFaqSetting(faqSetting) {
    this.setState({
      object: {...this.state.object, faq_setting: faqSetting}
    })
  }

  handleChangeAnnouncementBarSetting(announcementBarSetting) {
    this.setState({
      object: {...this.state.object, announcement_bar_setting: announcementBarSetting}
    })
  }

  render() {
    const styles = {
      cover: {
        position: 'fixed',
        top: '0px',
        right: '0px',
        bottom: '0px',
        left: '0px',
      }
    }

    let tagLineSetting = this.state.object.tag_line_setting || {}
    let phoneNumberSetting = this.state.object.phone_number_setting || {}
    let contactUsSetting = this.state.object.contact_us_setting || {}
    let faqSetting = this.state.object.faq_setting || {}
    let announcementBarSetting = this.state.object.announcement_bar_setting || {}

    return (
      <div className='store-header'>
        <div className='breabcrum' onClick={() => this.props.toggleActiveSub('')}>
          <i className="icon-chevron-left"></i>
          <span>Header</span>
        </div>
        <h1 className=''>Settings</h1>
        <div className='main-form-content'>
          <form onSubmit={this.handleSubmitForm}>
            <div className='checkbox-control'>
              <input 
                className='checkbox-input' 
                name='sticky_enabled' 
                type='checkbox'
                checked={this.state.object.sticky_enabled}
                onChange={this.handleFormOnChange}
                id='sticky_enabled' />
              <label htmlFor='sticky_enabled' className='checkbox-label'>Enable sticky header</label>
            </div>
            <div className='logo-image'>
              <p>Logo image</p>
              <p>200 x 80px .png recommended</p>
              <div className=''>
                <img src={this.state.object.logo_url} alt='logo-image' />
                <ImageUploader
                  className='logo-uploader'
                  withLabel={false}
                  withIcon={false}
                  buttonText='Choose images'
                  onChange={this.onDrop}
                  imgExtension={['.jpg', '.gif', '.png', '.gif']}
                  maxFileSize={5242880}
                  singleImage={true}
                />
              </div>
            </div>
            <div className='border-top-gray'>
              <TagLine 
                object={tagLineSetting} 
                handleChangeTagLineSetting={this.handleChangeTagLineSetting}/>
            </div>
            <div className='border-top-gray'>
              <Phone 
                object={phoneNumberSetting} 
                handleChangePhoneSetting={this.handleChangePhoneSetting}/>
            </div>
            <div className='border-top-gray'>
              <ContactUs 
                object={contactUsSetting} 
                handleChangeContactUsSetting={this.handleChangeContactUsSetting}/>
            </div>
            <div className='border-top-gray'>
              <Faq 
                object={faqSetting} 
                handleChangeFaqSetting={this.handleChangeFaqSetting}/>
            </div>
            <div className='border-top-gray'>
              <AnnouncementBar 
                object={announcementBarSetting}
                handleChangeAnnouncementBarSetting={this.handleChangeAnnouncementBarSetting}
              />                
            </div>
                <button className='btn' type='submit'>{ this.state.loading ? 'Saving...' : 'Save' }</button>
          </form>
        </div>
      </div>
    )
  }
}

StoreHeader.defaultProps = {
  object: {
    logo_url: 'images/missing_image.png'
  }
}

export default StoreHeader